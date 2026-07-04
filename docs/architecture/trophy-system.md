# Trophy System Architecture — k12-cms-score Module

**Version:** 1.0 | **Last Updated:** 2026-07-04 | **Owner:** k12-cms-score team

---

## Overview

Trophy system trong k12-cms-score là hệ thống **async event-driven** để cấp, quản lý, và xếp hạng học sinh dựa trên trophies (cups). Hệ thống nhận trophy events từ 3 sources khác nhau và cập nhật ranking real-time qua Redis sorted sets.

---

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│ SOURCES (3 Producers)                                   │
│ ├─ SendTrophyServiceImpl (individual trophy)            │
│ ├─ Bulk endpoint (give-trophy-ranking)                 │
│ └─ GiveTrophyEvent scheduler (quiz auto-award)         │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ KAFKA TOPICS (Async Distribution)                       │
│ ├─ give-trophy-event (3 partitions, batch)             │
│ ├─ give-trophy-ranking (3 partitions, real-time)       │
│ └─ system-message (broadcast to Socket.IO)             │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ CONSUMERS (k12-cms-score)                               │
│ ├─ GiveTrophyProfileListener (batch 50 msgs)           │
│ └─ GiveTrophyRankingListener (real-time, bulk lookup)  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ PROCESSING (TrophyRankingServiceImpl)                    │
│ └─ zincrby → Redis sorted set                          │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│ STORAGE & OUTPUT                                        │
│ ├─ Redis: Sorted Set (ranking by score)                │
│ └─ Socket.IO: Real-time notifications                  │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow — 3 Paths

### Path 1️⃣ Individual Trophy (give-trophy-event)

**Source:** `SendTrophyServiceImpl` (lms-ai-teacher module)

**Trigger:** Whenever a student completes an exercise and should get a trophy.

```
SendTrophyServiceImpl.sendTrophy(K12ExerciseScore)
  ↓
  Create GiveTrophyDto {
    profileId:        int
    sessionParentId:  int
    classRoomId:      long
    trophyType:       String (e.g., "IMPROVEMENT_AWARD")
    numberOfTrophies: int (default: 1)
  }
  ↓
  kafka2PublisherService.sendMessage(
    topic: "give-trophy-event",
    json: GiveTrophyDto
  )
```

**Consumer:** `GiveTrophyProfileListener` (k12-cms-score)
- **Topic:** `give-trophy-event` (3 partitions)
- **Group ID:** `k12-learning-profile-group`
- **Batch Config:**
  - `MAX_POLL_RECORDS = 50` messages per poll
  - `Concurrency = 3` threads (one per partition)
  - `AckMode = MANUAL` (ack after all processed)

**Processing:**
1. Receive batch of JSON strings (List<String> payloads)
2. Parse each JSON → extract {profileId, sessionParentId, classRoomId, trophyType, numberOfTrophies}
3. **Group by numberOfTrophies** (same score → batch update together)
4. For each group:
   ```
   Map<String, Set<String>> keyToMembers = {
     "K12_PRODUCT_RANKING:sessionParentId:classRoomId": {"profileId1", "profileId2", ...}
   }
   trophyRankingService.incrementBatch(keyToMembers, numberOfTrophies)
   ```
5. **Parallel notify socket** — call `trophySocketNotifier.notify()` for each event
   - Publishes to `system-message` topic
   - Message type: `GIVE_TROPHY`
   - Payload: {trophyType, numberOfTrophies, profileId}

**Error Handling:** Batch fault isolation
- Per-message try/catch (dòng 46-69 trong GiveTrophyProfileListener)
- Parse error → log warn, skip message, continue batch
- Batch error → log error, skip ack → Kafka will redeliver on restart

---

### Path 2️⃣ Bulk Trophy (give-trophy-ranking)

**Source:** Bulk endpoint (teacher-api) — e.g., "give trophy to entire class"

**Trigger:** Teacher wants to award same trophy count to multiple students at once.

```
BulkTrophyEndpoint.giveToGroup(
  sessionParentId: int,
  numberOfTrophies: int,
  giveAll: boolean,        // true = all students in session
  profileId?: int          // if giveAll=false, target 1 student
)
  ↓
  kafka2PublisherService.sendMessage(
    topic: "give-trophy-ranking",
    json: {sessionParentId, numberOfTrophies, giveAll, profileId?}
  )
```

**Consumer:** `GiveTrophyRankingListener` (k12-cms-score)
- **Topic:** `give-trophy-ranking` (3 partitions)
- **Group ID:** `k12-learning-profile-group`
- **No batch mode** — real-time processing per message

**Processing:**
1. Receive 1 message (String payload)
2. Parse JSON → {sessionParentId, numberOfTrophies, giveAll, profileId?}
3. **Lookup groups:**
   - If `giveAll=true`: 
     ```java
     List<K12TempGroup> groups = k12TempGroupService
       .findGroupAndProfileBySessionParentId(sessionParentId)
     ```
     → Create entry for **every profile in session**
   - If `giveAll=false`:
     ```java
     List<K12TempGroup> groups = k12TempGroupService
       .findByProfileIdAndSessionParentId(profileId, sessionParentId)
     ```
     → Create entry only for target profile
4. Build `Map<String, Set<String>> keyToMembers`
5. Call `trophyRankingService.incrementBatch(keyToMembers, numberOfTrophies)`

**Why Separate Topic?**
- `give-trophy-event`: Individual events (high volume, batch-able)
- `give-trophy-ranking`: Bulk operations (lower volume, needs group lookup)
- Separate topics allow different consumer configs without interference

---

### Path 3️⃣ Quiz Auto-Award (save-message-queue)

**Source:** `GiveTrophyEvent` listener (teacher-api, listening to `save-message-queue`)

**Trigger:** QUIZ event comes in from Socket.IO live session.

```
Socket.IO Session publishes QUIZ event
  ↓
GiveTrophyEvent.saveMessageQueueEventListener(
  topic: "save-message-queue",
  groupId: "lms-teacher-api-group"
)
  ↓
1. Check if messageType == "QUIZ"
2. Get currentExerciseId
3. Check Redis cache (REDIS_KEY_K12_CHECK_GIVE_TROPHY_QUIZ:{groupId})
4. If NOT in cache:
     - Lookup lmsSessions by groupId
     - Find latest QUIZ auto-event (max timeAuto)
     - Store exerciseId in Redis (2 hours TTL)
5. If currentExerciseId matches stored exerciseId:
     - Schedule task 40 seconds later
     - After 40s: call trophyService.checkStudentDoneExercise(groupId)
```

**Why 40 seconds?**
- Allow last-minute submissions before awarding trophy
- Avoid race condition with pending submissions

**Note:** This path is in `teacher-api`, not k12-cms-score. Mentioned here for completeness.

---

## Core Components

### TrophyRankingServiceImpl

Implements the actual Redis update logic.

```java
public void incrementBatch(Map<String, Set<String>> keyToMembers, 
                          int numberOfTrophies) {
  double score = (double) numberOfTrophies * SCORE_PER_TROPHY;
  // SCORE_PER_TROPHY = 10_000_000_000L (10 billion)
  
  redisService.zincrbyBatch(keyToMembers, score);
  // Redis ZINCRBY: increment score for each member in each key
}
```

**Why multiply by 10B?**
- Allows fine-grained ranking without floating-point errors
- 1 trophy = 10B points
- 100 trophies = 1T points (still fits in Long)

---

### TrophyRankingKeyBuilder

Constructs Redis sorted set keys.

```java
public static String build(int sessionParentId, long classRoomId) {
  return REDIS_KEY_K12_PRODUCT_RANKING_TEMPLATE 
       + sessionParentId + ":" + classRoomId;
}
```

**Result:** `K12_PRODUCT_RANKING:123:456`
- Key uniqueness: Per session + per classroom
- Each classroom has separate leaderboard

---

### TrophySocketNotifierImpl

Publishes trophy award notifications to real-time clients.

```java
public void notify(int sessionParentId, long classRoomId, int profileId,
                  String trophyType, int numberOfTrophies) {
  // Build message
  Map<String, Object> message = {
    "groupId": "sessionParentId-classRoomId",
    "messageType": "GIVE_TROPHY",
    "message": "Tặng cup đến học sinh",
    "payload": {
      "trophyType": trophyType,
      "numberOfTrophies": numberOfTrophies,
      "profileId": profileId
    }
  };
  
  // Publish to system-message topic
  kafka2PublisherService.sendMessage("system-message", message);
}
```

**Note:** Sends to Kafka, not direct Socket.IO. Allows decoupling.

---

## Configuration

### Kafka Topics (TopicConfiguration)

```yaml
# application.yml
application:
  k12-cms:
    kafka:
      topic:
        give-trophy-event: "give-trophy-event"      # 3 partitions
        give-trophy-ranking: "give-trophy-ranking"  # 3 partitions
      group:
        k12-learning-profile-group: "k12-learning-profile-group"
```

### Consumer Config (ConsumerConfig)

**trophyProfileBatchContainerFactory** (give-trophy-event):
```java
props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 50);     // batch size
factory.setConcurrency(3);                                 // 3 threads
factory.setBatchListener(true);
factory.getContainerProperties()
  .setAckMode(ContainerProperties.AckMode.MANUAL);        // manual ack
```

**GiveTrophyRankingListener** (give-trophy-ranking):
```java
@KafkaListener(topics = "give-trophy-ranking", ...)
// Default: no custom factory, 1 thread, auto ack
```

---

## Performance Characteristics

### Throughput
- **Individual path:** 150 trophies/sec (batch 50 × 3 partitions per poll)
- **Bulk path:** Depends on group size lookup (K12TempGroupService)

### Latency
- **Individual award:** ~50ms (batch wait + Redis)
- **Socket notify:** ~100ms (Kafka publish + listener pickup)
- **Bulk award:** ~200ms (group lookup + batch process)
- **Quiz auto-award:** 40sec + checkStudentDoneExercise() time

### Redis Memory
- **Key:** `K12_PRODUCT_RANKING:sessionId:classroomId` (~40 bytes)
- **Value:** Sorted set of profileId-score pairs (~8 bytes per student)
- **Estimate:** 30k CCU × avg 50 students/classroom × 50 bytes = ~75 MB

---

## Monitoring & Debugging

### Key Metrics
1. **Consumer lag:** `GiveTrophyProfileListener` offset vs latest offset
2. **Batch processing time:** Log "incrementBatch done" with duration
3. **Socket notify latency:** Trace system-message publish timestamp
4. **Redis zincrby latency:** RedisService metrics

### Logs
- `(onGiveTrophyProfile) batch size: X` — consumer batches
- `(incrementBatch) keys: X, numberOfTrophies: Y` — batch update
- `(TrophySocketNotifier.notify) sessionParentId: X, profileId: Y` — notify
- `(onGiveTrophyRanking) error, payload: ...` — bulk operation error

### Common Issues

**Issue:** Lag in `give-trophy-event` consumer
- **Check:** Consumer concurrency vs partitions (should be 3 vs 3)
- **Fix:** Increase `ConsumerConfig.setConcurrency()`

**Issue:** Bulk trophy takes >1s
- **Check:** `K12TempGroupService.findGroupAndProfileBySessionParentId()` query performance
- **Fix:** Add MongoDB index on {sessionParentId, groupId}

**Issue:** Socket notify not reaching clients
- **Check:** `system-message` topic has listeners in WebSocket module
- **Fix:** Verify k12-socketio-worker is consuming `system-message`

---

## Deployment Checklist

- [ ] Kafka topics created: `give-trophy-event` (3 part), `give-trophy-ranking` (3 part)
- [ ] Redis cluster available (for sorted sets)
- [ ] k12-socketio-worker listening to `system-message` topic
- [ ] Monitor: Consumer lag on `k12-learning-profile-group`
- [ ] Verify: Redis memory usage after trophy season load test

---

## Related Files

| Component | File |
|-----------|------|
| Individual Consumer | `k12-cms-score/src/main/java/com/educa/product/platform/trophy/GiveTrophyProfileListener.java` |
| Bulk Consumer | `k12-cms-score/src/main/java/com/educa/product/platform/trophy/GiveTrophyRankingListener.java` |
| Ranking Service | `k12-cms-score/src/main/java/com/educa/product/platform/trophy/TrophyRankingServiceImpl.java` |
| Socket Notifier | `k12-cms-score/src/main/java/com/educa/product/platform/trophy/TrophySocketNotifierImpl.java` |
| Producer | `lms-ai-teacher/src/main/java/vn/edupiaclass/lms/scheduler/service/impl/SendTrophyServiceImpl.java` |
| Quiz Listener | `teacher-api/src/main/java/vn/edupiaclass/teacher/api/listener/event/GiveTrophyEvent.java` |
| Config | `k12-cms-score/src/main/java/com/educa/product/platform/config/{TopicConfiguration,ConsumerConfig}.java` |

---

## Future Optimizations

1. **Async Socket Notify:** Use `@Async` or `CompletableFuture` in `TrophySocketNotifier.notify()` to avoid blocking Kafka listener
2. **Batch Notification:** Collect notifications per batch, send as array instead of per-event
3. **MongoDB Projection:** Cache frequently-read trophy fields (type, icon) in Redis instead of querying DB
4. **Dedupe Events:** Check if profileId already has trophy before incrementing (prevent double-award)
5. **Fair Ranking:** Use weighted scoring instead of simple sum (e.g., recent trophies worth more)

---

**Last Review:** 2026-07-04 | **Next Review:** 2026-08-04

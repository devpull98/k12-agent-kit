# Trophy System — Quick Reference

## 3 Award Paths

| Path | Source | Topic | Consumer | Latency |
|------|--------|-------|----------|---------|
| **Individual** | SendTrophyServiceImpl | `give-trophy-event` (3 part) | GiveTrophyProfileListener (batch 50) | ~50ms |
| **Bulk** | Teacher endpoint | `give-trophy-ranking` (3 part) | GiveTrophyRankingListener (real-time) | ~200ms |
| **Quiz Auto** | GiveTrophyEvent scheduler | save-message-queue → 40s delay | trophyService.checkStudentDoneExercise() | 40s+ |

## Key Files

```
k12-cms-score/
├── trophy/
│   ├── GiveTrophyProfileListener.java       (batch consumer)
│   ├── GiveTrophyRankingListener.java       (bulk consumer)
│   ├── TrophyRankingServiceImpl.java         (Redis zincrby)
│   ├── TrophySocketNotifierImpl.java         (notify via Kafka)
│   └── TrophyRankingKeyBuilder.java         (key format)
└── config/
    ├── TopicConfiguration.java              (3 partitions each)
    └── ConsumerConfig.java                  (batch size 50, concurrency 3)
```

## Redis Structure

```
Key:   K12_PRODUCT_RANKING:{sessionParentId}:{classRoomId}
Type:  Sorted Set (ZSET)
Value: profileId → score (numberOfTrophies × 10_000_000_000L)

Example:
  ZSET K12_PRODUCT_RANKING:123:456
    profileId=1001, score=10000000000  (1 trophy)
    profileId=2002, score=50000000000  (5 trophies)
    profileId=3003, score=20000000000  (2 trophies)
  → Ranking: 2002 > 3003 > 1001
```

## Config Tuning (2026-07-04)

```java
// ConsumerConfig.trophyProfileBatchContainerFactory()
MAX_POLL_RECORDS_CONFIG = 50        // was 5 → ↑10x
concurrency = 3                      // was 1 → match 3 partitions
AckMode = MANUAL                     // batch ack after all
```

## Bottleneck Risks

| Risk | Mitigation |
|------|------------|
| Slow socket notify → blocking listener | Use `@Async` in TrophySocketNotifierImpl |
| Bulk trophy group lookup slow | Index `K12TempGroup` on (sessionParentId, profileId) |
| Redis memory growth | Monitor sorted set size; evict old trophies if needed |
| Consumer lag spike | Auto-scale concurrency or repartition topic |

## Monitoring

```bash
# Consumer lag (Kafka)
kafka-consumer-groups.sh --bootstrap-server :9092 \
  --group k12-learning-profile-group \
  --describe

# Redis memory
redis-cli INFO memory | grep used_memory_human

# Logs
grep "GiveTrophyProfile" app.log   # batch processing
grep "incrementBatch" app.log      # Redis updates
grep "TrophySocketNotifier" app.log # socket notifies
```

## Deployment Steps

1. **Create Kafka topics:**
   ```bash
   kafka-topics.sh --create --topic give-trophy-event --partitions 3
   kafka-topics.sh --create --topic give-trophy-ranking --partitions 3
   ```

2. **Start k12-cms-score** (TopicConfiguration creates topics auto on startup)

3. **Verify:**
   - Check `give-trophy-event` has 3 partitions
   - Check consumer group `k12-learning-profile-group` assigned partitions
   - Send test message to `give-trophy-event` → verify procesed

4. **Monitor:**
   - Watch consumer lag first 30 minutes
   - Check Redis memory usage

---

**Last Updated:** 2026-07-04 | See [trophy-system.md](./trophy-system.md) for full details

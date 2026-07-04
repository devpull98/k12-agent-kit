# Tech Design — {UC-ID}: {Feature Name}

<!-- @trace.uc_id: {UC-ID} -->
<!-- @trace.bdd_version: 1.0 -->
<!-- @trace.status: draft -->

## 1. Tóm tắt
<!-- 2-3 câu: feature này làm gì, tại sao cần thiết kế trước -->

**BDD Spec:** `docs/specs/bdd/{UC-ID}.feature`
**Scenarios trong scope:** SC1, SC2, SC3 (liệt kê)

---

## 2. API Endpoints (nếu có HTTP interface)

### `POST /api/{resource}`
**Mô tả:** ...
**Auth required:** Yes / No / Role: ...

**Request Body:**
```json
{
  "fieldName": "string (required) — mô tả",
  "optionalField": "number (optional, default: 0)"
}
```

**Response — 200 OK:**
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**Response — Error cases:**
| Status | Code | Khi nào |
|--------|------|---------|
| 400 | INVALID_REQUEST | Request body thiếu field bắt buộc |
| 401 | UNAUTHORIZED | Token không hợp lệ |
| 404 | NOT_FOUND | Resource không tồn tại |
| 500 | SYSTEM_ERROR | Lỗi hệ thống |

---

## 3. Database Changes (nếu cần)

### New table / collection: `{table_name}`
| Field | Type | Nullable | Index | Mô tả |
|-------|------|----------|-------|-------|
| id | BIGINT PK | No | PK | |
| ... | | | | |

### Thay đổi bảng hiện có: `{existing_table}`
```sql
-- Migration (forward only)
ALTER TABLE {table} ADD COLUMN {col} {type} {constraint};
CREATE INDEX idx_{table}_{col} ON {table}({col});
```

---

## 4. Events / Messages (nếu có Kafka/RabbitMQ)

### Topic: `{topic-name}`
**Producer:** {service/module}
**Consumer:** {service/module}

**Message schema:**
```json
{
  "eventType": "string",
  "payload": { ... },
  "timestamp": "ISO-8601"
}
```

**Idempotency:** {Cách handle duplicate message}

---

## 5. Module / Layer map
<!-- Với project multi-module: code nằm ở đâu -->
| Layer | Module / File | Trách nhiệm |
|-------|--------------|-------------|
| Controller | {module}/controller/ | Nhận request, validate |
| Service | {module}/service/ | Business logic |
| Repository | {module}/repository/ | Data access |

---

## 6. Open Questions
<!-- Liệt kê những gì chưa chốt, cần confirm trước khi code -->
- [ ] ...

## 7. Reviewer Checklist
- [ ] Schema đủ field chưa?
- [ ] Index có đủ cho các query pattern không?
- [ ] Error cases có đủ không?
- [ ] Breaking change API không? (nếu có → versioning strategy)
- [ ] Event schema có backward compatible không?

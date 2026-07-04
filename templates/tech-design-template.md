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

## 5. External Service Integrations (nếu có)
<!-- Thiết kế khi gọi API của bên thứ 3 hoặc gọi chéo sang microservice khác -->
- **Service cần gọi:** <tên service, ví dụ: Payment Gateway>
- **Giao thức:** REST / gRPC / SOAP
- **Tham số an toàn:**
  - Timeout: <ví dụ: Connection Timeout 2000ms, Read Timeout 5000ms>
  - Retry Policy: <ví dụ: Retry 3 lần, Exponential Backoff>
  - Fallback Action: <kịch bản xử lý khi API bên ngoài lỗi/sập, ví dụ: lưu queue gửi lại sau, trả lỗi thân thiện>

---

## 6. Backward Compatibility & Migration Strategy
<!-- Các rủi ro về tính tương thích ngược và kế hoạch xử lý dữ liệu cũ -->
- **API Versioning:** Có gây breaking change cho mobile/front-end cũ không? Cần giữ endpoint v1 và mở endpoint v2 không?
- **Database Migration:** Dữ liệu cũ đang có trên production cần chuyển đổi thế nào?
  - Ví dụ: Thêm cột `status` NOT NULL → cần script SQL để UPDATE default value cho dữ liệu cũ trước khi chạy constraint `NOT NULL`.

---

## 7. Non-Functional Requirements (Security & Performance)
- **Security & Authorization:**
  - Cơ chế authenticate: JWT / API Key
  - Phân quyền (RBAC): Các Role nào được phép gọi API này?
  - Dữ liệu nhạy cảm cần mã hóa trong DB (ví dụ: Số điện thoại, Email).
- **Performance & Scalability:**
  - Chiến lược Caching: Có dùng Redis cache không? Key format là gì? TTL (Time-to-live) bao lâu?
  - Rate Limiting: Giới hạn bao nhiêu request/phút trên mỗi user/IP?

---

## 8. Module / Layer map
<!-- Với project multi-module: code nằm ở đâu -->
| Layer | Module / File | Trách nhiệm |
|-------|--------------|-------------|
| Controller | {module}/controller/ | Nhận request, validate |
| Service | {module}/service/ | Business logic |
| Repository | {module}/repository/ | Data access |

---

## 9. Technical Open Questions
<!-- Liệt kê những câu hỏi thuần túy kỹ thuật chưa chốt -->
- [ ] ...

---

## 10. Reviewer Checklist
- [ ] Schema đủ field chưa?
- [ ] Index có đủ cho các query pattern không?
- [ ] Error cases có đủ không?
- [ ] Breaking change API không? (nếu có → versioning strategy)
- [ ] Event schema có backward compatible không?
- [ ] Timeout và Retry của External Call đã được cấu hình hợp lý chưa?
- [ ] Cột NOT NULL mới đã có migration script cho dữ liệu lịch sử chưa?
- [ ] Rate limit và Cache TTL đã được thiết kế chưa?

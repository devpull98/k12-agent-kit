---
name: tech-docs
description: Viết tech design document (API contract, DB schema, event definitions) từ BDD spec đã duyệt. Use when BDD spec đã chốt và cần thiết kế kỹ thuật trước khi generate code.
keywords: [tech design, api contract, db schema, technical spec, thiết kế kỹ thuật, endpoint, migration]
not_for: [viết code ngay khi chưa có BDD spec, refactor không cần schema mới]
requires_rules:
  - _global/traceability
  - "{stack}/architecture"
---

# Purpose
Tạo tài liệu thiết kế kỹ thuật làm contract giữa dev và các bên liên quan — định nghĩa API, DB changes, events TRƯỚC KHI code, để mọi người đồng thuận trước rồi mới implement.

# Inputs
- BDD spec đã được duyệt (file `.feature` với UC-ID)
- Codebase hiện tại (để hiểu module structure, entity đã có)
- Stack rules của project (`{stack}/architecture`)

# Steps
1. **Đọc BDD spec**: Xác định tất cả UC-ID + scenarios cần implement.
2. **Thiết kế API** (nếu có HTTP interface):
   - Method + path + description cho từng endpoint
   - Request body / params (với kiểu dữ liệu, required/optional, validation)
   - Response schema (success + error cases)
   - HTTP status codes
   - Authentication requirement
3. **Thiết kế DB changes** (nếu cần):
   - Bảng/collection mới hoặc thay đổi schema
   - Fields, types, indexes
   - Migration approach (forward only, không breaking change nếu có thể)
4. **Thiết kế Events / Messages** (nếu có Kafka/RabbitMQ):
   - Topic name, message schema, producer/consumer
   - Idempotency consideration
5. **Thêm @trace metadata**:
   ```
   # @trace.uc_id: {UC-ID}
   # @trace.bdd_version: 1.0
   ```
6. **Lưu** vào `docs/specs/tech-design/{UC-ID}-tech-design.md`.
7. **Review**: Dev lead hoặc tech lead xem trước khi code.

# Output
- File tech-design với API contract + DB changes + event definitions
- Rõ ràng đến mức dev có thể implement mà không cần hỏi thêm
- Reviewer checklist: schema đủ field chưa, index có đủ chưa, edge case có handle chưa

# Ghi chú
- Không viết code trong tech-design — chỉ viết contract.
- Nếu có thay đổi breaking change API → phải note versioning strategy.
- Sau khi tech-design được duyệt → chuyển sang `tdd` hoặc `bdd-specification` nếu cần bổ sung scenario.

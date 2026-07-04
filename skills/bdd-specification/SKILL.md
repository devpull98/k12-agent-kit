---
name: bdd-specification
description: Viết BDD specification (Given/When/Then scenarios) từ yêu cầu hoặc ticket. Use when có feature mới cần xác định behavior trước khi code, hoặc khi tester cần spec để thiết kế test.
keywords: [bdd, scenario, given when then, acceptance criteria, feature spec, behavior, kịch bản]
not_for: [sửa bug nhỏ rõ ràng, refactor không đổi behavior]
on_success: [tech-docs, qc-automation]
on_failure: [spec-driven-development]
requires_rules:
  - _global/sdd-gate
  - _global/traceability
---

# Purpose
Tạo BDD specification làm nguồn sự thật chung giữa dev và tester — định nghĩa chính xác hệ thống phải làm gì, dưới góc nhìn hành vi người dùng, trước khi viết bất kỳ dòng code hoặc test nào.

# Inputs
- Yêu cầu / ticket / mô tả feature (dù mơ hồ)
- Context hệ thống hiện tại (nếu có)
- Spec hoặc brainstorm đã có (nếu có)

# Steps
1. **Xác định UC-ID**: Theo convention `{DOMAIN}-{NUMBER}` (xem `rules/_global/governance.mdc`). Ví dụ: `LMS-001`, `CLUB-012`, `AUTH-003`. Copy `templates/bdd-template.feature` làm starting point.
2. **Xác định actors**: Ai là người dùng? (student, teacher, admin, system...)
3. **Liệt kê scenarios**: Mỗi scenario = 1 luồng hành vi cụ thể:
   - Happy path (luồng chính thành công)
   - Alternate paths (luồng thành công khác)
   - Error/edge cases (dữ liệu sai, không có quyền, timeout...)
4. **Viết Given/When/Then** cho mỗi scenario:
   - `Given` — trạng thái ban đầu / điều kiện tiên quyết
   - `When` — hành động xảy ra
   - `Then` — kết quả mong đợi (đủ cụ thể để test được)
5. **Thêm @trace metadata** vào đầu file:
   ```
   # @trace.uc_id: {UC-ID}
   # @trace.domain: {domain}
   # @trace.status: draft
   ```
6. **Lưu** vào `docs/specs/bdd/{UC-ID}.feature` (hoặc theo cấu trúc project).
7. **Tạo trace file**: Copy `templates/trace-template.tsv` → `docs/trace/{UC-ID}-trace.tsv`. Điền `sc_id` và `sc_title` theo danh sách scenario vừa viết. Để `implemented_by`, `test_file`, `dev_selftest`, `qc_status` là `-` — dev và tester tự cập nhật sau.
8. **Xin review**: Hỏi dev + tester xem scenario có đủ, có đo được không trước khi chốt.

# Output
- File `.feature` với đầy đủ scenarios + @trace metadata
- Danh sách SC-ID (SC1, SC2...) tương ứng từng scenario để dev và tester tham chiếu
- Open questions nếu có ambiguity chưa giải quyết được

# Ghi chú
- `Then` phải đủ cụ thể để viết assertion: "hệ thống trả về 401" tốt hơn "hệ thống báo lỗi".
- Mỗi scenario chỉ test 1 behavior — không nhét nhiều hành động vào 1 `When`.
- Sau khi chốt BDD spec → chuyển sang `tech-docs` (dev) hoặc `qc-automation` (tester).

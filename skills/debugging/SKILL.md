---
name: reproduce-and-fix-bug
priority: CRITICAL
triggers:
  - IF: Hệ thống có bug, test case bị fail, hoặc crash log xuất hiện trên production.
    THEN: Kích hoạt skill này để sửa lỗi.
requires_rules:
  - _global/error-handling
---

# Problem
Sửa bug mò mẫm không có bằng chứng, làm gãy các tính năng cũ (regression).

# Rules & Knowledge

## 1. Nguyên lý Prove-It (Quy tắc)
*   **IF** Chưa viết được Unit Test hoặc Integration Test mô phỏng lỗi chạy **FAIL**:
    *   **THEN** Nghiêm cấm sửa bất kỳ dòng code logic nào.

## 2. Bản fix tối giản (Quy tắc)
*   **IF** Triển khai code sửa lỗi:
    *   **THEN** Chỉ sửa đúng root cause, không tiện tay refactor phần code không liên quan.

## Bad vs Good
*   **Bad (Sửa code chay không test, sửa lan man gây lỗi hồi quy):**
    Sửa trực tiếp hàm logic, đoán do biến Null rồi deploy thử lên staging kiểm tra.
*   **Good (Prove-It Pattern):**
    1. Viết test case `testUserTrophyNull()` -> Run -> **FAIL**.
    2. Sửa đúng dòng NPE trong class cần fix.
    3. Run test case -> **PASS**. Run full test suite -> **PASS**.

# Checklist
- [ ] Viết test tái hiện lỗi thành công (phải chạy FAIL trước khi sửa code).
- [ ] Xác định nguyên nhân gốc rễ (file:line) và ghi vào report.
- [ ] Chạy lại toàn bộ test suite để đảm bảo không gãy tính năng cũ.

# Output Expectation
- 1 file test mới hoặc test case mới verify lỗi đã được sửa.
- Báo cáo ngắn gọn: Triệu chứng (Symptom) -> Nguyên nhân (Root Cause) -> Bản vá (Fix).

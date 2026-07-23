---
name: review-code-pr
priority: MEDIUM
triggers:
  - IF: Lập trình viên chuẩn bị đẩy mã nguồn hoặc gửi Pull Request (PR) yêu cầu review.
    THEN: Kích hoạt skill này để đánh giá chất lượng.
requires_rules:
  - _global/security-baseline
  - _global/observability
  - _global/performance-baseline
  - _global/error-handling
---

# Problem
Review hời hợt bỏ lọt lỗi bảo mật, code bẩn, hoặc lỗi logic nghiêm trọng lên nhánh chính.

# Rules & Knowledge

## 1. Gác cổng an toàn (Quy tắc)
*   **IF** Nhánh code chưa chạy thành công toàn bộ test suite (`dev_selftest` chưa pass):
    *   **THEN** Từ chối duyệt (REJECT) PR ngay lập tức.
*   **IF** Phát hiện vi phạm quy tắc toàn cục (như N+1 query, unboxing không an toàn, log/secret bị lộ):
    *   **THEN** Yêu cầu sửa đổi và chỉ ra file:line vi phạm.

## Bad vs Good
*   **Bad (Review chung chung):**
    "Code trông ổn, đã merge." -> Bỏ lọt lỗi null unboxing gây crash job tuần sau.
*   **Good (Review chi tiết, chỉ ra lỗi cụ thể kèm luật đối chiếu):**
    "Yêu cầu sửa đổi tại `CourseService.java#L45`: Đang unbox `totalScore` kiểu `Integer` sang `int` trực tiếp. Cần thêm null check để tránh NPE (vi phạm `rules/_global/error-handling.mdc`)."

# Checklist
- [ ] Kiểm tra trạng thái build và test suite của PR.
- [ ] Quét diff để kiểm tra lỗi bảo mật (hardcoded secrets).
- [ ] Đối chiếu với các quy tắc performance-baseline và error-handling.

# Output Expectation
- PR Review Report chỉ rõ: Trạng thái (Approved / Change Requested) kèm danh sách lỗi chi tiết theo dòng code (file:line).

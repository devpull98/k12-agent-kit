---
name: code-review
description: Review code qua 2 tầng (spec compliance → 5 trục chất lượng) trước khi merge, kèm quy trình request/receive review. Use when sắp merge PR, hoàn thành 1 task/feature, hoặc nhận feedback review cần phản hồi.
keywords: [review, pull request, pr, code review, merge, feedback]
on_success: [trace-validation]
on_failure: [tdd]
priority: MEDIUM
triggers:
  - IF: Lập trình viên chuẩn bị đẩy mã nguồn hoặc gửi Pull Request (PR) yêu cầu review.
    THEN: Kích hoạt skill này để đánh giá chất lượng.
requires_rules:
  - _global/security-baseline
  - _global/observability
  - _global/performance-baseline
  - _global/caching
  - _global/error-handling
  - _global/solid
  - _global/clean-code
  - "{stack}/architecture"
---

# Problem
Review hời hợt bỏ lọt lỗi bảo mật, code bẩn, hoặc lỗi logic nghiêm trọng lên nhánh chính.

# Rules & Knowledge

## 1. Hai tầng — spec trước, chất lượng sau (Quy tắc)
*   **IF** Bắt đầu review:
    *   **THEN** Đọc spec/task (BDD scenario, acceptance criteria) rồi đọc **test trước code**.
*   **IF** Tầng 1 — Spec compliance: diff thiếu behavior của scenario/AC:
    *   **THEN** Critical (block merge). Làm thừa ngoài scope (over-build) → Required (bỏ). **Chưa đạt tầng 1 thì không review chất lượng.**
*   **IF** Tầng 2 — Code quality:
    *   **THEN** Đánh giá 5 trục: Correctness (edge case, error path) · Readability · Architecture (pattern hiện có, ranh giới module) · Security (`security-baseline`) · Performance (N+1, unbounded fetch).

## 2. Gác cổng an toàn (Quy tắc)
*   **IF** Nhánh code chưa chạy thành công toàn bộ test suite (`dev_selftest` chưa pass):
    *   **THEN** Từ chối duyệt (REJECT) PR ngay lập tức.
*   **IF** Sắp Approve:
    *   **THEN** Tự chạy test/build trên head (`verification-before-completion`) — không approve dựa vào "CI chắc xanh" hay report của tác giả.
*   **IF** Phát hiện vi phạm quy tắc toàn cục (như N+1 query, unboxing không an toàn, log/secret bị lộ, God service, use case `new` infra):
    *   **THEN** Yêu cầu sửa đổi và chỉ ra file:line + rule (`_global/solid.mdc` / `_global/clean-code.mdc` / `{stack}/architecture`).

## 3. Severity & phản hồi (Quy tắc)
*   **IF** Ghi finding:
    *   **THEN** Gắn severity: Critical (block) / Required / Nit / Optional / FYI — không để tất cả thành "bắt buộc". Thay đổi cải thiện codebase dù chưa hoàn hảo → Approve, không block vì khác gu.
*   **IF** Nhận review (receiving):
    *   **THEN** Đọc hết, diễn giải lại bằng lời mình, verify với code thật trước khi sửa; feedback sai kỹ thuật → phản biện có lý do, không đồng ý hình thức.
*   **IF** Gửi yêu cầu review (requesting):
    *   **THEN** Kèm mô tả ngắn, plan/requirement gốc, base/head SHA — không kèm toàn bộ lịch sử session.

## Bad vs Good
*   **Bad (Review chung chung):**
    "Code trông ổn, đã merge." -> Bỏ lọt lỗi null unboxing gây crash job tuần sau.
*   **Good (Review chi tiết, chỉ ra lỗi cụ thể kèm luật đối chiếu):**
    "Yêu cầu sửa đổi tại `CourseService.java#L45`: Đang unbox `totalScore` kiểu `Integer` sang `int` trực tiếp. Cần thêm null check để tránh NPE (vi phạm `rules/_global/error-handling.mdc`)."

# Checklist
- [ ] Kiểm tra trạng thái build và test suite của PR.
- [ ] Quét diff để kiểm tra lỗi bảo mật (hardcoded secrets).
- [ ] Đối chiếu performance-baseline, error-handling, **SOLID**, **clean-code** (tên/hàm/nest/magic trên **diff**, không audit cả repo).

# Output Expectation
- PR Review Report chỉ rõ: Trạng thái (Approved / Change Requested) kèm danh sách lỗi chi tiết theo dòng code (file:line).

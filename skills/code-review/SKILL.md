---
name: code-review
description: Review code qua 5 trục (correctness, readability, architecture, security, performance) trước khi merge, kèm quy trình request/receive review rõ ràng. Use when sắp merge PR, hoàn thành 1 task/feature, hoặc nhận feedback review cần phản hồi.
keywords: [review, pull request, pr, code review, merge, feedback]
not_for: []
requires_rules:
  - _global/security-baseline
  - _global/observability
---

# Purpose
Đảm bảo mọi thay đổi được đánh giá đa chiều trước khi vào main, và feedback review được xử lý bằng kỹ thuật chứ không bằng đồng ý hình thức.

# Inputs
- Diff/PR cần review (hoặc code mới hoàn thành)
- Spec/task gốc làm chuẩn đối chiếu

# Steps
1. Đọc spec/task trước để hiểu mục tiêu thay đổi.
2. Đọc test trước code — test thể hiện intent và coverage thật.
3. Đánh giá theo 5 trục: Correctness (đúng spec, edge case, error path), Readability (đặt tên, độ phức tạp), Architecture (theo pattern hiện có, không lặp code, ranh giới module), Security (theo rule security-baseline), Performance (N+1, unbounded fetch, pagination).
4. Gắn severity rõ ràng cho mỗi finding: Critical (block merge) / Required / Nit / Optional / FYI — không để tất cả thành "bắt buộc".
5. Khi đề xuất review (requesting): cung cấp mô tả ngắn, plan/requirement gốc, base/head SHA hoặc diff cụ thể — không kèm toàn bộ lịch sử session.
6. Khi nhận review (receiving): đọc hết feedback trước khi phản hồi, diễn giải lại yêu cầu bằng lời mình, verify với codebase thật trước khi sửa — không đồng ý hình thức ("bạn đúng rồi!"), không sửa mù theo feedback sai.
7. Nếu feedback không rõ hoặc có vẻ sai kỹ thuật: hỏi lại hoặc phản biện có lý do kỹ thuật, không im lặng làm theo.
8. Approve khi thay đổi rõ ràng cải thiện codebase, dù chưa hoàn hảo — không block vì khác gu cá nhân.

# Output
- Review verdict: Approve / Request changes, kèm finding theo severity
- Mọi Critical/Required đã được xử lý hoặc giải thích lý do defer

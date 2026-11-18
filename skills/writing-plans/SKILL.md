---
name: writing-plans
description: Phân rã spec thành task nhỏ, có thứ tự, có acceptance criteria và verification step. Use when đã có spec/requirement rõ và cần lập task breakdown trước khi code, hoặc task cảm thấy quá lớn để bắt đầu.
keywords: [plan, task breakdown, dependency graph, vertical slice, estimate]
not_for: [thay đổi 1 file phạm vi rõ ràng]
on_success: [spec-analyze]
on_skip: [executing-plans]
on_failure: [bdd-specification, tech-docs]
requires_rules:
  - _global/sdd-gate
---

# Purpose
Chuyển spec thành plan thực thi được: task nhỏ, có thứ tự theo dependency, mỗi task tự kiểm chứng được — để TDD/implementation chạy mượt, không đoán.

# Inputs
- Work package `_context.md` của task (`docs/work/<KEY>-<slug>/_context.md`) — entry point
- BDD spec đã duyệt (`docs/specs/bdd/{UC-ID}.feature`) — standard track
- Tech design đã review (nếu có API/DB change)
- Product Brief (nếu có) từ spec-driven-development
- Codebase hiện tại (pattern, convention đang dùng)

# Steps
1. Đọc spec ở chế độ read-only; map dependency graph giữa các phần (DB → API → UI...).
2. Cắt theo vertical slice (một luồng hoàn chỉnh end-to-end mỗi task), tránh cắt theo layer ngang.
3. **Principles check (gate)**: đối chiếu `docs/principles.md` — điền mục *Principles Check* trong plan. Vi phạm MUST mà không có lý do ghi trong *Complexity Tracking* → dừng, quay `tech-docs`/`brainstorming`.
4. Copy `templates/plan-template.md`; với mỗi task điền:
   - **ID** `T001`, `T002`… (ổn định, không đánh số lại khi chèn — dùng `T002a`).
   - Marker **`[P]`** nếu chạy song song được (khác file, không phụ thuộc task chưa xong).
   - **`Covers:`** FR/SC mà task hiện thực (`FR-002, SC3`) — để `spec-analyze` tính coverage.
   - File đụng tới với **path chính xác**, acceptance criteria đo được, lệnh **Verification** + output kỳ vọng.
   - Các bước nhỏ 2–5 phút theo nhịp TDD: viết test fail → chạy thấy fail → code tối thiểu → chạy thấy pass → commit. Viết cho người "không biết gì về codebase": nêu rõ tên hàm/type/signature, không viết "xử lý tương tự task trên".
5. Giới hạn quy mô: 1 task không đụng quá ~5 file; nếu lớn hơn, cắt nhỏ tiếp. Bám YAGNI/DRY — không task "chuẩn bị cho tương lai".
6. Sắp thứ tự task theo dependency, chèn checkpoint sau mỗi 2-3 task (tests pass + build sạch).
7. Tự rà soát plan: mọi FR/SC có task `Covers:` tương ứng, không còn placeholder ("TBD", "implement later", "thêm error handling phù hợp"), tên hàm/biến nhất quán giữa các task.
8. Lưu vào work package: `docs/work/<KEY>-<slug>/plan.md` + `checklist.md`; tick trạng thái trong `_context.md`. Xin user duyệt, rồi chuyển `spec-analyze` (standard) hoặc thẳng `executing-plans` (fast — on_skip).

# Output
- File plan đã commit, có task list theo thứ tự, mỗi task có acceptance criteria + verification step
- Checkpoint rõ ràng giữa các phase

---
name: writing-plans
description: Phân rã spec thành task nhỏ, có thứ tự, có acceptance criteria và verification step. Use when đã có spec/requirement rõ và cần lập task breakdown trước khi code, hoặc task cảm thấy quá lớn để bắt đầu.
keywords: [plan, task breakdown, dependency graph, vertical slice, estimate]
not_for: [thay đổi 1 file phạm vi rõ ràng]
on_success: [tdd]
on_failure: [bdd-specification, tech-docs]
requires_rules:
  - _global/sdd-gate
---

# Purpose
Chuyển spec thành plan thực thi được: task nhỏ, có thứ tự theo dependency, mỗi task tự kiểm chứng được — để TDD/implementation chạy mượt, không đoán.

# Inputs
- BDD spec đã duyệt (`docs/specs/bdd/{UC-ID}.feature`) — standard track
- Tech design đã review (nếu có API/DB change)
- Product Brief (nếu có) từ spec-driven-development
- Codebase hiện tại (pattern, convention đang dùng)

# Steps
1. Đọc spec ở chế độ read-only; map dependency graph giữa các phần (DB → API → UI...).
2. Cắt theo vertical slice (một luồng hoàn chỉnh end-to-end mỗi task), tránh cắt theo layer ngang.
3. Copy `templates/plan-template.md`; với mỗi task điền: mô tả ngắn, acceptance criteria (checklist cụ thể, đo được), verification step (lệnh test/build/manual check), file dự kiến đụng tới, dependency.
4. Giới hạn quy mô: 1 task không đụng quá ~5 file; nếu lớn hơn, cắt nhỏ tiếp.
5. Sắp thứ tự task theo dependency, chèn checkpoint sau mỗi 2-3 task (tests pass + build sạch).
6. Tự rà soát plan: mọi phần spec có task tương ứng chưa, không còn placeholder ("TBD", "implement later"), tên hàm/biến nhất quán giữa các task.
7. Lưu plan vào file (`docs/plans/YYYY-MM-DD-<feature>.md`), xin user duyệt trước khi chuyển sang tdd.

# Output
- File plan đã commit, có task list theo thứ tự, mỗi task có acceptance criteria + verification step
- Checkpoint rõ ràng giữa các phase

---
name: writing-plans
description: Phân rã spec thành task nhỏ, có thứ tự, có acceptance criteria và verification step. Use when đã có spec/requirement rõ và cần lập task breakdown trước khi code, hoặc task cảm thấy quá lớn để bắt đầu.
keywords: [plan, task breakdown, dependency graph, vertical slice, estimate]
not_for: [thay đổi 1 file phạm vi rõ ràng]
on_success: [tdd]
on_failure: [bdd-specification, tech-docs]
requires_rules:
  - _global/sdd-gate
  - _global/doc-scoping
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
3. Copy `templates/plan-template.md`. Điền **bắt buộc**:
   - `## Non-goals / Restrictions` — việc cấm trong đợt này (bảng).
   - `## Trade-offs` — quyết định chọn/bỏ + why (bảng; có thể 1–3 hàng).
   - `## Task Matrix` — mỗi hàng: Task ID · Component · Status · **Verification (lệnh copy-run)** · relative links tới code/spec.
   - Task details slim (≤6 dòng/task): Files (markdown links), Dep, AC, Verify (trùng Matrix), Rollback.
4. Giới hạn quy mô: 1 task không đụng quá ~5 file; nếu lớn hơn, cắt nhỏ tiếp.
5. Sắp thứ tự task theo dependency; mixed mode → ASCII/Mermaid ngắn (không 3–4 đoạn văn).
6. Tự rà: mọi phần spec có task tương ứng; không placeholder ("TBD"); mọi task có Verify cmd cụ thể (vd. `mvn -pl :mod test -Dtest=FooTest`, `npm test -- path`); Non-goals không trùng scope đang làm.
7. Lưu `docs/work/<KEY>-<slug>/plan.md` + `checklist.md`; patch Constraints (≤5 hàng) + YAML state trong `_context.md` (không copy spec). Xin user duyệt trước khi chuyển sang tdd.
8. Plan là artifact **cố định**: session sau chỉ đổi Status / tick AC. Cần đổi scope → replan có chủ đích, không “tổng hợp lại” sau mỗi task.

# Output
- `plan.md` có Non-goals + Trade-offs + Task Matrix; mỗi task có Verification copy-run được
- Checkpoint rõ giữa các phase (mixed)
- `_context.md` vẫn là index (≤ 90 dòng), có Constraints mirror Non-goals chính

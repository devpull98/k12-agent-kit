---
name: spec-driven-development
description: Viết feature Product Brief (scope, boundaries, success criteria) trước BDD. Use when bắt đầu feature mới standard track, requirement chưa rõ, hoặc task tốn hơn 30 phút implement.
keywords: [spec, requirement, acceptance criteria, specify, success criteria]
not_for: [sửa lỗi 1 dòng, task tự mô tả rõ scope]
on_success: [bdd-specification]
on_skip: [writing-plans]
on_failure: [brainstorming]
requires_rules:
  - _global/sdd-gate
  - "{stack}/architecture"
---

# Purpose
Tạo **feature Product Brief** (lớp spec 1/3): định nghĩa cái gì được xây, vì sao, boundaries, và biết khi nào "done" — trước BDD và code. Không thay thế BDD (behavior) hay tech-docs (technical contract).

# Inputs
- Thiết kế đã chốt từ brainstorming (nếu có)
- Codebase/dependency file hiện tại (để xác định stack, version)

# Steps
1. Nêu rõ giả định đang đưa ra (assumptions) trước khi viết spec — không tự điền ngầm yêu cầu mơ hồ.
2. Copy `templates/spec-template.md`, điền đầy đủ các mục (Objective, Tech stack/commands, Project structure, Code style, Testing strategy, Boundaries, Success criteria, Open questions). Nếu project chưa có `docs/principles.md`, copy `templates/principles-template.md` và điền MUST/MUST NOT riêng của project.
3. Quy đổi yêu cầu mơ hồ ("nhanh hơn", "tốt hơn") thành success criteria cụ thể, đo được.
4. Lưu spec vào file trong repo (ví dụ `docs/specs/YYYY-MM-DD-<feature>.md`), commit.
5. Xin user review và duyệt spec trước khi sang bước Plan/Tasks.
6. Sau khi Product Brief được duyệt, chuyển sang **bdd-specification** (standard track) hoặc writing-plans (fast track).
7. Coi spec là tài liệu sống: khi quyết định/scope đổi, sửa spec trước, rồi mới sửa code.

# Output
- File spec đã commit, được user duyệt
- Danh sách giả định đã chốt + success criteria cụ thể, đo được
- Boundaries rõ ràng (Always/Ask first/Never) cho phần còn lại của task

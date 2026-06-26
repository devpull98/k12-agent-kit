---
name: spec-driven-development
description: Viết spec có cấu trúc trước khi code, qua quy trình gated Specify -> Plan -> Tasks -> Implement. Use when bắt đầu project/feature mới, requirement chưa rõ, hoặc task tốn hơn 30 phút implement.
keywords: [spec, requirement, acceptance criteria, specify, success criteria]
not_for: [sửa lỗi 1 dòng, task tự mô tả rõ scope]
requires_rules:
  - _global/sdd-gate
  - "{stack}/architecture"
---

# Purpose
Đảm bảo có một spec là nguồn sự thật chung giữa user và agent: định nghĩa cái gì được xây, vì sao, và biết khi nào "done" — trước khi viết bất kỳ dòng code nào.

# Inputs
- Thiết kế đã chốt từ brainstorming (nếu có)
- Codebase/dependency file hiện tại (để xác định stack, version)

# Steps
1. Nêu rõ giả định đang đưa ra (assumptions) trước khi viết spec — không tự điền ngầm yêu cầu mơ hồ.
2. Copy `templates/spec-template.md`, điền đầy đủ các mục (Objective, Tech stack/commands, Project structure, Code style, Testing strategy, Boundaries, Success criteria, Open questions).
3. Quy đổi yêu cầu mơ hồ ("nhanh hơn", "tốt hơn") thành success criteria cụ thể, đo được.
4. Lưu spec vào file trong repo (ví dụ `docs/specs/YYYY-MM-DD-<feature>.md`), commit.
5. Xin user review và duyệt spec trước khi sang bước Plan/Tasks.
6. Sau khi spec được duyệt, chuyển sang writing-plans để lập task breakdown.
7. Coi spec là tài liệu sống: khi quyết định/scope đổi, sửa spec trước, rồi mới sửa code.

# Output
- File spec đã commit, được user duyệt
- Danh sách giả định đã chốt + success criteria cụ thể, đo được
- Boundaries rõ ràng (Always/Ask first/Never) cho phần còn lại của task

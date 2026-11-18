---
name: writing-skills
description: Viết hoặc sửa skill/rule của kit đúng contract (frontmatter, on_success/on_failure, requires_rules, router) và kiểm bằng pressure test trước khi ship. Use when thêm skill mới, sửa skill hiện có, thêm stack rule, hoặc agent liên tục bỏ qua 1 skill.
keywords: [writing skills, viết skill, tạo skill, sửa skill, new skill, skill authoring, thêm skill]
not_for: [viết convention project cụ thể — để vào docs/principles.md hoặc rules/_examples/]
requires_rules:
  - _global/governance
on_success: [code-review]
on_failure: []
---

# Purpose
Skill là **code cho hành vi agent**: phải có test (pressure scenario) và phải pass gate (`validate-skill-graph.sh`). Viết skill mà không test = ship code không chạy thử.

# Contract bắt buộc
```yaml
---
name: <trùng tên folder>             # validate-skill-graph kiểm
description: <làm gì>. Use when <trigger cụ thể>.   # description quyết định skill có được gọi không
keywords: [...]                       # khớp router.yaml
not_for: [...]                        # ranh giới với skill lân cận
requires_rules: [_global/x, "{stack}/architecture"]  # KHÔNG hardcode convention trong skill
on_success: [code-review]             # skill kế — phải tồn tại (validate-skill-graph kiểm)
on_failure: [debugging]               # skill quay về khi fail
---
# Purpose · # Inputs · # Steps · # Output
```
- Skill = HOW (quy trình). Convention = rule (`rules/`). Thứ tự flow = `workflows/canonical-flow.md`. Không trộn.
- Skill rigid (tdd, debugging, verification) cần **bảng rationalization** ("suy nghĩ → thực tế") và **red flags**.

# Steps (TDD cho skill)
1. **RED — baseline**: viết 2–3 pressure scenario (áp lực thời gian, sunk cost, "user bảo nhanh lên") mà agent hiện tại làm SAI khi chưa có skill. Ghi lại nguyên văn lý do agent tự biện hộ.
2. **GREEN**: viết skill tối thiểu chặn đúng các lý do đó (đưa nguyên văn vào bảng rationalization).
3. **REFACTOR**: chạy lại scenario; agent tìm được kẽ hở mới → bịt, lặp tới khi tuân thủ.
4. Đăng ký: thêm route vào `router.yaml` (keywords + `not_for_skills`), cập nhật `on_success` của skill đứng trước, bảng trong `skills/next-step/SKILL.md`, và `workflows/canonical-flow.md` nếu đổi flow.
5. Gate: `bash scripts/validate-skill-graph.sh` phải PASS. Ghi `CHANGELOG.md` (Unreleased), bump `version` trong `.claude-plugin/plugin.json` khi release.
6. Nhắc user: skill mới chỉ load ở **session mới**.

# Output
- `skills/<name>/SKILL.md` đúng contract, đã pressure-test (ghi scenario vào PR description)
- Router + next-step + canonical-flow đồng bộ; `validate-skill-graph.sh` PASS

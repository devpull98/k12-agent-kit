---
name: feature
---

# Feature Flow — Track-aware navigation

> **Canonical source:** `workflows/canonical-flow.md` — đọc file đó nếu mơ hồ bước tiếp theo.

## Track selection
- **Standard**: business logic / API / DB / thay đổi lớn
- **Fast**: copy, config, UI fix nhỏ (< 30 phút)
- **Hotfix**: production incident

## Flow (standard)
product-discovery → brainstorming → spec-driven-development → bdd-specification → tech-docs → writing-plans → (tdd → log)×n → review → qc → trace → ship

## Flow (fast)
brainstorming → writing-plans → tdd → review → trace → ship  `[fast-track]`

## Flow (hotfix)
bug-flow → debugging/tdd (repro & sửa lỗi) → review → qc → trace → ship  `[hotfix]`

## Steps & gates
| Step | Skill | Gate? | On fail → |
|------|-------|-------|-----------|
| discovery | product-discovery | — | — |
| brainstorm | brainstorming | scope + success criteria rõ | refine yêu cầu |
| Product Brief | spec-driven-development | Product Brief approved | brainstorm |
| bdd | bdd-specification | BDD approved | Product Brief |
| tech | tech-docs | design reviewed (nếu có API/DB) | bdd |
| plan | writing-plans | task breakdown hợp lệ | bdd/tech |
| tdd | tdd | test pass | plan |
| log | progress-logging | — (sau mỗi task pass) | — |
| review | code-review | no Critical/Major | tdd |
| qc | qc-automation | `qc_status` pass | bug-flow |
| trace | trace-validation | no GAP blocker | tdd/review |
| ship | shipping | release checklist pass | review |

## Rule vận hành
- Agent **nhắc** user chạy `./scripts/governance-check.sh` trước khi merge (user tự chạy, agent không tự chạy script).
- Chỉ merge khi `dev_selftest` + `qc_status` đều pass và governance scripts pass.

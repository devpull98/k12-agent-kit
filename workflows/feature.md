---
name: feature
---

# Feature Flow — Track-aware navigation

## Track selection
- **Standard**: feature có business logic/API/DB hoặc thay đổi lớn.
- **Fast**: thay đổi nhỏ (copy, config, UI fix) với scope rõ và rủi ro thấp.
- **Hotfix**: incident production, cần fix nhanh có kiểm soát rollback.

## Flow (standard)
brainstorm → spec → plan → (tdd → log)×n task → review → qc → trace → ship

## Flow (fast)
brainstorm (nhanh) → plan (rút gọn) → tdd → review → trace → ship

## Flow (hotfix)
bug-flow (classify) → debugging/tdd (repro first) → review → qc (focused re-run) → trace → ship

## Steps & gates
| Step | Skill | Gate? | On fail → |
|------|-------|-------|-----------|
| brainstorm | brainstorming | scope + success criteria rõ | refine yêu cầu |
| spec | spec-driven-development | BDD/spec đủ rõ để implement | brainstorm |
| plan | writing-plans | task breakdown hợp lệ, dependency rõ | spec |
| tdd | tdd | test pass và bám scenario | plan |
| log | progress-logging | không phải gate (chạy sau mỗi task pass) | — |
| review | code-review | không còn Critical/Major blocker | tdd |
| qc | qc-automation / bug-flow | `qc_status` pass hoặc issue được route | bug-flow |
| trace | trace-validation | không GAP blocker | tdd/review |
| ship | shipping | release checklist pass | review |

## Rule vận hành
- `log` luôn chạy sau mỗi task pass để giữ audit trail rõ.
- Fail ở gate nào quay lại step gần nhất xử lý được nguyên nhân gốc.
- Chỉ merge khi cả `dev_selftest` và `qc_status` đều pass.

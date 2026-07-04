---
name: dev-flow
role: developer
---

# Dev Flow — Feature Development

## Flow
ticket/yêu cầu → chọn track → bdd-specification → tech-docs → tdd → [log]×n → code-review → trace-validation → shipping

## Track selection
- **Standard**: mặc định cho feature có logic/API/DB.
- **Fast**: task nhỏ, scope rõ, không đổi behavior chính.
- **Hotfix**: production bug; phải có test tái hiện trước khi fix.

## Steps

| Step | Skill | Gate? | On fail |
|------|-------|-------|---------|
| bdd-specification | bdd-specification | ✓ phải được duyệt | — |
| tech-docs | tech-docs | ✓ phải được review | bdd-specification |
| tdd | tdd | ✓ test pass | tech-docs |
| log | progress-logging | — (sau mỗi task pass) | — |
| review | code-review | ✓ không còn Critical/Major | tdd |
| trace | trace-validation | ✓ không GAP blocker | tdd/review |
| ship | shipping | ✓ release checklist pass | review |

## Quy tắc gate
- **bdd-specification phải có trước khi mở file code** — SDD gate (xem `_global/sdd-gate`).
- Task < 30 phút và scope rõ → có thể skip bdd-specification, đi thẳng tdd.
- **tech-docs phải có trước khi generate code** cho feature có API mới hoặc DB change.
- **trace-validation** chạy trước merge — không merge nếu có GAP.
- **dev_selftest** phải pass trước khi chuyển sang QC.

## Với bug fix
ticket bug → bug-flow (classify) → debugging hoặc tdd → code-review → shipping

## Feedback loop enterprise
- Nếu QC fail hoặc có bug report, dev quay lại `bug-flow` để classify trước khi fix.
- Sau fix bắt buộc re-run test liên quan + trace-validation.
- Hotfix vẫn phải có rollback note trong bước shipping.

## Dev artifacts cần tạo
- `docs/specs/bdd/{UC-ID}.feature` (từ bdd-specification)
- `docs/specs/tech-design/{UC-ID}-tech-design.md` (từ tech-docs)
- Code files với `@trace.implements: {UC-ID}-SC{N}`
- Test files với `@trace.verifies: {UC-ID}-SC{N}`
- `docs/logs/{date}-{feature}.md` (từ progress-logging)

---
name: dev-flow
role: developer
---

# Dev Flow — Feature Development

> **Canonical source:** `workflows/canonical-flow.md`

## Flow
ticket → chọn track → [Product Brief → bdd → tech-docs] → writing-plans → tdd → [log]×n → code-review → trace-validation → shipping

(Pha trong `[ ]` bắt buộc với standard track; bỏ qua với fast/hotfix theo canonical-flow.)

## Steps

| Step | Skill | Gate? | On fail |
|------|-------|-------|---------|
| Product Brief | spec-driven-development | ✓ (standard) | brainstorming |
| bdd-specification | bdd-specification | ✓ phải được duyệt | Product Brief |
| tech-docs | tech-docs | ✓ nếu có API/DB mới | bdd-specification |
| writing-plans | writing-plans | ✓ plan hợp lệ | bdd/tech-docs |
| tdd | tdd | ✓ test pass | plan |
| log | progress-logging | — | — |
| review | code-review | ✓ no Critical/Major | tdd |
| trace | trace-validation | ✓ no GAP blocker | tdd/review |
| ship | shipping | ✓ release checklist | review |

## Quy tắc gate
- **BDD phải có trước khi mở file code** (standard) — SDD gate + `scripts/validate-sdd-gate.sh`
- **tech-docs** trước code khi có API mới hoặc DB change
- **trace-validation** + `scripts/validate-trace.sh` trước merge
- **dev_selftest** pass trước khi chuyển QC

## Bug fix
ticket bug → bug-flow → debugging/tdd (repro & sửa lỗi) → code-review → shipping

## Dev artifacts
- `docs/specs/{date}-{feature}.md` (Product Brief)
- `docs/specs/bdd/{UC-ID}.feature`
- `docs/specs/tech-design/{UC-ID}-tech-design.md`
- `docs/plans/{date}-{feature}.md`
- Code: `@trace.implements: {UC-ID}-SC{N}`
- Test: `@trace.verifies: {UC-ID}-SC{N}`

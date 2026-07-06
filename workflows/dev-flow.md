---
name: dev-flow
role: developer
---

# Dev Flow — góc nhìn Developer

> **Canonical source:** `workflows/canonical-flow.md` — flow, gates và Failure Recovery Map ở đó. File này chỉ nêu phần Dev chịu trách nhiệm.

## Dev sở hữu phase nào
Từ `canonical-flow.md`: `tech-docs → writing-plans → (tdd → progress-logging)×n → code-review` + cập nhật `dev_selftest`.

## Gate Dev bắt buộc tuân
- **BDD phải có trước khi mở file code** (standard) — SDD gate, `scripts/validate-sdd-gate.sh`.
- **tech-docs** trước code khi có API mới / DB change.
- **`dev_selftest: pass`** trước khi bàn giao QC.
- **trace-validation** (`scripts/validate-trace.sh`) không còn GAP trước merge.

## Dev artifacts
- Spec (stable): `docs/specs/modules/<module>/<spec>.md` · `docs/specs/bdd/{UC-ID}.feature` · `docs/specs/tech-design/{UC-ID}-tech-design.md`
- Execution (per task): `docs/work/<KEY>-<slug>/{_context,plan,checklist,note}.md`
- Trace tags: code `@trace.implements: {UC-ID}-SC{N}` · test `@trace.verifies: {UC-ID}-SC{N}`

Bug fix: theo hotfix/bug track trong `canonical-flow.md` (`bug-flow → debugging/tdd → …`).

---
name: qc-flow
role: tester
---

# QC Flow — Quality Control Pipeline

> **Canonical source:** `workflows/canonical-flow.md`

## Flow
BDD approved + dev_selftest pass → qc-automation (6 bước) → [bug-flow] → trace-validation → governance-check → merge-ready

## Steps

| Step | Skill | Gate? | On fail |
|------|-------|-------|---------|
| analyze | qc-automation (1-2) | ✓ no DOC_GAPS | Clarify spec |
| design test | qc-automation (3-4) | ✓ reviewer approve | analyze |
| run | qc-automation (5) | ✓ all pass | bug-flow |
| report | qc-automation (6) | — | — |
| trace | trace-validation + validate-trace.sh | ✓ no GAP | Báo dev |
| governance | scripts/governance-check.sh | ✓ pass | Block merge |

## Điều kiện bắt đầu QC
- BDD spec `@trace.status: approved`
- `dev_selftest: pass`
- `rules/{stack}/test-patterns.mdc` tồn tại

## Hai signal độc lập
- `dev_selftest` — dev
- `qc_status` — tester
- **Cả hai pass trước merge**

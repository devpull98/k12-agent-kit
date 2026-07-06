---
name: enterprise-flow
role: all
---

# Enterprise Flow — Ownership & Definition of Done

> **Canonical source:** `workflows/canonical-flow.md` — flow, tracks (standard/fast/hotfix), gates và Failure Recovery Map ở đó (single source). File này chỉ bổ sung **ai sở hữu phase nào** + **bar merge**.

## Phase → Owner (ai chịu trách nhiệm)
| Phase | Owner | Skill |
|------|-------|-------|
| 0. Align context | Tech Lead/PO | product-discovery, brainstorming |
| 1. Product Brief | PO + Dev | spec-driven-development |
| 2. Behavior spec | PO + Dev | bdd-specification |
| 3. Technical design | Dev/Lead | tech-docs |
| 4. Task planning | Dev | writing-plans |
| 5. Implement (TDD) | Dev | tdd |
| 6. Dev self-check | Dev | tdd → `dev_selftest: pass` |
| 7. QC automation | Tester | qc-automation → `qc_status: pass` |
| 8. Trace + Release | Lead | trace-validation, shipping |

(Gate của từng phase + đường quay lui khi fail: xem canonical-flow.md.)

## Definition of Done (bar merge)
- `bash scripts/governance-check.sh` pass
- `dev_selftest` **và** `qc_status` pass
- Không Critical/Major ở code-review / security-review
- Artifacts đủ: BDD, tech-design (nếu có), test plan, bug report (nếu có)

---
name: enterprise-flow
role: all
---

# Enterprise Flow — Multi-Agent Delivery Lifecycle

> **Canonical source:** `workflows/canonical-flow.md`

## Mục tiêu
- Chuẩn hóa flow dùng chung cho Tech Lead/PO, Dev, Tester và AI agent.
- Spec pipeline 3 lớp: Product Brief → BDD → Tech Design.
- Governance runtime enforce gate (`scripts/governance-check.sh`).

## Delivery tracks
| Track | Khi dùng | Bắt buộc | Có thể bỏ qua |
|------|----------|----------|---------------|
| Standard | Feature logic/API/DB | Product Brief + BDD + Tech + TDD + QC + Trace | Không |
| Fast | UI copy/config/typo < 30 phút | TDD + Review + Trace tối thiểu | Product Brief/BDD/Tech |
| Hotfix | Production incident | bug-flow + repro test + rollback | Discovery dài |

## Lifecycle 9 phases
| Phase | Owner | Skill | Gate |
|------|-------|-------|------|
| 0. Align context | Tech Lead/PO | product-discovery, brainstorming | Scope rõ |
| 1. Product Brief | PO + Dev | spec-driven-development | Product Brief approved |
| 2. Behavior spec | PO + Dev | bdd-specification | BDD approved |
| 3. Technical design | Dev/Lead | tech-docs | Design reviewed |
| 4. Task planning | Dev | writing-plans | Plan hợp lệ |
| 5. Implement (TDD) | Dev | tdd | Test pass + @trace.implements |
| 6. Dev self-check | Dev | tdd | dev_selftest: pass |
| 7. QC automation | Tester | qc-automation | qc_status: pass |
| 8. Trace + Release | Lead | trace-validation, shipping | governance-check pass |

## Failure loop
1. Fail ở phase nào → quay phase gần nhất sửa nguyên nhân gốc.
2. QC fail → `bug-flow` → fix → re-run từ bước Run của qc-automation.
3. Governance script fail → không merge cho đến khi pass hoặc Tech Lead approve exception trong PR.

## Definition of Done
- `bash scripts/governance-check.sh` pass
- `dev_selftest` + `qc_status` pass
- Không Critical/Major ở code-review/security-review
- Artifacts: BDD, tech-design (nếu có), test plan, bug report (nếu có)

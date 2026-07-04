---
name: canonical-flow
role: all
---

# Canonical Flow — Single source of truth

Mọi workflow khác (`feature.md`, `dev-flow.md`, `qc-flow.md`, `enterprise-flow.md`) tham chiếu flow này.

## Spec pipeline (3 lớp — không thay thế nhau)

| Lớp | Skill | Artifact | Trả lời câu hỏi |
|-----|-------|----------|-----------------|
| 1. Product Brief | spec-driven-development | `docs/specs/{date}-{feature}.md` | **Cái gì, vì sao, done khi nào?** (scope, boundaries) |
| 2. Behavior | bdd-specification | `docs/specs/bdd/{UC-ID}.feature` | **Hệ thống làm gì?** (Given/When/Then) |
| 3. Technical | tech-docs | `docs/specs/tech-design/{UC-ID}-tech-design.md` | **Làm bằng gì?** (API, DB, events) |

Thứ tự bắt buộc (standard track): **Product Brief → BDD → Tech Design → Plan → Implement**

## Full flow (standard track)

```
product-discovery (optional)
  → brainstorming
  → spec-driven-development     [Product Brief]
  → bdd-specification           [Behavior]
  → tech-docs                   [Technical — bỏ qua nếu không có API/DB mới]
  → writing-plans
  → (tdd → progress-logging) × n tasks
  → code-review
  → qc-automation
  → trace-validation
  → shipping
```

## Fast track (< 30 phút, scope rõ, rủi ro thấp)

```
brainstorming (rút gọn) → writing-plans (rút gọn) → tdd → code-review → trace-validation (tối thiểu) → shipping
```

- Bỏ qua Product Brief/BDD/Tech Design nếu không đổi behavior chính
- Commit/PR ghi `[fast-track]` để SDD gate biết

## Hotfix track (production incident)

```
bug-flow (classify) → debugging/tdd (repro & sửa lỗi) → code-review → qc-automation (focused) → trace-validation → shipping
```

- Commit/PR ghi `[hotfix]`
- Bắt buộc: test tái hiện + sửa lỗi + rollback plan trong shipping

## Gates & signals

| Gate | Kiểm chứng bởi | Script |
|------|----------------|--------|
| Spec exists | SDD gate | `scripts/validate-sdd-gate.sh` |
| Stack rules | Dev onboarding | `scripts/validate-stack.sh` |
| Trace coverage | Trace gate | `scripts/validate-trace.sh` |
| Dev verified | `dev_selftest: pass` | Test runner (manual/CI) |
| QC verified | `qc_status: pass` | qc-automation output |
| Merge ready | All above | `scripts/governance-check.sh` |

## On fail — failure recovery map

| Fail tại | Root cause thường gặp | Quay về |
|----------|-----------------------|---------|
| bdd-specification | Requirement chưa rõ, scope mơ hồ | spec-driven-development |
| bdd-specification | Cần khám phá thêm domain | product-discovery |
| tech-docs | BDD scenario thiếu/ambiguous | bdd-specification |
| tdd (test fail) | Logic sai, edge case thiếu | debugging |
| tdd (test fail) | Kiến trúc sai hướng | refactoring → tdd |
| code-review (critical issue) | Implementation sai | tdd |
| qc-automation (fail) | Code bug | bug-flow → tdd |
| qc-automation (fail) | Spec sai/thiếu | bug-flow → bdd-specification |
| trace-validation (GAP) | Scenario chưa implement | tdd |
| trace-validation (DRIFT) | Spec đã thay đổi, trace cũ | bdd-specification → tdd |
| shipping (rollback) | Production incident | bug-flow → hotfix track |

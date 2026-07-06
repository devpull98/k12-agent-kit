---
name: canonical-flow
role: all
---

# Canonical Flow — Single source of truth

Mọi workflow khác (`feature.md`, `dev-flow.md`, `qc-flow.md`, `enterprise-flow.md`) tham chiếu flow này.

## Spec pipeline (3 lớp — không thay thế nhau)

| Lớp | Skill | Artifact | Trả lời câu hỏi |
|-----|-------|----------|-----------------|
| 1. Product Brief | spec-driven-development | `docs/specs/modules/<module>/<spec>.md` | **Cái gì, vì sao, done khi nào?** (scope, boundaries) |
| 2. Behavior | bdd-specification | `docs/specs/bdd/{UC-ID}.feature` | **Hệ thống làm gì?** (Given/When/Then) |
| 3. Technical | tech-docs | `docs/specs/tech-design/{UC-ID}-tech-design.md` | **Làm bằng gì?** (API, DB, events) |

Thứ tự bắt buộc (standard track): **Product Brief → BDD → Tech Design → Plan → Implement**

> **Doc scoping:** spec ổn định ở `docs/specs/modules/<module>/`; artifact thực thi (plan, checklist, note, bugs) gom vào `docs/work/<KEY>-<slug>/`, bắt đầu từ `_context.md`. Xem `rules/_global/doc-scoping.mdc`.

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

## On fail — Failure Recovery Map

- **Fail ở Product Brief/BDD/Tech Design:** Quay lại skill `brainstorming` / `bdd-specification` / `tech-docs` tương ứng để sửa đổi spec.
- **Fail ở Plan:** Quay lại `writing-plans` để cấu trúc lại dependencies và rủi ro.
- **Fail ở TDD/Implement (test fail/compile error):** Gọi skill `debugging` để định vị và sửa lỗi code.
- **Fail ở Code Review (logic):** Quay lại `tdd` sửa implementation. Fail do security → gọi `security-review` → `tdd`.
- **Fail ở QC Automation:** Bug code → `bug-flow` → `debugging` → `tdd`. Spec sai/thiếu → `bdd-specification` → `tdd`.
- **Fail ở Trace Validation / Governance:** Gọi `trace-validation` để bổ sung `@trace` hoặc sửa spec drift. Script fail → xem bảng chi tiết bên dưới.

### Chi tiết theo từng điểm fail

| Fail tại | Root cause thường gặp | Quay về |
|----------|-----------------------|---------|
| spec-driven-development | Yêu cầu mơ hồ, chưa đủ context | product-discovery → brainstorming |
| bdd-specification | Requirement chưa rõ, scope chưa chốt | spec-driven-development |
| bdd-specification | Cần khám phá thêm domain | product-discovery |
| tech-docs | BDD scenario thiếu / ambiguous | bdd-specification |
| writing-plans | Spec chưa đủ chi tiết để breakdown | bdd-specification hoặc tech-docs |
| writing-plans | Rủi ro quá cao, cần thiết kế lại | brainstorming → tech-docs |
| validate-stack.sh | Rules stack chưa tạo / chưa đúng | copy `rules/_template/` → điền convention |
| validate-sdd-gate.sh | Code thay đổi nhưng chưa có spec/BDD | spec-driven-development → bdd-specification |
| tdd (test fail) | Logic sai, edge case thiếu | debugging → tdd |
| tdd (test fail) | Kiến trúc sai hướng | tech-docs → writing-plans → tdd |
| code-review (critical — logic) | Implementation sai spec | tdd |
| code-review (critical — security) | Lỗ hổng bảo mật | security-review → tdd |
| qc-automation (fail) | Code bug | bug-flow → debugging → tdd |
| qc-automation (fail) | Spec sai / thiếu scenario | bdd-specification → tdd |
| trace-validation (GAP) | Scenario chưa implement hoặc thiếu @trace | tdd |
| trace-validation (DRIFT) | Spec đổi nhưng code/trace chưa cập nhật | bdd-specification → tdd |
| shipping (rollback trigger) | Production incident sau deploy | bug-flow → hotfix track |

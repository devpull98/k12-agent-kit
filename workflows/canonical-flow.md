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
| spec-driven-development | Yêu cầu mơ hồ, chưa đủ context | product-discovery → brainstorming |
| bdd-specification | Requirement chưa rõ, scope chưa chốt | spec-driven-development |
| bdd-specification | Cần khám phá thêm domain | product-discovery |
| tech-docs | BDD scenario thiếu / ambiguous | bdd-specification |
| writing-plans | Spec chưa đủ chi tiết để breakdown | bdd-specification hoặc tech-docs |
## On fail — Failure Recovery Map

- **Fail ở Product Brief/BDD/Tech Design:** Quay lại skill `brainstorming`/`bdd-specification`/`tech-docs` tương ứng để sửa đổi spec.
- **Fail ở Plan:** Quay lại `writing-plans` để cấu trúc lại dependencies và rủi ro.
- **Fail ở TDD/Implement (test fail/compile error):** Chạy phân tích logs, gọi skill `debugging` để định vị và sửa lỗi code.
- **Fail ở Code Review:** Gọi skill `refactoring` để dọn dẹp và tối ưu mã nguồn theo feedback.
- **Fail ở QC Automation (phát hiện bug):** Gọi `bug-flow` → `debugging` để sửa lỗi code; (phát hiện test QC lỗi) → quay lại `qc-automation` để cập nhật test script.
- **Fail ở Trace Validation / Governance:** Chạy skill `trace-validation` để bổ sung tag `@trace` hoặc sửa spec drift.

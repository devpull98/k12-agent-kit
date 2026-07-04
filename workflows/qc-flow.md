---
name: qc-flow
role: tester
---

# QC Flow — Quality Control Pipeline

## Flow
BDD spec approved + dev_selftest pass → qc-automation (6 bước) → [bug-flow nếu có bug] → trace-validation → merge-ready

## Steps

| Step | Skill | Gate? | On fail |
|------|-------|-------|---------|
| analyze | qc-automation (bước 1-2) | ✓ không có DOC_GAPS | Yêu cầu dev/PO clarify spec |
| design test | qc-automation (bước 3-4) | ✓ reviewer approve | analyze |
| run | qc-automation (bước 5) | ✓ tất cả pass | bug-flow |
| report | qc-automation (bước 6) | — | — |
| trace check | trace-validation | ✓ không có GAP | Báo dev bổ sung @trace |

## Điều kiện bắt đầu QC
- BDD spec phải có `@trace.status: approved`
- Code đã được dev merge (hoặc PR để review)
- Dev self-test đã pass (`dev_selftest: pass`)

## Khi có bug
1. Classify với `bug-flow` → xác định case (1-6)
2. Tạo bug report từ `templates/bug-report-template.md`
3. Assign đúng người
4. Sau khi fix → re-run từ bước Run (bước 5) của `qc-automation`

## Feedback loop enterprise
- `DOC_GAPS` từ QC phải route ngược về clarify spec trước khi chạy tiếp.
- Bug critical được ưu tiên theo hotfix track, nhưng vẫn phải cập nhật trace và test evidence.
- Khi QC pass lại, cập nhật `qc_status` rõ ràng để unblock merge gate.

## QC artifacts cần tạo
- `docs/test-plans/{UC-ID}-test-plan.md` (từ test-plan-template)
- Test files với `@trace.verifies: {UC-ID}-SC{N}`
- `docs/bugs/{BUG-ID}.md` (nếu có bug)
- QC Report (embedded trong test-plan hoặc file riêng)

## Hai signal độc lập (không được nhầm)
- `dev_selftest` — dev tự chạy, chứng minh code hoạt động cơ bản
- `qc_status` — tester chạy, chứng minh behavior đúng với spec
- **Cả hai phải pass trước khi merge vào main**

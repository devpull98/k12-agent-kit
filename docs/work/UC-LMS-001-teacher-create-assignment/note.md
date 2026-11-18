# Progress Log — UC-LMS-001

## Task Matrix mirror

| Task | Status | Thời gian | Verification | Files | Ghi chú |
|------|--------|-----------|--------------|-------|---------|
| T1: SC1 create hợp lệ | done | 2026-07-03 | `npm test -- AssignmentCreate.sc1` pass | service + endpoint | — |
| T2: SC2 draft ẩn student | done | 2026-07-03 | `npm test -- AssignmentCreate.sc2` pass | DRAFT branch | — |
| T3: SC3 reject past due | done | 2026-07-03 | `npm test -- AssignmentCreate.sc3` pass | dueDate validation | xem RCA |

## Tóm tắt tiến độ
- Hoàn thành: 3/3 task · shipped
- Đang làm: —
- Block/vấn đề: không (BUG-LMS-001 Closed)

## Working notes (ephemeral)

<!-- Trống sau ship — compact-on-DONE -->

## RCA (chỉ lỗi kiến trúc / nguy hiểm)

| Bug / symptom | Root cause | Fix | Prevent |
|---------------|------------|-----|---------|
| SC3: past `dueDate` → `201` (BUG-LMS-001) | Thiếu validate trước persist | Validate ở service → `400 INVALID_DUE_DATE` | Fail-first integration test SC3 + QC smoke |

## SCARV (ship)
- **S**cope: SC1–SC3. **C**hange: endpoint + due-date validation.
- **A**ffected: `lms_assignments`, `POST /api/lms/assignments`.
- **R**ollback: revert validation (no schema change).
- **V**erify: QC 3/3 · trace 3/3.

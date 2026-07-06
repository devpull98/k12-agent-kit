# Progress Log — UC-LMS-001

Progress log (progress-logging) + SCARV khi ship. 1 dòng / task.

## Tiến độ
- **3/3 scenario done**, đã ship. Không còn block.

## Nhật ký
| Ngày | Task | Trạng thái | Verification | Ghi chú |
|------|------|-----------|--------------|---------|
| 2026-07-03 | SC1 create hợp lệ | done | integration test pass | — |
| 2026-07-03 | SC2 draft ẩn student | done | integration test pass | — |
| 2026-07-03 | SC3 reject past due | done | integration test pass sau fix | phát sinh BUG-LMS-001, xem `bugs.md` |

## Bug fix — BUG-LMS-001 (2026-07-03, Dev Team)
- Thêm validation `dueDate` trước khi persist assignment.
- Request `dueDate` quá khứ nay trả `400 INVALID_DUE_DATE`.
- Thêm regression cho SC3, rerun smoke SC1/SC2.
- `dev_selftest`: pass · QC rerun (SC1/SC2/SC3): pass · lifecycle: `Open → Fixed → Closed`.

## SCARV (ship)
- **S**cope: 3 scenario UC-LMS-001. **C**hange: endpoint + due-date validation.
- **A**ffected: `lms_assignments`, `POST /api/lms/assignments`.
- **R**ollback: revert validation commit (không đổi schema).
- **V**erify: QC rerun 3/3 pass, trace 3/3 OK.

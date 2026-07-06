# Plan — UC-LMS-001: Teacher creates assignment

**Track:** standard · **Module:** lms · **Spec:** `docs/specs/bdd/UC-LMS-001.feature`

## Vertical slices (theo scenario)
| # | Slice | Scenario | Trace |
|---|-------|----------|-------|
| 1 | Tạo assignment hợp lệ (PUBLISHED, due tương lai) → `201` | SC1 | UC-LMS-001-SC1 |
| 2 | Lưu nháp (DRAFT) → `201`, không hiển thị cho student | SC2 | UC-LMS-001-SC2 |
| 3 | Từ chối `dueDate` quá khứ → `400 INVALID_DUE_DATE` | SC3 | UC-LMS-001-SC3 |

## Thứ tự & dependency
1. Slice 1 (happy path) — dựng endpoint + persistence trước.
2. Slice 2 — thêm nhánh trạng thái DRAFT (phụ thuộc slice 1).
3. Slice 3 — thêm validation `dueDate` trước persist (phụ thuộc slice 1).

## Acceptance & verification
- Mỗi slice có integration test gắn `@trace.verifies` tương ứng.
- `dev_selftest` pass trước khi bàn giao QC.
- QC chạy `qc-automation` 6 bước; gap → `bug-flow`.

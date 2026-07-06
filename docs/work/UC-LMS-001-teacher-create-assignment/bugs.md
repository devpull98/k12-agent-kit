# Bug findings — UC-LMS-001

## BUG-LMS-001 — Assignment chấp nhận `dueDate` quá khứ

## Metadata
- **Bug ID:** BUG-LMS-001
- **UC / Scenario:** UC-LMS-001 · SC3 (`UC-LMS-001-SC3`)
- **Domain:** lms · **Severity:** High · **Priority:** P1
- **State:** Closed
- **Reporter:** QA Team · **Owner:** Dev Team · **Created:** 2026-07-03

## Summary
System accepts assignment creation when `dueDate` is in the past, while spec requires rejection with `INVALID_DUE_DATE`.

## Expected vs Actual
- **Expected:** teacher submit assignment với `dueDate` quá khứ → API trả `400 INVALID_DUE_DATE`.
- **Actual:** API trả `201 created` và persist assignment.

## Reproduction
1. Auth như teacher `T001`.
2. `POST /api/lms/assignments` với `classId=CLS-6A`, `title=Math Homework 1`, `dueDate=2026-06-01`, `status=PUBLISHED`.
3. Quan sát response + DB.

## Evidence
- API response: `201 created`
- Row tồn tại trong `lms_assignments` với due date quá khứ.

## Impact
- Vi phạm BDD scenario SC3. Student có thể nhận assignment quá hạn ngay lập tức.

## Trace
- `@trace.verifies: UC-LMS-001-SC3`
- Expected `@trace.implements: UC-LMS-001-SC3`

## Fix Guidance
- Thêm due-date validation ở service layer trước persistence.
- Test SC3 phải fail trước fix, pass sau fix.

## Retest Checklist
- [x] Rerun SC3 integration test: expect `400 INVALID_DUE_DATE`
- [x] Confirm không regression SC1/SC2
- [x] Cập nhật `qc_status` sau retest

## Resolution
- **State:** Open → Fixed → Closed
- **Retest:** QC rerun pass (3/3), xem `test-plan.md` §Rerun.

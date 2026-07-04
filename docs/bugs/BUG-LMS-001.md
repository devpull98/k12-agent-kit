# Bug Report — BUG-LMS-001

## Metadata
- **Bug ID:** BUG-LMS-001
- **UC ID:** UC-LMS-001
- **Related Scenario:** SC3 (`UC-LMS-001-SC3`)
- **Domain:** lms
- **Severity:** High
- **Priority:** P1
- **State:** Closed
- **Reporter:** QA Team
- **Owner:** Dev Team
- **Created at:** 2026-07-03

## Summary
System accepts assignment creation when `dueDate` is in the past, while spec requires rejection with `INVALID_DUE_DATE`.

## Expected Behavior
When teacher submits assignment with past `dueDate`, API must return `400 INVALID_DUE_DATE`.

## Actual Behavior
API returns `201 created` and persists assignment.

## Reproduction Steps
1. Authenticate as teacher `T001`.
2. Call `POST /api/lms/assignments` with:
   - `classId=CLS-6A`
   - `title=Math Homework 1`
   - `dueDate=2026-06-01`
   - `status=PUBLISHED`
3. Observe response and database state.

## Evidence
- API response: `201 created`
- Assignment row exists in `lms_assignments` with past due date

## Impact
- Violates BDD scenario `SC3`.
- Students may receive invalid overdue assignments immediately.

## Trace
- **@trace.verifies:** UC-LMS-001-SC3
- **Expected @trace.implements:** UC-LMS-001-SC3

## Fix Guidance
- Add due-date validation in service layer before persistence.
- Add/adjust test for `UC-LMS-001-SC3` to fail before fix and pass after fix.

## Retest Checklist
- [x] Re-run SC3 integration test: expect `400 INVALID_DUE_DATE`
- [x] Confirm no regression on SC1 and SC2
- [x] Update `qc_status` after retest

## Resolution
- **State transition:** Open -> Fixed -> Closed
- **Fix commit:** docs-only demo update (sample workflow artifact)
- **Retest result:** QC rerun passed (3/3), see `docs/test-plans/UC-LMS-001-qc-rerun-report.md`

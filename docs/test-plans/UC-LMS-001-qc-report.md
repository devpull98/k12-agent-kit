# QC Execution Report — UC-LMS-001

**Run date:** 2026-07-03  
**Run owner:** QA Team  
**Environment:** staging  
**Source plan:** `docs/test-plans/UC-LMS-001-test-plan.md`

## 1. Execution Summary
- Total scenarios: 3
- Passed: 2
- Failed: 1
- Blocked: 0
- Overall `qc_status`: **fail**

## 2. Scenario Results
| Scenario | Trace ID | Result | Note |
|---------|----------|--------|------|
| SC1 | UC-LMS-001-SC1 | Pass | Create published assignment works |
| SC2 | UC-LMS-001-SC2 | Pass | Draft assignment not visible to students |
| SC3 | UC-LMS-001-SC3 | Fail | API accepted past due date |

## 3. Defects Raised
- `BUG-LMS-001` (High, P1, State: Open)
  - Related scenario: `UC-LMS-001-SC3`
  - Symptom: expected `400 INVALID_DUE_DATE`, actual `201 created`

## 4. Recommended Next Actions
1. Dev applies fix for due-date validation (`UC-LMS-001-SC3`).
2. Dev re-runs affected tests and updates `dev_selftest`.
3. QA re-runs SC3 plus smoke regression for SC1/SC2.
4. Update `docs/trace/UC-LMS-001-trace.tsv` with rerun result.
5. Move bug state: `Open -> Fixed -> Closed` after verification.

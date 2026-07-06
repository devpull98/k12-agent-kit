# Test Plan — UC-LMS-001: Teacher creates assignment

**Tester:** QA Team · **BDD:** `docs/specs/bdd/UC-LMS-001.feature` · **Env:** staging

## 1. Scope
| SC-ID | Scenario | Priority | Test type |
|------|----------|----------|-----------|
| SC1 | Create assignment with valid inputs | Critical | Integration |
| SC2 | Save assignment as draft | High | Integration |
| SC3 | Reject past due date | High | Integration |

## 2. Test Strategy
**Data setup:** teacher `T001`, class `CLS-6A`, active academic term.
Dependencies: API deployed on staging · DB migration `lms_assignments` · Auth trả role `TEACHER`.

## 3. Test Cases
### SC1 — `@trace.verifies: UC-LMS-001-SC1`
| # | Case | Input | Expected |
|---|------|-------|----------|
| 1 | Valid create | `status=PUBLISHED`, future due | `201 created`, visible |

### SC2 — `@trace.verifies: UC-LMS-001-SC2`
| # | Case | Input | Expected |
|---|------|-------|----------|
| 1 | Save draft | `status=DRAFT`, future due | `201 created`, không hiển thị student |

### SC3 — `@trace.verifies: UC-LMS-001-SC3`
| # | Case | Input | Expected |
|---|------|-------|----------|
| 1 | Past due date | `dueDate=2026-06-01` | `400 INVALID_DUE_DATE` |

## 4. QC Run #1 (2026-07-03) — qc_status: **fail**
| Scenario | Trace | Result | Note |
|----------|-------|--------|------|
| SC1 | UC-LMS-001-SC1 | Pass | Create published works |
| SC2 | UC-LMS-001-SC2 | Pass | Draft ẩn với student |
| SC3 | UC-LMS-001-SC3 | Fail | API chấp nhận past due date → `BUG-LMS-001` |

**Defect raised:** `BUG-LMS-001` (High, P1). Bàn giao dev fix due-date validation.

## 5. QC Rerun (2026-07-03) — qc_status: **pass**
Trigger: verify fix cho `BUG-LMS-001`.
| Scenario | Trace | Result | Note |
|----------|-------|--------|------|
| SC1 | UC-LMS-001-SC1 | Pass | No regression |
| SC2 | UC-LMS-001-SC2 | Pass | No regression |
| SC3 | UC-LMS-001-SC3 | Pass | Trả `400 INVALID_DUE_DATE` |

**Overall:** 3/3 pass · `BUG-LMS-001` verified fixed & closed.

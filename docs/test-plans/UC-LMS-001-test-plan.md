# Test Plan — UC-LMS-001: Teacher creates assignment

**Date:** 2026-07-03  
**Tester:** QA Team  
**BDD Spec:** `docs/specs/bdd/UC-LMS-001.feature`  
**Status:** Draft

## 1. Scope
| SC-ID | Scenario | Priority | Test type |
|------|----------|----------|-----------|
| SC1 | Create assignment with valid inputs | Critical | Integration |
| SC2 | Save assignment as draft | High | Integration |
| SC3 | Reject past due date | High | Integration |

## 2. Test Strategy
**Environment:** staging  
**Data setup:** teacher `T001`, class `CLS-6A`, active academic term

Dependencies:
- [ ] API deployed on staging
- [ ] DB migration for `lms_assignments` completed
- [ ] Auth service returns role `TEACHER`

## 3. Test Cases

### SC1 — Create assignment with valid inputs
**@trace.verifies:** UC-LMS-001-SC1

| # | Test case | Input | Expected | Type |
|---|-----------|-------|----------|------|
| 1 | Valid create request | `status=PUBLISHED`, future due date | `201 created`, assignment visible | Integration |

### SC2 — Save assignment as draft
**@trace.verifies:** UC-LMS-001-SC2

| # | Test case | Input | Expected | Type |
|---|-----------|-------|----------|------|
| 1 | Save draft request | `status=DRAFT`, future due date | `201 created`, not visible to students | Integration |

### SC3 — Reject past due date
**@trace.verifies:** UC-LMS-001-SC3

| # | Test case | Input | Expected | Type |
|---|-----------|-------|----------|------|
| 1 | Due date in past | `dueDate=2026-06-01` | `400 INVALID_DUE_DATE` | Integration |

## 4. DOC Gaps
- [ ] None at planning stage.

## 5. Results Summary
| SC-ID | Pass | Fail | Blocked | Notes |
|------|------|------|---------|-------|
| SC1 | 1 | 0 | 0 | `201 created` as expected |
| SC2 | 1 | 0 | 0 | Draft not visible to students |
| SC3 | 0 | 1 | 0 | See `BUG-LMS-001` |

**Overall:** 2/3 passed, 1 failed  
**Bugs found:** `BUG-LMS-001`

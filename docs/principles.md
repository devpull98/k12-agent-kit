# K12 Enterprise Engineering Principles

## Scope
- Applies to all product domains: `lms`, `club`, `teacher`, `products`.
- Applies to all delivery surfaces: code, tests, specs, CI/CD, and release operations.
- Applies to every AI role: Tech Lead/PO, Dev, Tester, Reviewer, Security Auditor.

## MUST
- Follow spec-first behavior changes: update BDD/spec before or with code changes.
- Keep traceability for key behavior with `@trace.implements` and `@trace.verifies`.
- Require both independent signals before merge: `dev_selftest=pass` and `qc_status=pass`.
- Add rollback notes for all hotfix releases and critical production fixes.
- Record architecture decisions that exceed existing baseline in technical artifacts.

## MUST NOT
- Do not merge with unresolved trace GAP blockers.
- Do not skip test evidence in hotfix unless an approved exception is logged.
- Do not introduce silent behavior changes without updating spec/test artifacts.
- Do not add abstractions without measurable value or clear design rationale.

## Delivery Tracks

### Standard
- Default for any business logic, API, database, or cross-module changes.
- Required flow: spec -> design -> tdd -> review -> qc -> trace -> ship.

### Fast
- Allowed for scoped low-risk updates (copy, typo, config, minor UI fixes).
- Still requires: relevant tests, code review, and minimal trace validation.

### Hotfix
- For production incidents requiring urgent recovery.
- Required minimum: bug classification, repro test, targeted fix, rollback note, focused QC rerun.

## Quality Gates
- Gate 1: Requirement/spec clarity (no ambiguity blockers).
- Gate 2: Tests pass with no critical regression.
- Gate 3: No unresolved Critical/Major findings in review.
- Gate 4: QC evidence present and `qc_status` updated.
- Gate 5: Trace validation has no GAP blockers.

## Security and Safety Baseline
- Never commit secrets, keys, or credentials into repository artifacts.
- Follow global security/error-handling/observability rules in `rules/_global/`.
- Require security-review for sensitive scope (auth, payment, PII, permission model).

## Exception Log
| Date | Decision | Reason | Approved by | TTL |
|------|----------|--------|-------------|-----|
| YYYY-MM-DD | (exception detail) | (business/technical reason) | (Tech Lead/Owner) | (expiry date) |

## Review Cadence
- Sprint-level review for active exceptions and unresolved risks.
- Monthly governance review to update principles for new stack/modules/process changes.

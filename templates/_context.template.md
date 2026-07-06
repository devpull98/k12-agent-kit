# <JIRA-KEY> — <Human-readable title>

## Classification
- **Type:** feature | bug | perf | refactor
- **Module:** <module-name>
- **Jira:** <JIRA-KEY> (use `NOJIRA` if none)
- **Artifact key:** `<JIRA-KEY>-<slug>`

## Spec anchor
- **File:** docs/specs/modules/<module>/<spec-file>.md
- **Sections:** §X.Y, §Z (list only sections needed — not full spec)

## Read order (ONLY — do not glob elsewhere)
1. `_context.md` (this file)
2. `plan.md`
3. `checklist.md`
4. Spec sections listed above

## Dependencies (read if touching these areas)
- **Code:** `<module-path>/ClassName.ext`
- **Cross-module:** `<other-module>` — reason
- **Rules:** `rules/{stack}/<pattern>.mdc` — if perf/cache involved

## Impact radius
- **Stores:** DB tables / cache keys / collections (or "none")
- **Messaging:** queue topics (or "none")
- **APIs:** endpoints / contracts (or "none")

## Do NOT read (unless dependency above triggered)
- `docs/work/*` — other work packages
- `docs/plans/*`, `docs/logs/*`, `docs/notes/features/*` — legacy flat
- Unrelated module specs

## Status
- [ ] brainstorm
- [ ] plan
- [ ] in progress
- [ ] review
- [ ] done

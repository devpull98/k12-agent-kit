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

## State (machine-readable — governance + hook đọc block này)
<!-- Mỗi skill khi hoàn thành CẬP NHẬT block này. Đây là single source of truth
     cho handoff dev→QC→ship. scripts/validate-context-state.sh parse block này. -->
```yaml
phase: discovery        # discovery|spec|bdd|tech|plan|implement|review|qc|trace|ship|done
track: standard         # standard|fast|hotfix
last_skill: ""          # skill vừa chạy xong
next_skill: ""          # skill kế (đọc từ on_success của last_skill)
dev_selftest: pending   # pending|pass|fail   — dev đặt sau tdd/implement
qc_status: pending      # pending|pass|fail|na — tester đặt sau qc-automation (na = fast/hotfix bỏ qua)
trace: pending          # pending|pass|fail   — validate-trace.sh / trace-validation
updated: ""             # YYYY-MM-DD
```

**Ship-ready khi:** `dev_selftest: pass` **và** `qc_status ∈ {pass, na}` **và** `trace: pass`.

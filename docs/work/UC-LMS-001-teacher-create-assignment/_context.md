# UC-LMS-001 — Teacher creates assignment

> **Reference example** cho toàn kit: một UC chạy trọn vòng đời standard track
> (spec → BDD → tech → plan → tdd → QC → bug → rerun → ship) theo mô hình
> Work Package của `rules/_global/doc-scoping.mdc`. Đây là mẫu để copy, không phải task thật.

## Classification
- **Type:** feature (phát sinh 1 bug ở QC, đã fix & close)
- **Module:** lms
- **Jira:** NOJIRA (demo UC)
- **Artifact key:** `UC-LMS-001-teacher-create-assignment`

## Spec anchor
- **BDD:** `docs/specs/bdd/UC-LMS-001.feature` (SC1, SC2, SC3)
- **Tech design:** `docs/specs/tech-design/UC-LMS-001-tech-design.md`
- **Trace:** `docs/trace/UC-LMS-001-trace.tsv`

## Read order (ONLY — do not glob elsewhere)
1. `_context.md` (this file)
2. `plan.md`
3. `checklist.md`
4. `test-plan.md` · `bugs.md` · `note.md`
5. Spec anchors ở trên

## Dependencies (read if touching these areas)
- **Code:** service layer tạo assignment (validate `dueDate` trước khi persist)
- **Rules:** `rules/{stack}/architecture.mdc`, `rules/{stack}/test-patterns.mdc`

## Impact radius
- **Stores:** bảng `lms_assignments`
- **Messaging:** none
- **APIs:** `POST /api/lms/assignments`

## Do NOT read (unless dependency above triggered)
- `docs/work/*` — other work packages
- `docs/plans/*`, `docs/logs/*`, `docs/notes/features/*` — legacy flat
- Unrelated module specs

## State (machine-readable — governance + hook đọc block này)
<!-- Mỗi skill khi hoàn thành CẬP NHẬT block này. scripts/validate-context-state.sh parse block này. -->
```yaml
phase: done             # discovery|spec|bdd|tech|plan|implement|review|qc|trace|ship|done
track: standard         # standard|fast|hotfix
last_skill: shipping    # skill vừa chạy xong
next_skill: ""          # skill kế (đọc từ on_success của last_skill)
dev_selftest: pass      # pending|pass|fail
qc_status: pass         # pending|pass|fail|na  (rerun sau khi fix BUG-LMS-001)
trace: pass             # pending|pass|fail
updated: 2026-07-03     # YYYY-MM-DD
```

**Ship-ready khi:** `dev_selftest: pass` **và** `qc_status ∈ {pass, na}` **và** `trace: pass`.

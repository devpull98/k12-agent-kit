---
# ── Work item metadata — SOURCE OF TRUTH cho board/issue/lịch sử. Tạo bằng:
#    bash scripts/work.sh new <type> <module> "<title>"     (tự cấp ID, điền ngày)
#    Cập nhật bằng: bash scripts/work.sh set <ID> status=review phase=review ...
# Frontmatter PHẲNG: key: value, list dạng [a, b]. Enum sai → validate-work-items.sh FAIL.
id: <ID>                # Jira key (EDC-5681) hoặc <MODULE-PREFIX>-<NNN> (SOCKETIO-012). Folder = <id>-<slug>
title: "<TITLE>"
type: feature           # feature|bug|perf|refactor|security|chore|spike
status: todo            # backlog|todo|in-progress|blocked|review|qc|ready|done|cancelled
priority: P2            # P0 (sự cố) | P1 | P2 | P3
modules: [<module>]     # key trong docs/modules.yaml — ≥1
track: standard         # standard|fast|hotfix
phase: discovery        # discovery|spec|bdd|tech|plan|implement|review|qc|trace|ship|done
created: YYYY-MM-DD
updated: YYYY-MM-DD
closed: ""              # bắt buộc khi status = done|cancelled
assignee: ""
jira: ""
fixes: []               # item gốc mà item này sửa (bug → feature), vd [NUDGE-003]
relates_to: []
supersedes: []          # item cũ bị thay thế (vd v2 thay v1)
prs: []                 # link/số PR
last_skill: ""          # skill vừa xong
next_skill: ""          # skill kế (on_success của last_skill)
dev_selftest: pending   # pending|pass|fail   — dev đặt sau implement (có bằng chứng)
qc_status: pending      # pending|pass|fail|na — tester đặt sau qc-automation (na = fast/hotfix)
trace: pending          # pending|pass|fail   — validate-trace.sh / trace-validation
---
# <ID> — <TITLE>

> **ENTRY POINT** — đọc file này TRƯỚC. Chỉ đọc path liệt kê ở đây.
> Ship-ready khi: `dev_selftest: pass` **và** `qc_status ∈ {pass, na}` **và** `trace: pass` (`scripts/validate-context-state.sh`).

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
- `docs/work/*` — other work packages (dùng `docs/work/INDEX.md` / `work.sh history` để tra)
- `docs/plans/*`, `docs/logs/*`, `docs/notes/features/*` — legacy flat
- Unrelated module specs

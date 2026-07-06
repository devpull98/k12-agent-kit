# Docs Artifact Guide

Tài liệu trong thư mục này là nguồn sự thật cho quy trình enterprise và traceability.
Mô hình doc: **Work Package** (`rules/_global/doc-scoping.mdc`) — 1 task = 1 folder.

## Core files
- `principles.md`: governance của project (MUST/MUST NOT, tracks, quality gates, exception log).

## Stable truth — tầng spec (behavior/contract, UC-keyed, phẳng)
- `specs/modules/<module>/`: Product Brief / behavior contract (`spec-driven-development`).
- `specs/bdd/`: BDD scenarios (`{UC-ID}.feature`).
- `specs/tech-design/`: technical design (`{UC-ID}-tech-design.md`).
- `trace/`: trace artifacts phục vụ coverage/drift checks (`{UC-ID}-trace.tsv`).
  - Mẫu đã có: `trace/UC-LMS-001-trace.tsv`

## Execution — Work Package (mỗi task/bug gom vào 1 folder)
```
docs/work/<KEY>-<slug>/
  _context.md    ← ENTRY POINT bắt buộc (State block cho ship gate)
  plan.md        ← writing-plans
  checklist.md   ← task breakdown, mỗi dòng traceable
  note.md        ← progress-logging + SCARV khi ship
  bugs.md        ← bug-flow findings
  test-plan.md   ← qc-automation (optional)
```
- Reference example đầy đủ vòng đời: `docs/work/UC-LMS-001-teacher-create-assignment/`.
- Sprint-level retro (aggregate nhiều work package): `docs/retros/<sprint-id>.md`.

> **Legacy (deprecated):** `docs/plans/`, `docs/notes/`, `docs/logs/`, `docs/bugs/`, `docs/test-plans/`
> phẳng — chỉ đọc khi migrate. Task mới **chỉ** tạo trong `docs/work/`. Xem bảng mapping trong
> `rules/_global/doc-scoping.mdc`.

## Minimal operating rules
- Thay đổi behavior phải cập nhật spec/BDD trước hoặc cùng lúc code.
- Mọi thay đổi quan trọng cần trace tags:
  - `@trace.implements: {UC-ID}-SC{N}`
  - `@trace.verifies: {UC-ID}-SC{N}`
- Chỉ merge khi cả `dev_selftest` và `qc_status` đều pass (ship gate: `scripts/validate-context-state.sh`).

## Suggested naming
- UC IDs: `UC-<domain>-<number>` (ví dụ: `UC-LMS-012`).
- Bug IDs: `BUG-<domain>-<number>` (ví dụ: `BUG-CLUB-004`).
- Work Package: `<JIRA-KEY>-<slug>` (không có Jira → `NOJIRA-<slug>`).
- Trace TSV: `UC-<domain>-<number>-trace.tsv`.

## Ownership
- Tech Lead/PO: duy trì `principles.md` và phê duyệt ngoại lệ.
- Dev: duy trì `specs/`, `tech-design/`, `work/<KEY>/note.md`, trace implements.
- Tester: duy trì `work/<KEY>/test-plan.md`, `work/<KEY>/bugs.md`, trace verifies, `qc_status`.

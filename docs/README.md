# Docs Artifact Guide

Tài liệu trong thư mục này là nguồn sự thật cho quy trình enterprise và traceability.

## Core files
- `principles.md`: governance của project (MUST/MUST NOT, tracks, quality gates, exception log).

## Artifact directories
- `specs/bdd/`: BDD scenarios (`{UC-ID}.feature`).
- `specs/tech-design/`: technical design (`{UC-ID}-tech-design.md`).
- `test-plans/`: kế hoạch test và QC report (`{UC-ID}-test-plan.md`).
- `bugs/`: bug reports (`{BUG-ID}.md`).
- `logs/`: progress logs theo task/sprint.
- `trace/`: trace artifacts phục vụ coverage/drift checks.
  - Mẫu đã có: `trace/UC-LMS-001-trace.tsv`

## Minimal operating rules
- Thay đổi behavior phải cập nhật spec/BDD trước hoặc cùng lúc code.
- Mọi thay đổi quan trọng cần trace tags:
  - `@trace.implements: {UC-ID}-SC{N}`
  - `@trace.verifies: {UC-ID}-SC{N}`
- Chỉ merge khi cả `dev_selftest` và `qc_status` đều pass.

## Suggested naming
- UC IDs: `UC-<domain>-<number>` (ví dụ: `UC-LMS-012`).
- Bug IDs: `BUG-<domain>-<number>` (ví dụ: `BUG-CLUB-004`).
- Logs: `YYYY-MM-DD-<short-topic>.md`.
- Trace TSV: `UC-<domain>-<number>-trace.tsv`.

## Ownership
- Tech Lead/PO: duy trì `principles.md` và phê duyệt ngoại lệ.
- Dev: duy trì `specs/`, `tech-design/`, `logs/`, trace implements.
- Tester: duy trì `test-plans/`, `bugs/`, trace verifies, `qc_status`.

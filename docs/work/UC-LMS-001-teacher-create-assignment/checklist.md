# Checklist — UC-LMS-001

Mỗi dòng traceable tới 1 scenario. `[x]` = done + verified.

- [x] SC1 · `@trace.implements: UC-LMS-001-SC1` — tạo assignment PUBLISHED hợp lệ → `201`
- [x] SC1 · `@trace.verifies: UC-LMS-001-SC1` — integration test happy path
- [x] SC2 · `@trace.implements: UC-LMS-001-SC2` — nhánh DRAFT, ẩn với student
- [x] SC2 · `@trace.verifies: UC-LMS-001-SC2` — integration test draft không hiển thị
- [x] SC3 · `@trace.implements: UC-LMS-001-SC3` — validate `dueDate` quá khứ → `400 INVALID_DUE_DATE`
- [x] SC3 · `@trace.verifies: UC-LMS-001-SC3` — integration test reject past due date (fail trước fix → pass sau fix, xem `bugs.md`)
- [x] Trace TSV cập nhật (`docs/trace/UC-LMS-001-trace.tsv`) — OK 3/3
- [x] QC rerun pass 3/3 sau khi close BUG-LMS-001

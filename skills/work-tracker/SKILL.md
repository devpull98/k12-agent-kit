---
name: work-tracker
description: Quản lý work item như GitHub Issues trong repo — tạo item có ID (work.sh new), cập nhật status/phase, xem board tiến độ, bug đang mở, lịch sử thay đổi/bug của 1 module hoặc 1 feature, migrate work package cũ. Use when bắt đầu task/bug/perf mới chưa có work package, user hỏi "đang làm gì / tiến độ / bug nào còn mở / module X đã sửa gì", hoặc repo còn package NOJIRA/legacy.
keywords: [work item, issue, board, tiến độ tổng, bug đang mở, lịch sử module, history, tạo task, work package mới, migrate work, nojira]
not_for: [ghi log 1 task trong plan vừa xong — dùng progress-logging, tổng kết sprint — dùng sprint-retro]
requires_rules:
  - _global/work-items
  - _global/doc-scoping
on_success: []
on_failure: []
---

# Purpose
Mọi việc đều là 1 work item có ID, module, status — để trả lời được *đang chạy gì, bug nào mở, module X đã qua những thay đổi gì* bằng 1 lệnh, không phải mở từng folder.

# Inputs
- `docs/modules.yaml` (registry) — thiếu → tạo từ `templates/modules.template.yaml` trước (hỏi user danh sách module + code path)
- Yêu cầu của user (task mới / câu hỏi tiến độ / lịch sử)

# Steps

## A. Bắt đầu việc mới (trước brainstorming/bug-flow/debugging)
1. Tra trùng: `bash scripts/work.sh list <module>` — đã có item cùng việc → dùng tiếp, không tạo mới.
2. Xác định `type` (feature/bug/perf/refactor/security/chore/spike) và module chính (key trong registry). Bug phát hiện sau khi item gốc đã done → `--fixes <ID gốc>`.
3. `bash scripts/work.sh new <type> <module> "<title>" [--jira KEY] [--fixes ID] [--priority P1]`
4. Nhiều module → sửa `modules: [a, b]` trong frontmatter. Điền Spec anchor / Read order trong `_context.md`.
5. Tạo branch theo gợi ý `<feat|fix|perf…>/<ID>-<slug>` (commit tự gắn `Work-Item: <ID>`).

## B. Chuyển bước (mỗi khi 1 skill xong)
- `bash scripts/work.sh set <ID> status=<…> phase=<…> last_skill=<…> next_skill=<…>`
  | Đang ở | status |
  |--------|--------|
  | chưa bắt đầu / spec / plan | `todo` |
  | implement | `in-progress` |
  | chờ thứ khác (người, env, quyết định) | `blocked` (ghi lý do vào note.md) |
  | code-review | `review` |
  | qc-automation | `qc` |
  | đủ gate, chờ deploy | `ready` |
  | đã deploy / đóng | `done` (tự điền `closed`) |
- Thêm PR: `set <ID> prs=[#123]`. Sau đó `bash scripts/work.sh index` và commit `INDEX.md` cùng thay đổi.

## C. Trả lời câu hỏi tiến độ / lịch sử (KHÔNG glob docs/work/*)
| Câu hỏi | Lệnh |
|---------|------|
| Đang chạy gì, ai kẹt? | đọc `docs/work/INDEX.md` § Đang chạy (⚠Nd = stale) |
| Bug nào còn mở? | `INDEX.md` § Bug đang mở |
| Module X đã có những gì (cũ → mới)? | `bash scripts/work.sh history <module> --git` |
| Feature Y: bug nào phát sinh, commit nào? | `bash scripts/work.sh history <ID> --git` |
| Lọc nhanh | `bash scripts/work.sh list in-progress` / `list bug` / `list <module>` |

## D. Migrate repo cũ
1. Có `docs/modules.yaml` (thêm `aliases` cho tên module hay xuất hiện trong doc cũ).
2. `bash scripts/work.sh migrate --report /tmp/migrate.md` → trình user bảng mapping; cột "Cần duyệt" phải được xử lý (sửa registry/aliases, chạy lại).
3. User duyệt → trên nhánh riêng: `work.sh migrate --apply` → `work.sh index` → `bash scripts/validate-work-items.sh`. Trong thời gian chuyển đổi: `work_items_strict: false`.
4. File legacy (`docs/plans/*`…) theo gợi ý trong report: gộp vào package tương ứng hoặc tạo item mới.

# Output
- Work item hợp lệ (`validate-work-items.sh` PASS), `INDEX.md` cập nhật
- Câu trả lời tiến độ/lịch sử kèm lệnh đã chạy (bằng chứng)

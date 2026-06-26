---
name: progress-logging
description: Lưu vết và báo cáo tiến độ ngay sau khi 1 task trong plan hoàn thành. Use when 1 task vừa pass verification step, hoặc user hỏi "tiến độ tới đâu rồi".
keywords: [log, tiến độ, progress, nhật ký, report, hoàn thành task]
not_for: [báo cáo tổng kết toàn feature sau khi ship — dùng shipping]
requires_rules:
  - _global/sdd-gate
---

# Purpose
Đảm bảo mọi task hoàn thành đều có vết ghi lại (ai/khi nào/kết quả gì), và user luôn biết tiến độ thật
mà không cần tự hỏi lại — tránh mất dấu khi 1 feature có nhiều task chạy nối tiếp qua nhiều session.

# Inputs
- File plan đã có (`docs/plans/<feature>.md`), từ `writing-plans`
- Task vừa hoàn thành + kết quả verification step của nó

# Steps
1. Xác nhận task vừa xong đã pass verification step (test/build/manual check) — chưa pass thì KHÔNG log là "done".
2. Nếu chưa có file log cho feature này, tạo từ `templates/progress-log-template.md` tại `docs/logs/<feature>.md`.
3. Cập nhật đúng 1 dòng của task đó: trạng thái (`done`), timestamp, lệnh verification + kết quả, file đã đụng tới.
4. Cập nhật mục "Tóm tắt tiến độ" (số task done/tổng, task đang làm tiếp theo, block nếu có).
5. Commit file log cùng lúc với code của task đó (không tách riêng commit).
6. Báo lại ngay cho user 1-2 câu: task nào vừa xong, còn bao nhiêu task, có block gì không.

# Output
- File `docs/logs/<feature>.md` được cập nhật, khớp với task list trong plan
- 1 câu báo cáo ngắn cho user: "X/Y task done, đang làm Task <tên>, [không có block / block: ...]"

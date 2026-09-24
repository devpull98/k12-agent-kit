---
name: progress-logging
description: Lưu vết và báo cáo tiến độ ngay sau khi 1 task trong plan hoàn thành. Use when 1 task vừa pass verification step, hoặc user hỏi "tiến độ tới đâu rồi".
keywords: [log, tiến độ, progress, nhật ký, report, hoàn thành task]
not_for: [báo cáo tổng kết toàn feature sau khi ship — dùng shipping, gọi standalone khi task chưa pass verification step]
on_success: [tdd]
on_failure: []
requires_rules:
  - _global/sdd-gate
  - _global/doc-scoping
---

# Purpose
Đảm bảo mọi task hoàn thành đều có vết ghi lại (ai/khi nào/kết quả gì), và user luôn biết tiến độ thật
mà không cần tự hỏi lại — tránh mất dấu khi 1 feature có nhiều task chạy nối tiếp qua nhiều session.

# Inputs
- Work package của task (`docs/work/<KEY>-<slug>/`) với `plan.md` từ `writing-plans`
- Task vừa hoàn thành + kết quả verification step của nó

# Steps
1. Xác nhận task vừa xong đã pass verification step (test/build/manual check) — chưa pass thì KHÔNG log là "done".
2. Nếu chưa có file log: tạo từ `templates/progress-log-template.md` tại `docs/work/<KEY>-<slug>/note.md`.
3. Cập nhật **đúng 1 dòng** của task trong bảng Task Matrix mirror: `done`, timestamp, lệnh verification + kết quả, relative link file đã đụng, ghi chú ≤1 câu.
4. Cập nhật "Tóm tắt tiến độ" (3 bullet: done/tổng, đang làm, block) — không viết đoạn văn.
5. Trong `plan.md`: đổi `Status` → `done` trên hàng Task Matrix + tick `[x]` AC. Không sửa mô tả, không thêm heading.
6. **Compact-on-DONE (task):** thu gọn / xóa Working notes liên quan task vừa xong (giả thiết, log dump → 1 câu ở cột Ghi chú). Nếu lỗi kiến trúc nguy hiểm → 1 hàng bảng RCA; không giữ stack dài.
7. Trong `_context.md`: chỉ patch YAML (`last_skill: progress-logging`, `next_skill`, `updated`). Không append recap.
8. Commit file log cùng lúc với code của task đó (không tách riêng commit).
9. Báo user 1–2 câu: task nào vừa xong, còn bao nhiêu, block gì không.

# Output
- `note.md` khớp Task Matrix trong plan; Working notes không phình sau task done
- 1 câu báo cáo: "X/Y task done, đang làm Task <tên>, [không block / block: ...]"
- `_context.md` / `plan.md` không dài thêm ngoài Status tick + YAML patch

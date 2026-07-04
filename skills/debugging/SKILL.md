---
name: debugging
description: Tìm root cause có hệ thống trước khi sửa lỗi, qua quy trình reproduce -> localize -> fix root cause -> guard. Use when test fail, build lỗi, behavior không đúng kỳ vọng, hoặc gặp bug/exception bất kỳ.
keywords: [debug, bug, fix, lỗi, error, exception, test failure, root cause]
not_for: [tdd cho feature mới chưa có bug]
on_success: [tdd]
on_failure: [root-cause-tracing]
requires_rules:
  - _global/error-handling
---

# Purpose
Sửa đúng nguyên nhân gốc thay vì vá triệu chứng — dừng việc đoán, dùng quy trình triage có thứ tự.

# Inputs
- Mô tả lỗi / log / stack trace
- Khả năng reproduce (steps, môi trường)

# Steps
1. STOP: ngừng thêm feature mới, giữ nguyên evidence (log, output lỗi, repro steps).
2. Reproduce lỗi ổn định. Nếu không reproduce được, thu thập thêm log/instrumentation tại từng layer trước khi đoán.
3. Localize: xác định layer lỗi xảy ra (UI/API/DB/build tool/external service/test sai). Dùng `git bisect` nếu là regression.
4. Reduce: tạo minimal reproduction — bỏ bớt phần không liên quan tới khi rõ root cause.
5. Tìm root cause bằng cách hỏi "vì sao" tới khi chạm nguyên nhân thật, không dừng ở nơi triệu chứng xuất hiện. Nếu cần trace ngược qua nhiều lớp gọi, dùng kỹ thuật ở skill root-cause-tracing.
6. Viết 1 test tái hiện đúng bug đó (test phải fail trước khi fix) — theo skill tdd.
7. Sửa đúng root cause, 1 thay đổi/lần, không bundle thêm refactor "tiện tay".
8. Verify: test cụ thể pass, full suite không regression, build sạch, kiểm tra lại scenario gốc end-to-end.
9. Nếu đã thử ≥3 fix mà vẫn lỗi mới ở chỗ khác: dừng, nghi vấn kiến trúc, escalate cho user thay vì tiếp tục đoán.

# Output
- Root cause được xác định và ghi lại rõ ràng
- Test regression fail-trước/pass-sau fix
- Toàn bộ suite pass, không bug mới phát sinh

---
name: root-cause-tracing
description: Trace lỗi ngược qua call stack/luồng dữ liệu để tìm điểm khởi phát thật, khi lỗi xuất hiện sâu trong hệ thống nhiều lớp. Use when error xảy ra ở 1 layer nhưng nghi ngờ nguyên nhân nằm ở layer khác, hoặc giá trị sai không rõ phát sinh từ đâu.
keywords: [root cause, trace, call stack, data flow, multi-layer, backward trace]
not_for: [bug đơn giản 1 file đã rõ nguyên nhân]
requires_rules: []
on_success: [tdd]
on_failure: []
---

# Purpose
Bổ trợ skill debugging khi lỗi xuyên qua nhiều component/lớp gọi — tìm điểm khởi phát giá trị/lỗi sai bằng cách lùi dần từ nơi phát hiện về nguồn, thay vì sửa tại nơi triệu chứng lộ ra.

# Inputs
- Vị trí phát hiện lỗi (file/dòng/log)
- Khả năng thêm log/instrumentation tạm thời

# Steps
1. Xác định giá trị/trạng thái sai cụ thể (không phải "nó bug" mà "biến X = null lúc Y, lẽ ra phải = Z").
2. Tìm lời gọi/nguồn tạo ra giá trị đó: ai set/pass giá trị này vào đây?
3. Lùi tiếp lên 1 lớp gọi nữa: giá trị đó được tạo/biến đổi ở đâu trước đó?
4. Lặp lại bước 3 cho tới khi chạm điểm đầu tiên giá trị sai xuất hiện (không còn lớp nào trước đó tạo ra sai).
5. Nếu hệ thống nhiều component (CI → build → sign, API → service → DB), thêm log tại mỗi boundary, chạy 1 lần để xác định chính xác component nào làm sai lệch.
6. Sửa tại điểm khởi phát, không sửa tại nơi triệu chứng lộ ra.
7. Gỡ bỏ instrumentation tạm sau khi xác nhận fix đúng (giữ lại nếu có giá trị giám sát lâu dài).

# Output
- Điểm khởi phát lỗi được xác định chính xác (file/hàm/lớp cụ thể)
- Fix áp dụng tại nguồn, không phải tại nơi phát hiện

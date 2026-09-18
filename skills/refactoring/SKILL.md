---
name: refactoring
description: Đơn giản hóa code mà không đổi hành vi, giảm độ phức tạp để dễ đọc/sửa/test hơn. Use when code chạy đúng nhưng khó đọc/khó maintain, hoặc review phát hiện complexity không cần thiết.
keywords: [refactor, simplify, clean code, complexity, readability]
not_for: [thay đổi behavior, code đã rõ ràng không cần sửa]
on_success: [code-review]
on_failure: [debugging]
requires_rules:
  - _global/solid
  - _global/clean-code
  - "{stack}/architecture"
---

# Purpose
Giảm độ phức tạp của code đã hoạt động đúng, giữ behavior y nguyên — mục tiêu là người đọc mới hiểu nhanh hơn, không phải ít dòng hơn.

# Inputs
- Code đã có test pass, cần đơn giản hóa
- Convention/pattern hiện có của project (qua requires_rules)

# Steps
0. Verify `rules/{stack}/architecture.mdc` tồn tại — nếu thiếu, dừng và hướng dẫn dev copy từ `rules/_template/`.
1. Hiểu code trước khi đụng (Chesterton's Fence): nó làm gì, ai gọi nó, vì sao viết như vậy — check git blame nếu cần.
2. Xác nhận có test bảo vệ behavior hiện tại; nếu chưa có, viết test trước (theo skill tdd).
3. Quét `_global/clean-code` (tên, hàm dài, nest, magic, DRY, comment chết) và `_global/solid` (God service, `new` infra, interface béo, `switch(type)` phình).
4. Sửa từng điểm một, chạy test sau mỗi thay đổi; nếu test fail, revert và xem lại — không gộp nhiều thay đổi không kiểm chứng.
5. Tách refactor ra khỏi feature/bugfix — không commit chung 1 thay đổi vừa refactor vừa thêm behavior mới.
6. So sánh trước/sau: bản đơn giản hóa có thực sự dễ hiểu hơn không, có phá convention project không. Nếu không tốt hơn, revert.

# Output
- Code đã đơn giản hóa, mọi test cũ pass không sửa đổi
- Diff tách riêng khỏi thay đổi feature/bugfix, dễ review
- Nợ kỹ thuật phát hiện nhưng ngoài scope lần này → log vào `templates/tech-debt-template.md` (backlog), không sửa lan man

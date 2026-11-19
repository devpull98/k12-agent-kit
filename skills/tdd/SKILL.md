---
name: tdd
description: Viết test trước khi viết code implementation. Use when bắt đầu 1 task code mới, sửa bug có test case rõ ràng, hoặc khi spec đã có acceptance criteria.
keywords: [test, tdd, unit test, acceptance criteria, write test first]
not_for: [debugging]
on_success: [progress-logging, code-review]
on_failure: [debugging]
requires_rules:
  - _global/error-handling
  - _global/solid
  - _global/clean-code
  - "{stack}/architecture"
---

# Purpose
Đảm bảo code được sinh ra có test bảo vệ, theo đúng chu trình Red-Green-Refactor.

# Inputs
- Spec hoặc acceptance criteria của task
- Rule áp dụng theo stack (đã khai báo ở requires_rules)

# Iron Law
```
KHÔNG CÓ PRODUCTION CODE NÀO KHI CHƯA CÓ 1 TEST FAIL TRƯỚC
```
Lỡ viết code trước test? **Xóa code đó**, viết test, rồi viết lại. Không giữ "để tham khảo", không "viết test bù sau".

# Steps
0. Verify `rules/{stack}/architecture.mdc` tồn tại — nếu thiếu, dừng và hướng dẫn dev copy từ `rules/_template/`.
1. Đọc BDD spec + tech design (nếu có), xác định behavior cần test (1 scenario `SC{N}` / 1 acceptance criterion mỗi vòng).
2. **RED** — viết 1 test nhỏ nhất mô tả behavior đó.
3. **Verify RED** — chạy test, xác nhận nó FAIL **đúng lý do** (assertion về behavior chưa có), không phải lỗi compile/typo/import. Test pass ngay → test sai hoặc behavior đã có: sửa test.
4. **GREEN** — viết code tối thiểu để test pass (được phép xấu, **chưa được coi là xong**). Không thêm tính năng test chưa đòi (YAGNI).
5. **Verify GREEN** — chạy test đó + test liên quan: pass, không warning mới.
6. **REFACTOR bắt buộc** trước khi đóng task: đối chiếu `_global/solid` + `_global/clean-code` + `{stack}/architecture`. God class / `new` infra / tên mơ hồ / hàm dài / magic number / nest 3+ → sửa, giữ test xanh. Không skip vì "feature nhỏ".
7. Lặp lại cho behavior tiếp theo.
8. Với bug fix (Prove-It Pattern): viết test tái hiện đúng bug trước (phải fail xác nhận bug tồn tại), rồi mới sửa code, test pass xác nhận đã fix và chặn regression.
9. Trước khi báo task xong: `verification-before-completion` — chạy full suite + build trong chính message đó.

# Rationalization — không chấp nhận

| Suy nghĩ | Thực tế |
|----------|---------|
| "Quá đơn giản, khỏi test" | Code đơn giản vẫn hỏng. Test mất 30 giây. |
| "Viết test sau cũng vậy" | Test viết sau pass ngay → không chứng minh được gì. |
| "Đã test tay rồi" | Test tay không lặp lại được, không chặn regression. |
| "Xóa code đã viết thì phí" | Sunk cost. Code chưa được test kiểm chứng là nợ. |
| "Giữ code làm tham khảo khi viết test" | Bạn sẽ viết test khớp code thay vì khớp spec. Xóa. |
| "Cần spike trước để hiểu" | Được — spike rồi **vứt**, sau đó TDD lại từ đầu (`templates/spike-template.md`). |
| "Mock hết cho nhanh" | Test mock-only kiểm mock, không kiểm behavior. Mock ở biên (I/O, external). |
| "Feature nhỏ, khỏi refactor" | Green chưa phải xong. Refactor là bước bắt buộc. |

# Output
- Test file + implementation file tương ứng
- Toàn bộ test pass, không có test bị skip/comment — có bằng chứng (lệnh + output) trong message
- Diff không vi phạm `_global/solid.mdc` và `_global/clean-code.mdc` — nợ ngoài scope ghi tech-debt + ticket, không im lặng
- Sau khi 1 task trong plan pass toàn bộ test: gọi tiếp `progress-logging` để ghi vết, không tự coi là xong khi chưa log.

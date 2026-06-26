---
name: tdd
description: Viết test trước khi viết code implementation. Use when bắt đầu 1 task code mới, sửa bug có test case rõ ràng, hoặc khi spec đã có acceptance criteria.
keywords: [test, tdd, unit test, acceptance criteria, write test first]
not_for: [debugging]
requires_rules:
  - _global/error-handling
  - "{stack}/architecture"
---

# Purpose
Đảm bảo code được sinh ra có test bảo vệ, theo đúng chu trình Red-Green-Refactor.

# Inputs
- Spec hoặc acceptance criteria của task
- Rule áp dụng theo stack (đã khai báo ở requires_rules)

# Steps
1. Đọc spec, xác định behavior cần test.
2. Viết test case mô tả behavior đó (test phải fail — Red).
3. Viết code tối thiểu để test pass (Green).
4. Refactor code, giữ test pass, đối chiếu requires_rules để không vi phạm convention.
5. Lặp lại cho behavior tiếp theo.
6. Với bug fix (Prove-It Pattern): viết test tái hiện đúng bug trước (phải fail xác nhận bug tồn tại), rồi mới sửa code, test pass xác nhận đã fix và chặn regression.

# Output
- Test file + implementation file tương ứng
- Toàn bộ test pass, không có test bị skip/comment
- Sau khi 1 task trong plan pass toàn bộ test: gọi tiếp `progress-logging` để ghi vết, không tự coi là xong khi chưa log.

---
name: brainstorming
description: Khám phá ý định người dùng và thiết kế giải pháp trước khi viết spec hoặc code. Use when bắt đầu feature/task mới, ý tưởng còn mơ hồ, hoặc chưa rõ requirement/constraint/success criteria.
keywords: [brainstorm, ideation, design, ý tưởng, requirement chưa rõ, clarify]
not_for: [bug fix có repro rõ ràng, task 1 dòng]
requires_rules: []
---

# Purpose
Biến ý tưởng thô thành thiết kế đủ rõ để viết spec, qua hội thoại hỏi-đáp tuần tự — không code, không scaffold trước khi có thiết kế được duyệt.

# Inputs
- Yêu cầu ban đầu của user (có thể mơ hồ)
- Codebase/context hiện tại của project (nếu đang sửa project có sẵn)

# Steps
1. Khảo sát context hiện tại (file, docs, commit gần đây) trước khi hỏi bất cứ gì.
2. Đánh giá phạm vi: nếu yêu cầu gộp nhiều subsystem độc lập, đề xuất tách nhỏ trước khi đi sâu.
3. Hỏi từng câu một (không hỏi dồn nhiều câu/message), ưu tiên multiple-choice, tập trung vào: mục đích, constraint, success criteria.
4. Đề xuất 2-3 hướng giải quyết kèm trade-off, có khuyến nghị rõ ràng.
5. Trình bày thiết kế theo từng phần (architecture, components, data flow, error handling, testing), xin xác nhận sau mỗi phần.
6. Tự rà soát thiết kế: không còn placeholder/TBD, không mâu thuẫn nội bộ, phạm vi đủ nhỏ cho 1 spec, không còn câu mơ hồ.
7. Bàn giao cho spec-driven-development để viết spec chính thức.

# Output
- Thiết kế đã được user duyệt (ghi lại dưới dạng tóm tắt hoặc note, không bắt buộc file riêng nếu spec-driven-development sẽ chốt lại)
- Danh sách giả định/quyết định đã chốt, sẵn sàng đưa vào spec

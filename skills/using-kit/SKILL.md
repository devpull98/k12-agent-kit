---
name: using-kit
description: Kỷ luật bootstrap của kit — BẮT BUỘC kiểm skill trước MỌI hành động (kể cả câu hỏi làm rõ). Được hook session-start nạp sẵn. Use when bắt đầu session, nhận yêu cầu mới, hoặc sắp hành động mà chưa chọn skill.
keywords: [using kit, bootstrap, chọn skill, which skill, skill nào]
not_for: [thực thi task — skill này chỉ quy định cách chọn và tuân thủ skill]
requires_rules:
  - _global/governance
on_success: []
on_failure: []
---

# Purpose
Biến skill từ "gợi ý" thành **quy trình bắt buộc**. Nếu có ≥1% khả năng một skill áp dụng cho việc đang làm → load skill đó và làm theo. Không thương lượng, không "lần này thôi".

# Thứ tự ưu tiên chỉ dẫn
1. **User** (yêu cầu trực tiếp, `CLAUDE.md`, `docs/principles.md`) — cao nhất.
2. **Kit** (skill, rule, canonical flow, governance script) — ghi đè hành vi mặc định của agent.
3. **Hành vi mặc định** của agent — thấp nhất.

User nói "bỏ qua TDD lần này" → làm theo user, ghi lý do vào `_context.md`. Agent tự thấy "không cần TDD" → **không được**.

# Steps (trước mỗi phản hồi)
1. Có work package đang mở? → đọc `docs/work/<KEY>-<slug>/_context.md` TRƯỚC, nối tiếp `next_skill`.
2. Khớp intent với `router.yaml` (hook `route-hint` đã gợi ý — vẫn tự kiểm `not_for_skills`).
3. Chọn skill theo thứ tự: **process skill trước** (brainstorming, debugging, clarify-spec) → **execution skill sau** (tdd, executing-plans, tech-docs).
   - "Làm feature X" → brainstorming trước, không nhảy vào code.
   - "Sửa bug Y" → debugging trước, không sửa đoán.
4. Load skill (Skill tool), **thông báo**: "Đang dùng skill `<name>` để <mục đích>".
5. Skill có checklist → tạo todo cho TỪNG mục, làm tuần tự.
6. Trước khi tuyên bố xong bất cứ thứ gì → `verification-before-completion`.
7. Xong skill → cập nhật state block `_context.md` (`last_skill`, `next_skill`, `phase`) theo `on_success`.

# Red flags — dừng lại, bạn đang tự biện hộ

| Suy nghĩ | Thực tế |
|----------|---------|
| "Chỉ là câu hỏi đơn giản" | Câu hỏi cũng là task. Kiểm skill. |
| "Để xem code trước đã" | Skill nói CÁCH xem. Kiểm skill trước. |
| "Cần thêm context đã rồi chọn skill" | Kiểm skill trước khi hỏi/khám phá. |
| "Việc này không cần quy trình" | Việc "đơn giản" là nơi giả định sai gây hại nhất. |
| "Skill này overkill" | Đã có skill thì dùng. Fast track có sẵn cho việc nhỏ. |
| "Mình nhớ skill này rồi" | Skill thay đổi theo version. Đọc bản hiện tại. |
| "Làm nhanh 1 cái trước đã" | Không hành động nào trước khi kiểm skill. |
| "Spec rõ rồi, khỏi BDD" | Quyết định track (standard/fast) là của user/plan, không phải cảm giác. |
| "Test pass rồi, xong" | Chưa chạy lại trong message này = chưa có bằng chứng. |

# Loại skill
- **Rigid** (tdd, debugging, verification-before-completion, governance gate): làm đúng từng bước, không "thích nghi" bỏ kỷ luật.
- **Flexible** (brainstorming, product-discovery, tech-docs): áp nguyên tắc theo ngữ cảnh.

# Output
- Mỗi task bắt đầu bằng 1 dòng: skill nào đang dùng và vì sao (hoặc "không skill nào khớp — fallback: <lý do>").

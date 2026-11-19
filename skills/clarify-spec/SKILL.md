---
name: clarify-spec
description: Quét Product Brief theo taxonomy ambiguity, hỏi tối đa 5 câu (từng câu một, có đề xuất), ghi đáp án vào spec và gỡ hết marker [NEEDS CLARIFICATION]. Use when Product Brief còn marker [NEEDS CLARIFICATION], còn từ mơ hồ ("nhanh", "dễ dùng"), hoặc trước khi viết BDD cho feature rủi ro cao.
keywords: [clarify, làm rõ, needs clarification, ambiguity, mơ hồ, câu hỏi spec, clarify spec]
not_for: [ý tưởng còn thô chưa có Product Brief — dùng brainstorming, bug có repro rõ]
requires_rules:
  - _global/sdd-gate
on_success: [bdd-specification]
on_failure: [brainstorming]
---

# Purpose
Giảm rework downstream bằng cách chốt các điểm mơ hồ **trước** BDD/tech design. Đáp án được ghi thẳng vào spec (stable truth), không nằm trong chat.

# Inputs
- Product Brief: `docs/specs/modules/<module>/<spec>.md` (anchor trong `_context.md`)
- `docs/principles.md` (nếu có)

# Steps
1. **Quét taxonomy** — đánh dấu mỗi mục `Clear | Partial | Missing`:
   1. Functional scope & hành vi (in/out of scope, user role)
   2. Domain & data model (entity, quan hệ, vòng đời trạng thái, quy mô dữ liệu)
   3. Interaction & UX (luồng chính, trạng thái lỗi/rỗng/loading)
   4. Non-functional (performance số cụ thể, security/privacy — FERPA/GDPR với dữ liệu học sinh, observability)
   5. Integration & dependency ngoài (API/service, failure mode)
   6. Edge case & xử lý lỗi (concurrency, giới hạn, rate limit)
   7. Constraint & trade-off (kỹ thuật, deadline, phương án đã loại)
   8. Thuật ngữ (glossary, từ đồng nghĩa lệch nhau)
   9. Completion signal (success criteria đo được)
   10. Placeholder & từ mơ hồ (`[NEEDS CLARIFICATION]`, TODO, "nhanh", "an toàn", "trực quan")
2. **Chọn câu hỏi** — tối đa **5**, ưu tiên theo (impact × độ bất định). Chỉ hỏi câu mà đáp án làm đổi kiến trúc, data model, test design hoặc compliance. Bỏ câu thuần style.
3. **Hỏi TỪNG câu một** (không lộ trước danh sách), mỗi câu có dòng *"Vì sao quan trọng"* và 1 trong 2 dạng:
   - **Multiple choice** (2–5 lựa chọn, bảng `| Option | Mô tả |`), nêu **Khuyến nghị: <X> — <lý do>**. User trả lời bằng chữ cái hoặc "ok".
   - **Short answer** (≤5 từ), kèm *Gợi ý: <đáp án>*.
4. **Ghi ngay sau mỗi đáp án** vào spec:
   - Thêm bullet vào `## Clarifications` → `### Session YYYY-MM-DD`: `- Q: <câu hỏi> → A: <đáp án>`.
   - Cập nhật section liên quan (Requirements, Success criteria, Boundaries, Edge cases, Glossary). Thay text mâu thuẫn, không để 2 phiên bản cùng tồn tại.
   - Xóa marker `[NEEDS CLARIFICATION: ...]` tương ứng.
   - Lưu file sau MỖI câu (tránh mất khi context bị nén).
5. **Dừng khi**: hết điểm mơ hồ quan trọng, user nói "xong/tiếp", hoặc đủ 5 câu. Không có gì đáng hỏi → nói rõ và chuyển tiếp.
6. **Báo cáo**: số câu đã hỏi, section đã sửa, bảng coverage taxonomy (Resolved / Deferred / Outstanding). Mục Outstanding còn ảnh hưởng lớn → khuyến nghị chạy lại `clarify-spec` hoặc quay về `brainstorming`.
7. Kiểm: `grep -n "NEEDS CLARIFICATION" <spec>` phải rỗng trước khi sang `bdd-specification` (gate: `scripts/validate-spec-clarity.sh`).

# Output
- Spec đã cập nhật, có section `## Clarifications`, không còn marker `[NEEDS CLARIFICATION]`
- State block `_context.md`: `last_skill: clarify-spec`, `next_skill: bdd-specification`, `phase: spec`

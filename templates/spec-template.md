# Spec: <feature-name>

<!--
Product Brief = WHAT/WHY. Không viết HOW (framework, API, schema → tech-docs).
Chỗ không suy ra được → `[NEEDS CLARIFICATION: <câu hỏi cụ thể>]` (tối đa 3), KHÔNG đoán.
Gate: scripts/validate-spec-clarity.sh FAIL nếu docs/specs/** còn marker → chạy skill clarify-spec.
-->

## Objective
<Tại sao làm cái này, giá trị mang lại, ai hưởng lợi>

## Requirements
<!-- ID ổn định FR-xxx — plan.md dùng `Covers: FR-xxx` để spec-analyze tính coverage -->
- **FR-001**: Hệ thống PHẢI <năng lực cụ thể, test được>
- **FR-002**: Người dùng CÓ THỂ <hành động>
- **FR-003**: Hệ thống PHẢI <...> [NEEDS CLARIFICATION: <câu hỏi>]

### Key entities (nếu có data)
- **<Entity>**: <ý nghĩa, thuộc tính chính — không nêu kiểu DB>

## Tech stack / commands
<Stack hiện tại (xem project-context.yaml), command build/test/run>

## Project structure
<Phần code nào sẽ bị đụng tới, module/folder liên quan>

## Code style
<1 ví dụ thật trong codebase làm chuẩn tham chiếu>

## Testing strategy
<Loại test cần (unit/integration/e2e), coverage kỳ vọng>

## Boundaries
- Always: <luôn phải làm>
- Ask first: <cần hỏi user trước khi quyết>
- Never: <không được làm>

## Success criteria
<!-- Đo được, không phụ thuộc công nghệ: "giáo viên tạo bài tập < 1 phút", không phải "API < 200ms" -->
- **SC-B1**: <tiêu chí đo được>

## Assumptions
<Default hợp lý đã chọn thay vì hỏi — để reviewer thấy và phản biện>

## Clarifications
<!-- Skill clarify-spec ghi vào đây, mỗi session 1 mục -->
### Session YYYY-MM-DD
- Q: <câu hỏi> → A: <đáp án>

## Open questions
<Câu hỏi chưa có câu trả lời, không chặn BDD — câu chặn thì dùng marker NEEDS CLARIFICATION>

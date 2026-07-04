# Few-Shot Examples Template

<!--
Few-shot examples là kỹ thuật context engineering hiệu quả nhất.
1 ví dụ thật = 500 từ instruction mơ hồ.

Khi nào cần:
- Agent đang ra output sai format dù đã có instruction
- Task có nhiều edge case cần anchor behavior cụ thể
- Output cần nhất quán giữa nhiều lần gọi (report, code gen, review)

Cấu trúc 1 example: Input → Reasoning (optional) → Output
Số lượng khuyến nghị: 1-3 examples. Quá nhiều → waste context budget.
-->

---
name: few-shot-<tên skill hoặc task>
applies_to: skills/<skill-name>/SKILL.md   # hoặc agents/<agent>.md
---

## Example 1 — Happy path (bắt buộc có)

**Context / System:**
```
<Phần system prompt ngắn gọn áp dụng cho example này>
```

**User input:**
```
<Input thực tế, càng giống production càng tốt>
```

**Expected output:**
```
<Output đúng — đây là "ground truth" agent sẽ học theo>
```

**Ghi chú (tại sao output này là đúng):**
- <lý do 1>
- <lý do 2>

---

## Example 2 — Edge case quan trọng (nên có)

**User input:**
```
<Input có điểm bất thường: thiếu field, ambiguous, scope lớn hơn dự kiến>
```

**Expected output:**
```
<Cách agent xử lý edge case — thường là hỏi lại hoặc clarify scope>
```

**Ghi chú:**
- <Lý do behavior này được chọn>

---

## Example 3 — Anti-example / Negative (tùy chọn)

<!--
Chỉ thêm khi agent hay mắc một lỗi cụ thể dù đã có instruction.
Negative example giúp anchor rõ hơn "đừng làm gì".
-->

**User input:**
```
<Input mà agent hay xử lý sai>
```

**Output SAI (đừng làm thế này):**
```
<Output sai — ghi chú rõ tại sao sai>
```

**Output ĐÚNG:**
```
<Output đúng>
```

---

## Hướng dẫn viết example chất lượng

| Nguyên tắc | Chi tiết |
|-----------|---------|
| Dùng data thật | Copy từ project thật, ẩn PII. Tránh `foo/bar` placeholder. |
| Output phải runnable | Nếu output là code — phải compile được. Nếu là markdown — phải render đúng. |
| Tránh example quá dài | Input + Output > 200 token/example → cắt bớt, giữ phần quan trọng |
| 1 example = 1 behavior | Không nhồi nhiều lesson vào 1 example |
| Cập nhật khi behavior thay đổi | Example stale = agent học hành vi cũ |

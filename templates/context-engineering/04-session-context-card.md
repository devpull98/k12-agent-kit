# Session Context Card

<!--
Dùng khi bắt đầu một session làm việc mới — đặc biệt khi:
- Tiếp tục task dở từ session trước
- Handoff giữa các engineer (dev → reviewer, dev → tester)
- Onboarding agent mới vào một task đang chạy

Điền vào đây rồi paste đầu conversation (sau system prompt).
Mục tiêu: agent hiểu đủ context trong < 1K tokens để không hỏi lại những gì đã rõ.

Nguyên tắc:
- Chỉ ghi những gì KHÔNG suy ra được từ code/git hiện tại
- Quyết định đã bị loại bỏ (và lý do) quan trọng hơn quyết định đã chọn
- Link đến file thật, không mô tả lại nội dung file
-->

---
session_type: new | continue | handoff   # chọn 1
date: YYYY-MM-DD
role: Dev | Tester | TechLead
---

## Task đang làm

**UC / Ticket:** <UC-ID hoặc BUG-XXX>
**Mô tả ngắn:** <1 câu — đang làm gì>
**Track:** standard | fast | hotfix

## Trạng thái hiện tại

**Đã xong:**
- [ ] <milestone đã pass>

**Đang làm:**
- [ ] <task hiện tại — chính xác nhất có thể>

**Bị block bởi:**
- <Nếu có: lý do block, cần ai/cái gì để unblock>

## Context không suy ra được từ code

<!--
Ví dụ: "Đã thử approach X nhưng bỏ vì Y", "Thỏa thuận với PO là bỏ field Z",
"Constraint từ infra: không được thêm index mới lên bảng orders tháng này"
-->

- <fact 1>
- <fact 2>

## Files liên quan trực tiếp

```
docs/specs/bdd/<UC-ID>.feature     # Behavior spec
docs/specs/tech-design/<UC-ID>-tech-design.md
src/.../<file-đang-sửa>
```

## Quyết định đã loại bỏ (và lý do)

| Approach đã loại | Lý do loại |
|-----------------|-----------|
| <approach A> | <lý do> |

## Handoff note (chỉ điền khi type = handoff)

**Từ:** <tên / role>
**Đến:** <tên / role>
**Việc cần làm tiếp:** <cụ thể>
**Rủi ro cần chú ý:** <nếu có>

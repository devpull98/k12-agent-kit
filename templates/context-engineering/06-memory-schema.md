# Memory Schema

<!--
Khai báo cấu trúc persistent memory cho agent trong project.

Tại sao cần memory schema:
- Agent không có memory liên session theo mặc định
- Không có schema → agent lưu gì thì lưu → khó query lại
- Có schema → memory có thể index, search, summarize đúng cách

Memory trong framework này phân 4 loại:
1. user     — thông tin về người dùng / team member
2. feedback — hành vi agent nên/không nên làm
3. project  — trạng thái, quyết định, constraint của project
4. reference— pointer đến tài nguyên external

File này: template để tạo memory entries chuẩn.
Storage location: theo Claude Code memory system hoặc docs/memory/ nếu tự quản lý.
-->

---

## Template: User Memory

```markdown
---
name: <slug>
description: <1 câu — ai, role, expertise>
metadata:
  type: user
---

**Role:** <TechLead | Dev | Tester | PO>
**Expertise:** <stack/domain mạnh>
**Work style:** <điều gì đặc biệt về cách làm việc — relevant cho agent>
**Avoid:** <điều agent không nên làm khi làm việc với người này>
```

---

## Template: Feedback Memory

```markdown
---
name: feedback-<slug>
description: <1 câu — rule gì, khi nào apply>
metadata:
  type: feedback
---

**Rule:** <hành vi cụ thể — MUST / MUST NOT>

**Why:** <lý do — incident cụ thể, preference mạnh, constraint kỹ thuật>

**How to apply:** <khi nào rule này kick in — context trigger>
```

---

## Template: Project Memory

```markdown
---
name: project-<slug>
description: <1 câu — fact gì, về phần nào của project>
metadata:
  type: project
  expires: YYYY-MM-DD   # optional — một số fact có thời hạn
---

**Fact:** <quyết định / constraint / trạng thái>

**Why:** <lý do — stakeholder, technical, business>

**How to apply:** <khi nào fact này relevant — tránh apply sai context>
```

---

## Template: Reference Memory

```markdown
---
name: ref-<slug>
description: <1 câu — resource gì, ở đâu, dùng cho việc gì>
metadata:
  type: reference
---

**Resource:** <tên resource>
**Location:** <URL, path, system>
**Purpose:** <dùng khi nào>
**Access note:** <quyền truy cập, cách authenticate nếu cần>
```

---

## Cấu trúc thư mục (nếu tự quản lý ngoài Claude Code memory)

```
docs/memory/
  MEMORY.md              # Index — tối đa 200 dòng
  user/
    <member-slug>.md
  feedback/
    <rule-slug>.md
  project/
    <fact-slug>.md
  reference/
    <resource-slug>.md
```

## MEMORY.md index format

```markdown
# Memory Index

## User
- [user-slug](user/user-slug.md) — Role, expertise summary

## Feedback
- [feedback-slug](feedback/feedback-slug.md) — Rule 1-liner

## Project
- [project-slug](project/project-slug.md) — Fact 1-liner  

## Reference
- [ref-slug](reference/ref-slug.md) — Resource 1-liner
```

## Vòng đời memory

| Loại | Review cycle | Trigger xóa |
|------|-------------|-------------|
| user | Ít thay đổi | Role change |
| feedback | Sau mỗi sprint retro | Rule không còn relevant |
| project | Mỗi milestone | Feature shipped, decision reversed |
| reference | Khi resource move | 404, access revoked |

# Command vs Skill Pattern

> Cách thiết kế command và skill để người dùng không cần nhớ workflow phức tạp.

---

## Khái niệm

| | Command | Skill |
|---|---|---|
| **File** | `.claude/commands/<name>.md` | `skills/<name>/SKILL.md` (plugin root) |
| **Ai gọi** | User gõ `/command-name` | Claude agent tự invoke |
| **Nội dung** | Entry point mỏng, orchestrate skills | Chi tiết quy trình step-by-step |
| **Discover** | Tự động (có description frontmatter) | Tự động (có frontmatter `name/description/keywords`) |

---

## Pattern: Command = Orchestrator, Skill = Executor

```
User gõ /product-discovery
        ↓
commands/product-discovery.md     ← thin wrapper
        ↓
skills/product-discovery/SKILL.md ← full process
        ↓
Chain sang skill tiếp theo theo role/context
```

---

## Cấu trúc SKILL.md (bắt buộc có frontmatter)

```markdown
---
name: ten-skill
description: Mô tả ngắn gọn. Use when <điều kiện>. (Đủ để Claude tự chọn đúng skill)
keywords: [keyword1, keyword2, ...]
not_for: [trường hợp không dùng]
---

# Skill: Tên Skill

## When to Use
...

## Steps
...
```

> ⚠️ Thiếu frontmatter → Claude Code không auto-discover skill.

---

## Cấu trúc command.md

```markdown
---
description: Mô tả ngắn cho user thấy trong autocomplete
---

## Bước 1: <skill chính>
Đọc `skills/<name>/SKILL.md` và thực hiện quy trình.
- Nếu <điều kiện A> → làm X
- Nếu <điều kiện B> → làm Y

---

## Bước 2: Chain theo role/context

**Nếu role = Dev** → dùng skill `spec-driven-development`
**Nếu role = Tester** → dùng skill `bdd-specification` → `qc-automation`
**Nếu role = TL/PO** → dùng skill `writing-plans`
**Nếu phát hiện risk** → dùng skill `performance-optimization`

Không tự nhảy bước 2 nếu user chưa confirm.
```

---

## Ví dụ thực tế: /product-discovery

```markdown
---
description: Tìm hiểu product/module → chain sang workflow phù hợp theo role
---

## Bước 1: Discovery
Đọc `skills/product-discovery/SKILL.md`.
- Nếu user chỉ định module → focus module đó
- Nếu không → hỏi: Quick Scan (15 min) hay Deep Dive (2 hours)?
Kết thúc → lưu summary vào `docs/architecture/<module>-overview.md`

## Bước 2: Chain theo role
Dev      → spec-driven-development / tech-docs
Tester   → bdd-specification → qc-automation
TL/PO    → writing-plans
Perf risk→ performance-optimization
Chỉ hiểu → Done
```

---

## Khi tạo command mới

**Checklist:**
- [ ] Tạo `skills/<name>/SKILL.md` với đầy đủ frontmatter
- [ ] Tạo `commands/<name>.md` với bước 1 (skill chính) + bước 2 (chain options)
- [ ] Test: mở session mới → skill có xuất hiện trong available skills không?
- [ ] Sync vào `E:\k12-agent-kit` nếu muốn dùng cho nhiều project

**Sync command:**
```bash
cp ".claude/commands/<name>.md" "E:/k12-agent-kit/.claude/commands/"
cp "skills/<name>/SKILL.md" "E:/k12-agent-kit/skills/<name>/"
```

---

## Lưu ý

- Skill mới chỉ xuất hiện trong available skills sau khi mở **session mới** (không phải reload)
- `description` trong frontmatter phải đủ nghĩa để Claude tự chọn đúng — thiếu nghĩa → agent chọn sai
- Command KHÔNG chứa business logic — chỉ orchestrate, delegate sang skill

---

**Last Updated:** 2026-07-04

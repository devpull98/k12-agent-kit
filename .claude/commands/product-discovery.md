---
description: Tìm hiểu product/module → phân tích → chuyển sang workflow phù hợp theo role. Quick scan (15 min) hoặc deep dive (2 hours).
---

## Bước 1: Discovery
Đọc `.claude/skills/product-discovery/SKILL.md` và thực hiện quy trình discovery.

- Nếu user chỉ định module → focus vào module đó
- Nếu không chỉ định → hỏi: Quick Scan hay Deep Dive?

Kết thúc bước 1 → lưu summary vào `docs/architecture/<module>-overview.md`

---

## Bước 2: Chuyển sang workflow theo role

Sau khi discovery xong, hỏi user muốn làm gì tiếp:

**Nếu role = Dev** hoặc user muốn bắt đầu build:
→ dùng skill `spec-driven-development` hoặc `tech-docs`

**Nếu role = Tester / QC** hoặc user muốn viết test:
→ dùng skill `bdd-specification` → `qc-automation`

**Nếu role = Tech Lead / PO** hoặc user muốn plan:
→ dùng skill `writing-plans`

**Nếu phát hiện performance risk** trong quá trình discovery:
→ dùng skill `performance-optimization` trước khi tiếp tục

**Nếu chỉ muốn hiểu, không làm gì thêm:**
→ dừng lại, báo cáo summary là đủ

---

Không tự nhảy bước 2 nếu user chưa confirm. Hỏi trước khi chuyển sang skill tiếp theo.

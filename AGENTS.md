# uniclass-workflow — Agent Integration Guide

## Folder map
- `rules/` — static knowledge (architecture, coding convention). Scoped theo `_global/` hoặc `<stack>/`.
- `skills/` — execution knowledge (process, checklist). Tham chiếu rule qua `requires_rules`, không hardcode convention.
- `workflows/` — navigation only. Map step → skill.
- `router.yaml` — intent → skill, strict-first. Nếu không match, fallback free-match (xem `fallback:` trong router.yaml).
- `config.yaml` — set `stack` cho project hiện tại (laravel/spring/golang...).

## 2 lớp discovery — đừng nhầm router.yaml là cơ chế chặn cứng

1. **Lớp native (luôn chạy, không phụ thuộc file này)**: Claude Code tự quét `description` trong
   frontmatter mọi `skills/*/SKILL.md` và liệt kê skill khả dụng cho agent ngay từ đầu session. Đây là
   tuyến phòng thủ chính — nếu `description` không tự đủ nghĩa (không đúng công thức `<verb> <object>.
   Use when <trigger>`), agent có thể chọn sai skill dù router.yaml đúng 100%.
2. **Lớp custom (chỉ chạy nếu agent đọc file này)**: `router.yaml`, `keywords`, `not_for`,
   `requires_rules` là field tự chế của uniclass-workflow — Claude Code KHÔNG tự đọc chúng. Chúng chỉ có
   tác dụng khi agent chủ động tham chiếu theo hướng dẫn dưới đây. Coi đây là lớp tinh chỉnh thêm, không
   phải cơ chế ép buộc của engine.

## Cách agent chọn skill (lớp custom)
1. Đọc `router.yaml`, so khớp keyword với intent của task.
2. Match 1 route → dùng skill đó. Match nhiều → loại theo `not_for_skills`.
3. Không match → fallback: quét `skills/*/SKILL.md`, chọn theo description, BẮT BUỘC nêu rõ lý do chọn trước khi tiến hành.
4. Resolve `{stack}` trong `requires_rules` của skill theo `config.yaml` → load đúng rule.

## Lưu ý khi thêm skill mới
- Skill mới chỉ xuất hiện trong danh sách "available skills" sau khi mở **session mới** (`/exit` rồi mở
  lại `claude`) — Claude Code không quét lại `skills/` giữa 1 session đang chạy.
- Luôn viết `description` tự đủ nghĩa trước, rồi mới thêm route vào `router.yaml` — không bao giờ làm
  ngược lại (router không cứu được description mơ hồ).

## Nguyên tắc bất biến
- Rule không chứa workflow/step-by-step.
- Skill không hardcode convention cụ thể — luôn qua `requires_rules`.
- Workflow không chứa logic quyết định theo stack hoặc rule content.

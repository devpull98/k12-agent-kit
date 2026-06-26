---
name: sprint-retro
description: Tổng hợp toàn bộ progress log và changelog trong 1 sprint thành báo cáo retro (velocity, block lặp lại, đề xuất cải thiện). Use when kết thúc sprint, cần tổng kết tiến độ nhiều feature, hoặc retro meeting cần dữ liệu thật từ log.
keywords: [retro, retrospective, sprint, tổng kết, velocity, sprint review]
not_for: [báo cáo tiến độ 1 task/feature đơn lẻ — dùng progress-logging]
requires_rules: []
---

# Purpose
Biến log rải rác của nhiều feature trong sprint thành 1 báo cáo tổng hợp có dữ liệu thật (không phải
cảm tính "sprint này ổn"), dùng cho sprint review/retro của Scrum.

# Inputs
- Toàn bộ `docs/logs/*.md` có hoạt động trong khoảng thời gian sprint
- `CHANGELOG.md` — các entry ship trong sprint
- Khoảng thời gian sprint cần tổng hợp (ngày bắt đầu/kết thúc)

# Steps
1. Liệt kê mọi file trong `docs/logs/` có task hoàn thành trong khoảng thời gian sprint.
2. Với mỗi feature: đếm số task, số task done, block đã gặp (cột "Ghi chú"/"Block" trong log), thời gian từ lúc spec được duyệt tới lúc ship (đối chiếu `docs/specs/` và `CHANGELOG.md`).
3. Đối chiếu `CHANGELOG.md` trong sprint: feature nào đã ship, feature nào rollback và lý do.
4. Gom các block/vấn đề xuất hiện ở nhiều feature — đây là tín hiệu cần cải thiện hệ thống (rule/skill/process), không phải lỗi cá nhân.
5. Copy `templates/sprint-retro-template.md`, điền đầy đủ velocity, block lặp lại, sự cố rollback, đề xuất cải thiện.
6. Đề xuất cải thiện phải cụ thể, hành động được (ví dụ: "thêm rule X vào rules/<stack>/" hoặc "task Y nên cắt nhỏ hơn"), không viết chung kiểu "cần làm tốt hơn".
7. Lưu báo cáo vào `docs/retros/<sprint-id>.md`.

# Output
- File `docs/retros/<sprint-id>.md` với velocity, block lặp lại, đề xuất cụ thể
- Dữ liệu trích từ log thật, không suy diễn cảm tính

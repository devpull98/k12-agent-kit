---
name: shipping
description: Chuẩn bị deploy production an toàn — checklist tiền triển khai, feature flag, rollout theo giai đoạn, kế hoạch rollback. Use when sắp deploy production, release feature mới cho user, hoặc cần rollback plan trước khi merge.
keywords: [ship, deploy, release, launch, rollout, rollback, production]
not_for: []
on_success: []
on_failure: [bug-flow]
requires_rules:
  - _global/security-baseline
  - _global/observability
---

# Purpose
Đảm bảo mọi lần lên production đều reversible, observable và triển khai theo từng bước — không "ship rồi cầu may".

# Inputs
- Code đã qua code-review, test pass, build sạch
- Definition of Done của project (checklist cố định, không đổi theo deadline)

# Steps
1.  **Bắt buộc kiểm tra Bug Gate (Anti-Bug Gate):** 
    *   Quét `docs/work/*/bugs.md` và các file trace TSV. 
    *   Nếu còn bất kỳ file bug nào ở trạng thái chưa sửa (`status: open/active/pending`) hoặc bất kỳ kịch bản nào trong trace TSV chưa có `qc_status: pass`, **bắt buộc phải dừng lại và không được tiến hành deploy**.
2.  Chạy pre-launch checklist: code quality (test/build/lint pass, không console.log debug), security (theo rule security-baseline), performance cơ bản, infra (env var, migration, health check).
3.  Nếu feature có rủi ro/chưa hoàn thiện 100%, bọc bằng feature flag — deploy code OFF trước, bật dần sau.
3. Xác định rollout theo giai đoạn: staging → production (flag OFF) → team/internal → canary % nhỏ → tăng dần → full. Theo dõi error rate/latency ở mỗi bước theo rule observability.
4. Viết rollback plan trước khi deploy: trigger condition cụ thể (error rate > X lần baseline), bước rollback, thời gian dự kiến.
5. Sau khi deploy: kiểm tra health check, error monitoring, latency, test thử luồng chính, xác nhận log đang chảy — trong 1 giờ đầu.
6. Nếu vượt ngưỡng rollback đã định, rollback ngay — không cố "đợi xem có tự ổn không".
7. Sau khi rollout 100% ổn định, dọn dẹp feature flag và code nhánh cũ trong vòng 2 tuần. Tạo PR theo `templates/pull-request-template.md` nếu chưa có.
8. Ngay khi rollout 100% ổn định (hoặc đã rollback), ghi 1 entry vào `CHANGELOG.md` (copy mục mới từ
   `templates/changelog-template.md` nếu file chưa có) — feature gì, thay đổi gì, có rollback không và vì sao.
   Đây là log cấp release cho team/user đọc, khác với `docs/work/<KEY>-<slug>/note.md` của `progress-logging` (log nội bộ từng task).

# Output
- Checklist pre-launch hoàn tất, rollback plan đã viết
- Deploy theo giai đoạn có giám sát, hoặc rollback đã thực hiện nếu vượt ngưỡng
- `CHANGELOG.md` đã có entry cho lần ship này

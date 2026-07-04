---
name: security-review
description: Rà soát lỗ hổng bảo mật trước khi merge hoặc release. Use when code đụng tới auth, input từ user, secret, external call, hoặc trước khi ship feature ra production.
keywords: [security, bảo mật, vulnerability, owasp, audit, secret, auth]
not_for: [code-review thông thường không liên quan auth/input/secret]
on_success: [code-review]
on_failure: [tdd]
requires_rules:
  - _global/security-baseline
---

# Purpose
Phát hiện lỗ hổng bảo mật có hệ thống trước khi code đi vào production, dựa trên checklist OWASP đã rút gọn trong rule.

# Inputs
- Diff/PR cần audit
- `rules/_global/security-baseline.mdc`

# Steps
1. Xác định vùng nhạy cảm trong diff: input từ user, auth/session, secret/credential, external call (SSRF risk), output hiển thị cho client (XSS/injection).
2. Đối chiếu từng vùng với `security-baseline.mdc` — đánh dấu Required nào bị vi phạm.
3. Với input validation: kiểm tra mọi input có whitelist/schema validate, không chỉ blacklist.
4. Với auth: kiểm tra authorization check ở đúng tầng (không chỉ check ở UI).
5. Nếu phát hiện vi phạm nghiêm trọng (secret lộ, SQL injection, broken auth): chặn merge, báo ngay, không chờ review tổng.
6. Ghi lại finding theo severity (Critical/High/Medium/Low) kèm vị trí file:line.

# Output
- Danh sách finding theo severity, có file:line cụ thể
- Quyết định: pass / cần sửa trước merge

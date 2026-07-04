---
name: trace-validation
description: Kiểm tra @trace tags trong code và test có khớp với BDD spec không. Use when trước khi merge để verify coverage, hoặc khi nghi ngờ code bị drift khỏi spec.
keywords: [trace, traceability, coverage, drift, @trace, validate trace, spec coverage]
not_for: [viết test mới — dùng tdd hoặc qc-automation, review code quality — dùng code-review]
on_success: [shipping]
on_failure: [tdd, code-review]
requires_rules:
  - _global/traceability
---

# Purpose
Đảm bảo mọi BDD scenario đều có code implement (`@trace.implements`) và test verify (`@trace.verifies`). Phát hiện GAP (scenario chưa implement) và DRIFT (code dùng version spec cũ).

# Inputs
- BDD spec files (`.feature`) — danh sách UC-ID + SC-ID
- Code files với `@trace.implements` tags
- Test files với `@trace.verifies` tags

# Steps
0. Chạy `bash scripts/validate-trace.sh` — dùng output script làm baseline, bổ sung phân tích DRIFT thủ công nếu cần.
1. **Thu thập scenarios**: Đọc tất cả `.feature` file trong `docs/specs/bdd/`, liệt kê mọi `{UC-ID}-SC{N}`.
2. **Tìm implementations**: Grep `@trace.implements` trong codebase, build mapping `SC-ID → file:line`.
3. **Tìm test coverage**: Grep `@trace.verifies` trong test files, build mapping `SC-ID → test`.
4. **Phân loại trạng thái** cho từng scenario:
   - ✅ **OK** — có implementation + có test
   - 🔴 **GAP** — có trong spec nhưng chưa có implementation hoặc chưa có test
   - ⚠️ **DRIFT** — có implementation nhưng @trace trỏ UC-ID không tồn tại trong spec hiện tại (spec đã đổi)
   - — **UNTRACKED** — code không có @trace tag nào
5. **Tạo báo cáo** theo format:

```
## Trace Validation Report — {UC-ID}

| SC-ID | Scenario | Implementation | Test | Status |
|-------|----------|----------------|------|--------|
| SC1   | Happy path | LoginService:42 | LoginServiceTest:15 | ✅ OK |
| SC2   | Wrong password | LoginService:68 | - | 🔴 GAP (no test) |
| SC3   | Account locked | - | - | 🔴 GAP (no impl) |

Coverage: 1/3 (33%)
Action required: SC2 cần test, SC3 chưa implement
```

6. **Kết luận**: Merge-ready chỉ khi tất cả scenario có trạng thái OK.

# Output
- Trace validation report (per UC-ID hoặc per domain)
- Danh sách hành động cụ thể: scenario nào cần impl, cần test, cần update @trace
- Không tự sửa code — chỉ report và suggest

# Ghi chú
- Chạy sau `qc-automation` và trước `shipping` để làm final gate.
- Nếu project chưa có @trace tags → báo cáo tất cả là UNTRACKED và hướng dẫn dev bắt đầu tag dần.

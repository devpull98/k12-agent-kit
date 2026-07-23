---
name: trace-validation
description: Kiểm tra ánh xạ traceability trong file trace TSV có khớp với BDD spec và mã nguồn thực tế không. Use when trước khi merge để verify coverage, hoặc khi nghi ngờ code bị drift khỏi spec.
keywords: [trace, traceability, coverage, drift, validate trace, spec coverage, tsv trace]
not_for: [viết test mới — dùng tdd hoặc qc-automation, review code quality — dùng code-review]
on_success: [shipping]
on_failure: [tdd, code-review]
requires_rules:
  - _global/traceability
---

# Purpose
Đảm bảo mọi kịch bản (BDD scenario) đều được đăng ký đầy đủ và hợp lệ trong file trace TSV (`docs/trace/{UC-ID}-trace.tsv`). Phát hiện GAP (scenario chưa có mapping thực thi/test) và DRIFT (file trace hoặc spec không khớp).

# Inputs
- BDD spec files (`.feature`) — danh sách UC-ID + SC-ID
- Trace TSV files (`docs/trace/{UC-ID}-trace.tsv`)

# Steps
0. Chạy `bash scripts/validate-trace.sh` — dùng output script làm baseline.
1. **Thu thập scenarios**: Đọc tất cả `.feature` file trong `docs/specs/bdd/`, liệt kê mọi `{UC-ID}-SC{N}`.
2. **Kiểm tra trace file**: Định vị file trace tương ứng `docs/trace/{UC-ID}-trace.tsv`. Nếu thiếu file → báo cáo GAP.
3. **Đối chiếu mapping**:
   - Kiểm tra xem từng scenario có dòng tương ứng trong file trace TSV hay không.
   - Kiểm tra `implements_tag` (chỉ ra `<đường_dẫn_file>::<tên_phương_thức>`) và `verifies_tag` (chỉ ra `<đường_dẫn_test>::<tên_test>`).
   - Kiểm tra xem các file vật lý và symbol khai báo có tồn tại thực tế trong codebase không.
   - Nếu một trong hai giá trị là `-` hoặc trống → báo cáo GAP (thiếu implementation hoặc thiếu test).
4. **Phân loại trạng thái** cho từng scenario:
   - ✅ **OK** — có mapping impl + mapping test hợp lệ, đồng thời `dev_selftest` và `qc_status` là `pass`.
   - 🔴 **GAP** — thiếu mapping trong TSV, file/symbol không tồn tại, hoặc chất lượng chưa pass.
   - ⚠️ **DRIFT** — scenario đã bị xóa khỏi BDD spec nhưng vẫn còn trong file trace TSV.
5. **Tạo báo cáo** theo format:

```
## Trace Validation Report — {UC-ID}

| SC-ID | Scenario | Implementation | Test | Status |
|-------|----------|----------------|------|--------|
| SC1   | Happy path | src/service/User.ts::login | tests/User.test.ts::should_login | ✅ OK |
| SC2   | Wrong password | src/service/User.ts::login | - | 🔴 GAP (no test) |
| SC3   | Account locked | - | - | 🔴 GAP (no impl) |

Coverage: 1/3 (33%)
Action required: SC2 cần bổ sung test, SC3 chưa có code logic
```

6. **Kết luận**: Merge-ready chỉ khi tất cả scenario có trạng thái OK và các quality signals pass.

# Output
- Trace validation report (per UC-ID hoặc per domain)
- Danh sách hành động cụ thể: scenario nào cần impl, cần test, cần sửa path/symbol trong TSV
- Không tự sửa code — chỉ report và đề xuất

# Ghi chú
- Chạy sau `qc-automation` và trước `shipping` để làm final gate.
- Nếu project chưa có trace TSV → báo cáo tất cả scenario là GAP và yêu cầu tạo file trace từ template.

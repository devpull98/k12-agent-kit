---
name: verification-before-completion
description: Iron law "không tuyên bố hoàn thành khi chưa có bằng chứng verify MỚI". Use when sắp nói "xong/pass/fixed/ready", trước commit/PR, trước khi đặt dev_selftest/qc_status/trace = pass, hoặc khi nhận báo cáo "DONE" từ subagent.
keywords: [verify, verification, xác minh, done, hoàn thành, bằng chứng, evidence, completion]
not_for: [thiết kế/brainstorm khi chưa có gì để verify]
requires_rules:
  - _global/governance
on_success: []
on_failure: [debugging]
---

# Purpose
Bằng chứng trước, tuyên bố sau. Không có ngoại lệ — paraphrase ("có vẻ ổn", "chắc pass") cũng tính là tuyên bố.

# Iron Law
```
KHÔNG TUYÊN BỐ HOÀN THÀNH NẾU CHƯA CHẠY LỆNH VERIFY TRONG CHÍNH MESSAGE NÀY
```

# Gate function (trước mọi tuyên bố thành công)
1. **Identify** — lệnh nào chứng minh được tuyên bố? (lấy từ `Verification:` của task trong `plan.md`)
2. **Run** — chạy lại lệnh ĐẦY ĐỦ, mới (không dùng kết quả cũ, không chạy 1 phần).
3. **Read** — đọc toàn bộ output, kiểm exit code, đếm số fail/skip.
4. **Compare** — output có thực sự chứng minh tuyên bố? Không → báo trạng thái thật kèm bằng chứng.
5. **Claim** — chỉ khi đó mới tuyên bố, **kèm bằng chứng** (lệnh + tóm tắt output).

# Bảng bằng chứng hợp lệ

| Tuyên bố | Bằng chứng cần | KHÔNG đủ |
|----------|----------------|----------|
| Test pass | Output test runner: 0 fail, 0 skip ngoài dự kiến | Lần chạy trước, "chắc pass" |
| Build OK | Lệnh build exit 0 | Lint pass |
| Bug fixed | Test tái hiện triệu chứng gốc pass | "Đã sửa code" |
| Regression test đúng | Fail khi revert fix, pass khi có fix | Chỉ pass 1 lần |
| Subagent xong | `git diff` thấy thay đổi + tự chạy verification | Report "DONE" của subagent |
| Requirement đạt | Đối chiếu từng dòng acceptance criteria / BDD scenario | Test pass chung chung |
| Governance pass | `bash scripts/governance-check.sh` exit 0 | "Đã thêm trace" |
| `dev_selftest: pass` | Full suite pass + build sạch trong message này | Pass từng test lẻ |

# Red flags — DỪNG và verify
- Dùng từ rào đón: "should", "probably", "có vẻ", "chắc là".
- Hài lòng trước khi verify ("Xong rồi!", "Perfect!").
- Sắp commit/push/tạo PR/đổi state block mà chưa chạy lệnh.
- Tin report của subagent/tool mà không tự kiểm.
- "Lần này thôi", "mệt rồi, cho qua".

# Output
- Mỗi tuyên bố hoàn thành đi kèm: `lệnh đã chạy` → `kết quả (exit code, số pass/fail)`.
- Verify fail → báo đúng trạng thái, chuyển `debugging` (on_failure), KHÔNG cập nhật state = pass.

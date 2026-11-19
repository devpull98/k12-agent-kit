---
name: executing-plans
description: Thực thi plan.md theo từng task — inline (rẻ) hoặc subagent-driven (mỗi task 1 subagent mới + review 2 tầng spec-compliance → code-quality). Có ledger chống mất context, xử lý status DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED. Use when plan đã duyệt (và spec-analyze không còn CRITICAL), cần implement nhiều task liên tiếp.
keywords: [execute plan, thực thi plan, implement plan, subagent, chạy plan, execute tasks, subagent-driven]
not_for: [plan chưa duyệt, thay đổi 1 file — dùng tdd trực tiếp]
requires_rules:
  - _global/git-safety
  - _global/sdd-gate
  - "{stack}/architecture"
on_success: [code-review]
on_failure: [debugging, writing-plans]
---

# Purpose
Đi từ plan đã duyệt tới branch sẵn sàng review mà không trôi khỏi spec. Mỗi task: implement (TDD) → review → ghi vết. Controller (agent chính) giữ context điều phối, không tự ôm code.

# Chọn mode
| Mode | Khi dùng | Chi phí |
|------|----------|---------|
| **inline** | ≤3 task, scope rõ, fast track | Rẻ — 1 lần review cuối |
| **subagent** | Standard track, ≥4 task, hoặc task chạm nhiều module | Đắt hơn — review sau MỖI task, chất lượng cao nhất |

# Setup (bắt buộc)
1. **Branch an toàn** (`rules/_global/git-safety`): KHÔNG làm trên `main/master/test`. Tạo `feat/<KEY>-<slug>` (hoặc git worktree `../<repo>-<KEY>` khi cần chạy song song nhiều package). Ghi base SHA.
2. **Baseline sạch**: chạy test suite trước khi đụng code. Baseline đỏ → dừng, báo user (không trộn lỗi cũ với lỗi mới).
3. Đọc `_context.md` → `plan.md` → spec anchor. Tạo todo cho MỖI task `T0xx`.
4. **Ledger**: dùng `docs/work/<KEY>-<slug>/note.md` (progress-logging) làm recovery record — context chat không sống qua compaction, ledger thì có.

# Vòng lặp mỗi task
1. **Dispatch implementer** (subagent mode: agent `developer`, inline: tự làm) với **task brief tối thiểu**: nội dung task, `Covers:` (FR/SC), file đụng tới, interface/quyết định liên quan, lệnh verification. KHÔNG dán cả lịch sử session; artifact lớn truyền bằng path file.
   - Implementer bắt buộc theo `tdd` (Red → Green → Refactor).
   - Task gắn `[P]` chỉ chạy song song khi không chung file; mặc định tuần tự.
2. **Implementer trả 1 trong 4 status**:
   | Status | Xử lý |
   |--------|-------|
   | `DONE` | Sang review |
   | `DONE_WITH_CONCERNS` | Đọc concern; concern về correctness/scope → xử lý trước review |
   | `NEEDS_CONTEXT` | Bổ sung đúng thông tin thiếu, dispatch lại |
   | `BLOCKED` | Thiếu context → bổ sung; task quá lớn → tách; plan sai → quay `writing-plans`. Không ép retry y nguyên |
3. **Review 2 tầng** (subagent mode: agent `code-reviewer`, diff base→head của task):
   - **Tầng 1 — Spec compliance**: làm ĐỦ và CHỈ những gì task/scenario yêu cầu? Thiếu → fix. Thừa (over-build) → bỏ.
   - **Tầng 2 — Code quality**: chỉ chạy khi tầng 1 ✅. 5 trục theo `code-review`.
   - Self-review của implementer KHÔNG thay thế review.
4. **Fix loop**: implementer sửa → reviewer review lại phạm vi đã sửa. Tối đa 3 vòng; quá → park finding kèm ruling + lý do vào ledger, báo user.
5. **Verify độc lập** (`verification-before-completion`): controller tự chạy lệnh `Verification:` của task — không tin report.
6. `progress-logging`: ghi dòng task (commit range, status, lệnh verify + kết quả). Tick todo.

# Quy tắc dừng
Chạy liên tục, KHÔNG check-in mỗi task. Chỉ dừng hỏi user khi: thao tác phá hủy/không đảo ngược, chạm security/secret, side effect ngoài branch (merge, push nhánh chung, publish), hoặc plan hỏng tới mức phải đoán. Ambiguity nhỏ → controller tự ruling, ghi ledger: *quyết định · lý do · cái giá nếu sai*.

# Chọn model (subagent mode — luôn chỉ định rõ, đừng để kế thừa model đắt)
- Task cơ học, spec rõ → model rẻ nhất (haiku).
- Integration/debug → model chuẩn (sonnet).
- Kiến trúc, final review → model mạnh nhất (opus). Fix loop vòng ≥2 → nâng model.

# Kết thúc
1. Mọi task done → **whole-branch review** (model mạnh nhất) đối chiếu toàn bộ BDD scenario: 1 đợt fix.
2. Full suite + build + `bash scripts/governance-check.sh` (verification-before-completion) → đặt `dev_selftest: pass` chỉ khi có bằng chứng.
3. Chuyển `code-review` (on_success). Không tự merge/push nhánh bảo vệ.

# Output
- Branch feature với mọi task `T0xx` done, ledger `note.md` đầy đủ
- State block: `phase: review`, `last_skill: executing-plans`, `next_skill: code-review`, `dev_selftest: pass|fail`

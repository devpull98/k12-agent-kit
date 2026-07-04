---
name: bug-flow
description: Phân loại bug và xác định hướng fix đúng. Use when tester tìm thấy lỗi sau khi chạy QC, hoặc dev nhận bug report và cần xác định root cause ở tầng nào (code, spec, env).
keywords: [bug, bug report, lỗi, classify bug, fix bug, bug flow, phân loại lỗi]
not_for: [debug lỗi kỹ thuật đang chạy — dùng debugging, trace nhiều layer — dùng root-cause-tracing]
on_success: [debugging, tdd]
on_failure: [root-cause-tracing]
requires_rules:
  - _global/traceability
---

# Purpose
Phân loại đúng loại bug → xác định ai fix, fix ở đâu → tránh sửa sai tầng hoặc sửa code khi thực ra spec sai.

# Inputs
- Mô tả bug: behavior thực tế vs expected behavior
- BDD spec liên quan (UC-ID + SC-ID)
- Code implementation (nếu cần đọc)

# Steps

## Bước 1 — Đọc spec chain
Trước khi kết luận bug ở đâu, đọc theo thứ tự:
BDD spec → (tech-design nếu có) → code → test

## Bước 2 — Phân loại (6 cases)

| Case | Chẩn đoán | Ai fix | Hành động |
|---|---|---|---|
| **1. Code bug** | Code ≠ BDD; BDD đúng | Dev | Sửa code, chạy lại dev test, re-run QC |
| **2. Spec bug** | Code đúng theo spec nhưng spec sai/thiếu scenario | Dev + PO | Cập nhật BDD spec → dev update code |
| **3. Ambiguous spec** | BDD mơ hồ, dev và tester hiểu khác nhau | PO/Dev clarify | Làm rõ `Then` → update BDD → re-implement |
| **4. Spec changed** | Spec được update sau khi code đã done | PO confirm | Bump spec version → dev review impact → update code |
| **5. Test bug** | Test sai (assert sai, setup sai) — code và spec đều đúng | Tester | Sửa test, không sửa code |
| **6. Env/Data bug** | Spec + code + test đều đúng — lỗi do config/data/infra | DevOps/Dev | Check logs, env config, data seeding |

## Bước 3 — Tạo bug report
Dùng `templates/bug-report-template.md`:
- UC-ID + SC-ID bị ảnh hưởng
- Case phân loại (1-6)
- Steps to reproduce
- Expected vs actual
- Evidence (log, screenshot, test output)

## Bước 4 — Route đến đúng người
- Case 1, 4 → Dev fix code
- Case 2, 3 → PO + Dev update spec trước, rồi dev mới fix code
- Case 5 → Tester tự fix test
- Case 6 → DevOps hoặc Dev check infra

## Bước 5 — Verify sau fix
- Dev fix xong → chạy lại `qc-automation` từ bước Run (không cần analyze lại)
- Cập nhật bug report: Open → Fixed → Closed

# Output
- Bug report với case classification + người phụ trách + trạng thái
- Không bao giờ sửa code khi chưa xác định đúng case — sai tầng sửa là lãng phí

---
name: qc-automation
description: Chạy QC pipeline 6 bước từ BDD spec đến automated test. Use when tester nhận BDD spec đã duyệt và cần thiết kế + chạy test automation, hoặc khi cần đánh giá coverage trước khi merge.
keywords: [qc, quality control, test automation, test plan, qc-analyze, qc-run, tester, kiểm thử, automation]
not_for: [dev tự viết unit test — dùng tdd skill, debug lỗi đang xảy ra — dùng debugging]
on_success: [trace-validation]
on_failure: [bug-flow]
requires_rules:
  - _global/traceability
  - "{stack}/test-patterns"
---

# Purpose
Chạy pipeline QC độc lập với dev — từ BDD spec đến automated test hoàn chỉnh. Output là `qc_status` trong trace file, tách biệt với `dev_selftest` của dev.

# Inputs
- BDD spec đã duyệt (file `.feature` với UC-ID + SC-ID)
- Tech design doc (nếu có — để hiểu API contract)
- Code đã được dev merge (hoặc branch để test)
- Stack test-patterns rules

# Steps

0. Verify `rules/{stack}/test-patterns.mdc` tồn tại — nếu thiếu, dừng và hướng dẫn dev copy từ `rules/_template/test-patterns.mdc`.

## Bước 1 — QC Analyze
- Đọc BDD spec, liệt kê tất cả scenarios (SC1, SC2...)
- Xác định scope: bao nhiêu scenario cần cover, loại test nào (unit/integration/e2e)
- Phát hiện **DOC_GAPS**: scenario mơ hồ, thiếu `Then` đủ cụ thể, missing error case
- Nếu có DOC_GAPS → stop, báo cáo cho dev/PO bổ sung spec trước khi tiếp tục

## Bước 2 — QC Plan
- Copy `templates/test-plan-template.md` → `docs/test-plans/{UC-ID}-test-plan.md`
- Điền: scenario nào → test cấp nào → priority (Critical/High/Medium/Low)
- Xác định test data cần setup
- Xác định dependencies (mock hay real service)

## Bước 3 — QC Design Test
- Viết test cases chi tiết cho từng scenario (theo stack test-patterns):
  - Test class name, method name
  - Setup / arrange
  - Action / act
  - Assertions / assert — bao gồm cả negative cases
- Mỗi test method có `@trace.verifies: {UC-ID}-SC{N}`

## Bước 4 — QC Review
- Tự review test design trước khi viết code:
  - Test có cover đúng behavior trong `Then` không?
  - Assertion có đủ cụ thể không (đừng chỉ assert status 200)?
  - Edge case có đủ không?

## Bước 5 — QC Run Test
- Chạy test theo stack runner (xem `{stack}/test-patterns`)
- Ghi kết quả: PASS / FAIL / BLOCKED
- Nếu FAIL: phân loại nguyên nhân → chuyển sang `bug-flow`
- Cập nhật `qc_status` trong trace file (nếu có)

## Bước 6 — QC Report
- Tóm tắt: tổng scenario, pass/fail/blocked, coverage %
- Liệt kê FAIL scenarios + nguyên nhân (code bug / spec bug / env issue)
- Next action: merge-ready / cần fix / cần clarify spec

# Output
- Test files với `@trace.verifies` tags
- QC Report (pass/fail/blocked breakdown)
- Danh sách bug cần tạo (nếu có) → dùng `bug-flow` để classify

# Ghi chú
- `qc_status` (do tester set) độc lập với `dev_selftest` (do dev set) — cả 2 phải pass trước khi merge.
- Không sửa code khi đang làm QC — chỉ report, dev mới sửa.

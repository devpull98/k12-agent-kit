# Plan: <feature-name>

<!-- 
Lưu tại:        docs/work/<KEY>-<slug>/plan.md
Spec gốc:       docs/specs/modules/<module>/<spec>.md
BDD spec:       docs/specs/bdd/<UC-ID>.feature
Tech design:    docs/specs/tech-design/<UC-ID>-tech-design.md
Track:          standard | fast | hotfix
Estimated size: XS (<2h) | S (<1d) | M (<3d) | L (<1w) | XL (>1w)
-->

---
uc_id: <UC-ID>
track: standard
size: M
parallel_safe: true   # true nếu các task độc lập có thể chạy song song
---

## Principles Check (gate — điền TRƯỚC task list)

<!-- Đối chiếu docs/principles.md. Vi phạm MUST mà không có justification → dừng, không lập task. -->

| Principle (docs/principles.md) | Tuân thủ? | Ghi chú |
|--------------------------------|-----------|---------|
| <MUST ...> | ✅ / ❌ | |

### Complexity Tracking (chỉ điền khi có vi phạm được chấp nhận)

| Vi phạm | Vì sao cần | Phương án đơn giản hơn đã loại vì |
|---------|-----------|-----------------------------------|

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| <rủi ro kỹ thuật> | Low/Med/High | Low/Med/High | <cách giảm thiểu> |
| <rủi ro dependency> | | | |
| <rủi ro scope creep> | | | |

**Rollback plan:**
- Trigger: <điều kiện nào cần rollback — ví dụ: error rate > 1% sau deploy>
- Action: <feature flag off / revert commit / DB migration rollback>
- Command: `<lệnh cụ thể>`
- Estimated time: <bao lâu để rollback hoàn tất>

---

## Execution Mode

<!--
sequential: task phải chạy theo thứ tự (có dependency chain)
parallel:   task độc lập, nhiều agent/dev có thể làm cùng lúc
mixed:      một số block tuần tự, một số block song song
-->

**Mode:** sequential | parallel | mixed

```
Dependency graph (chỉ điền khi mode = mixed):

  [T001] ──→ [T003]
  [T002] ──→ [T003] ──→ [T005 (deploy)]
  [T004] ──────────────→ [T005]
```

---

## Task List

<!--
Mỗi task: scope rõ ràng, 1 người / 1 agent làm được hoàn chỉnh.
ID ổn định T001, T002... (chèn thêm dùng T002a — không đánh số lại).
[P] = chạy song song được (khác file, không phụ thuộc task chưa xong).
Covers: FR/SC mà task hiện thực — skill spec-analyze tính coverage từ đây.
Steps: bước 2–5 phút theo nhịp TDD, path chính xác, không "xử lý tương tự".
Dependency: "none" nếu có thể bắt đầu ngay.
-->

### T001: <tên — động từ + danh từ>

- **Covers:** FR-001, SC1
- **Mode:** sequential after [none] | parallel with [T00X]
- **Mô tả:** <1-2 câu — làm gì, kết quả là gì>
- **File dự kiến:** `<path chính xác>` (create | modify | test)
- **Dependency:** none | T00N phải xong trước
- **Steps:**
  1. Viết test fail `<path test>::<tên test>` cho <behavior>
  2. Chạy `<lệnh>` → kỳ vọng FAIL: `<thông điệp lỗi>`
  3. Implement tối thiểu `<Class.method(signature)>`
  4. Chạy `<lệnh>` → kỳ vọng PASS
  5. Commit `<type>(<scope>): <message>`
- **Acceptance criteria:**
  - [ ] <tiêu chí 1 — đo được, không mơ hồ>
  - [ ] <tiêu chí 2>
- **Verification:** `<lệnh test/build/check cụ thể>` → <output kỳ vọng>
- **Rollback nếu fail:** <revert file / drop migration / turn off flag>

---

### T002 [P]: <tên>

- **Covers:** FR-002, SC2
- **Mode:** parallel with [T001]
- **Mô tả:**
- **File dự kiến:** `<path>`
- **Dependency:** none
- **Acceptance criteria:**
  - [ ]
- **Verification:** `<lệnh>`
- **Rollback nếu fail:**

---

### Sync checkpoint (chỉ cần khi mode = mixed)

> Chờ T001 + T002 xong trước khi bắt đầu T003+

- [ ] T001 pass verification
- [ ] T002 pass verification
- [ ] Build tổng thể sạch
- [ ] Không có regression trong test suite

---

### T003: <tên — thường là integration / wiring>

- **Covers:** SC3

- **Mode:** sequential after [T001, T002]
- **Mô tả:**
- **File dự kiến:** `<path>`
- **Dependency:** T001, T002
- **Acceptance criteria:**
  - [ ]
- **Verification:** `<lệnh>`
- **Rollback nếu fail:**

---

## Pre-merge Checklist

- [ ] `spec-analyze`: 0 CRITICAL
- [ ] Tất cả task pass verification (bằng chứng trong note.md)
- [ ] `bash scripts/governance-check.sh` → PASS
- [ ] `dev_selftest: pass` ghi vào trace TSV
- [ ] Không có TODO/FIXME chưa resolve trong code mới
- [ ] Feature flag tắt (nếu ship dần) hoặc bật đúng environment
- [ ] Rollback plan đã test (staging)

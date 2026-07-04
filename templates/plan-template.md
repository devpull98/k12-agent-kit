# Plan: <feature-name>

<!-- 
Spec gốc:       docs/specs/<file>.md
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

  [Task 1] ──→ [Task 3]
  [Task 2] ──→ [Task 3] ──→ [Task 5 (deploy)]
  [Task 4] ──────────────→ [Task 5]
```

---

## Task List

<!--
Mỗi task: scope rõ ràng, 1 người / 1 agent làm được hoàn chỉnh.
Dependency: "none" nếu có thể bắt đầu ngay.
-->

### Task 1: <tên — động từ + danh từ>

- **Mode:** sequential after [none] | parallel with [Task X]
- **Mô tả:** <1-2 câu — làm gì, kết quả là gì>
- **File dự kiến:** `<path>`
- **Dependency:** none | Task N phải xong trước
- **Acceptance criteria:**
  - [ ] <tiêu chí 1 — đo được, không mơ hồ>
  - [ ] <tiêu chí 2>
- **Verification:** `<lệnh test/build/check cụ thể>`
- **Rollback nếu fail:** <revert file / drop migration / turn off flag>

---

### Task 2: <tên>

- **Mode:** parallel with [Task 1]
- **Mô tả:**
- **File dự kiến:** `<path>`
- **Dependency:** none
- **Acceptance criteria:**
  - [ ]
- **Verification:** `<lệnh>`
- **Rollback nếu fail:**

---

### Sync checkpoint (chỉ cần khi mode = mixed)

> Chờ Task 1 + Task 2 xong trước khi bắt đầu Task 3+

- [ ] Task 1 pass verification
- [ ] Task 2 pass verification
- [ ] Build tổng thể sạch
- [ ] Không có regression trong test suite

---

### Task 3: <tên — thường là integration / wiring>

- **Mode:** sequential after [Task 1, Task 2]
- **Mô tả:**
- **File dự kiến:** `<path>`
- **Dependency:** Task 1, Task 2
- **Acceptance criteria:**
  - [ ]
- **Verification:** `<lệnh>`
- **Rollback nếu fail:**

---

## Pre-merge Checklist

- [ ] Tất cả task pass verification
- [ ] `bash scripts/governance-check.sh` → PASS
- [ ] `dev_selftest: pass` ghi vào trace TSV
- [ ] Không có TODO/FIXME chưa resolve trong code mới
- [ ] Feature flag tắt (nếu ship dần) hoặc bật đúng environment
- [ ] Rollback plan đã test (staging)

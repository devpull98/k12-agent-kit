# Tech Debt: <debt-name>

<!--
Track:          fast (thay đổi nội bộ, không đổi behavior)
Type:           code-quality | architecture | dependency | test-coverage | docs
Severity:       high (block feature) | med (slow dev) | low (cosmetic)
Estimated size: XS (<2h) | S (<1d) | M (<3d) | L (<1w)
-->

## Current State (Before)
<!-- Mô tả vấn đề hiện tại — tại sao đây là debt? Ảnh hưởng gì đến velocity? -->

## Target State (After)
<!-- Trạng thái mong muốn sau khi trả debt. -->

## Scope
**Files / modules bị ảnh hưởng:**
- 

**Behavior thay đổi:** none (nếu có → đây không còn là pure refactor, cần BDD spec)

## Risk
| Risk | Mitigation |
|------|-----------|
| Regression | Test suite phải pass trước và sau |
| Scope creep | Hard stop: nếu phát hiện behavior change → tạo ticket mới |

## Tasks

| # | Task | Acceptance Criteria | File(s) |
|---|------|-------------------|---------|
| 1 | | | |
| 2 | | | |

## Verify
- [ ] Toàn bộ existing test pass sau thay đổi
- [ ] Không có behavior change (diff output của integration test không đổi)
- [ ] Code review không có Critical/Major mới

# Test Plan — {UC-ID}: {Feature Name}

**Date:** {YYYY-MM-DD}
**Tester:** {tên}
**BDD Spec:** `docs/specs/bdd/{UC-ID}.feature`
**Status:** Draft | Approved | Executed

---

## 1. Scope

**Scenarios trong plan:**
| SC-ID | Scenario | Priority | Test type |
|-------|----------|----------|-----------|
| SC1 | {Tên scenario} | Critical | Integration |
| SC2 | {Tên scenario} | High | Unit |
| SC3 | {Tên scenario} | Medium | Integration |

**Ngoài scope:** {Liệt kê scenario hoặc edge case không test lần này + lý do}

---

## 2. Test Strategy

**Môi trường:** dev / staging / local
**Data setup:** {Mô tả data cần chuẩn bị}
**Dependencies:**
- [ ] Code đã merge vào branch test
- [ ] DB schema migration đã chạy
- [ ] Mock service: {liệt kê nếu cần}

---

## 3. Test Cases

### SC1 — {Tên scenario}
**@trace.verifies:** {UC-ID}-SC1

| # | Test case | Input | Expected | Type |
|---|-----------|-------|----------|------|
| 1 | Happy path | valid data | 200 + {response} | Integration |
| 2 | Missing field | body thiếu {field} | 400 INVALID_REQUEST | Integration |

---

### SC2 — {Tên scenario}
**@trace.verifies:** {UC-ID}-SC2

| # | Test case | Input | Expected | Type |
|---|-----------|-------|----------|------|
| 1 | ... | ... | ... | ... |

---

## 4. DOC Gaps (nếu có)
<!-- Scenario mơ hồ, thiếu Then cụ thể — cần clarify trước khi test -->
- [ ] SC{N}: "{Then}" không đủ cụ thể để assert. Cần confirm: ...

---

## 5. Results Summary
*(Điền sau khi chạy)*

| SC-ID | Pass | Fail | Blocked | Notes |
|-------|------|------|---------|-------|
| SC1 | | | | |
| SC2 | | | | |

**Overall:** {X}/{Y} passed — {status}
**Bugs found:** {BUG-ID list hoặc "none"}

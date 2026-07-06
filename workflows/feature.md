---
name: feature
---

# Feature Flow — Track-aware navigation

> **Canonical source:** `workflows/canonical-flow.md` — flow đầy đủ, gates và **Failure Recovery Map** ở đó (single source). File này CHỈ giúp chọn track ở điểm vào.

## Track selection
| Track | Khi dùng | Đánh dấu commit/PR |
|-------|----------|--------------------|
| **Standard** | business logic / API / DB / thay đổi lớn | — |
| **Fast** | copy, config, UI fix nhỏ (< 30 phút, không đổi behavior chính) | `[fast-track]` |
| **Hotfix** | production incident | `[hotfix]` |

Flow tóm tắt theo track + on-fail: xem `canonical-flow.md` (§ Full flow / Fast / Hotfix / Failure Recovery Map).

## Rule vận hành
- Agent **nhắc** user chạy `./scripts/governance-check.sh` trước merge (user tự chạy, agent không tự chạy script).
- Chỉ merge khi `dev_selftest` + `qc_status` đều pass và governance pass.

---
name: qc-flow
role: tester
---

# QC Flow — góc nhìn Tester

> **Canonical source:** `workflows/canonical-flow.md` — flow, gates và Failure Recovery Map ở đó. File này chỉ nêu phần QC.

## Điều kiện bắt đầu QC (bắt buộc đủ 3)
- BDD spec `@trace.status: approved`
- `dev_selftest: pass`
- `rules/{stack}/test-patterns.mdc` tồn tại

## qc-automation — 6 bước (chi tiết trong skill `qc-automation`)
| Bước | Nội dung | Gate |
|------|----------|------|
| 1–2 analyze | phân tích BDD, phát hiện DOC_GAPS | no DOC_GAPS |
| 3–4 design | thiết kế test case, reviewer duyệt | reviewer approve |
| 5 run | chạy automation | all pass (fail → `bug-flow`) |
| 6 report | báo cáo + cập nhật `qc_status` | — |

Sau QC: `trace-validation` → `governance-check` → merge-ready (theo canonical).

## Hai signal độc lập — cả hai pass trước merge
- `dev_selftest` — do Dev đặt
- `qc_status` — do Tester đặt

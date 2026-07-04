---
name: enterprise-flow
role: all
---

# Enterprise Flow — Multi-Agent Delivery Lifecycle

## Mục tiêu
- Chuẩn hóa một flow dùng chung cho Tech Lead/PO, Dev, Tester và mọi AI agent.
- Giữ spec là nguồn sự thật, code là kết quả triển khai có trace.
- Tách rõ hai tín hiệu độc lập: `dev_selftest` và `qc_status`.

## Delivery tracks
| Track | Khi dùng | Bắt buộc | Có thể bỏ qua |
|------|----------|----------|---------------|
| Standard | Feature có logic nghiệp vụ/API/DB | Spec + Tech Design + TDD + QC + Trace | Không |
| Fast | UI copy/config/typo, thay đổi nhỏ < 30 phút | TDD + Code Review + Trace check tối thiểu | BDD/Tech design đầy đủ |
| Hotfix | Lỗi production cần xử lý nhanh | Bug classification + test tái hiện + rollback plan + QC re-run | Discovery/PRD dài |

## Lifecycle 9 phases
| Phase | Owner | Mục tiêu | Gate |
|------|-------|----------|------|
| 0. Align context | Tech Lead/PO | Chốt scope, domain, constraints, principles | Không còn mơ hồ blocker |
| 1. Discovery/Spec | PO + Dev | BDD scenario và acceptance criteria rõ ràng | BDD approved |
| 2. Technical design | Dev/Lead | Chốt API/data model/architecture impact | Design reviewed |
| 3. Task planning | Dev | Task breakdown theo dependency + slice | Task plan hợp lệ |
| 4. Implement (TDD) | Dev | Code theo scenario với `@trace.implements` | Unit/integration pass |
| 5. Dev self-check | Dev | Xác nhận code chạy đúng mức dev | `dev_selftest: pass` |
| 6. QC automation | Tester | Xác minh behavior theo spec | `qc_status: pass` |
| 7. Trace validation | Lead/Dev | Không drift giữa spec-test-code | Không còn GAP/DRIFT blocker |
| 8. Release & feedback | Lead + Dev + Tester | Ship an toàn, đóng loop bug/scenario mới | Release checklist pass |

## Failure loop chuẩn
1. Fail ở phase nào thì quay lại phase gần nhất có thể sửa nguyên nhân gốc.
2. Mọi fail của QC được ghi vào bug/report và route về `bug-flow`.
3. Sau fix bắt buộc re-run tối thiểu từ phase gây fail trở đi.

## Definition of Done (Enterprise)
- Scenario quan trọng có đủ `@trace.implements` + `@trace.verifies`.
- `dev_selftest` và `qc_status` đều pass.
- Không còn issue Critical/Major ở code-review/security-review.
- Có artifact vận hành tối thiểu: test plan, bug report (nếu có), release note/log.

## Anti-drift operating rules
- Không merge khi spec và code mâu thuẫn mà chưa cập nhật trace.
- Thay đổi behavior phải cập nhật BDD trước hoặc cùng lúc code.
- Fast/Hotfix chỉ là rút gọn bước, không miễn trừ kiểm thử và trace tối thiểu.

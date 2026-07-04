# Project Principles (Enterprise Template)

> Mục tiêu: tạo một lớp governance ổn định cho mọi AI agent trong project.
> Cách dùng: copy thành `docs/principles.md` ở project thật và chỉnh lại theo tổ chức.

## Scope
- Áp dụng cho toàn bộ code, test, docs, CI/CD, release.
- Ưu tiên cao hơn guideline ngầm; thấp hơn yêu cầu pháp lý/compliance bắt buộc.

## MUST
- Spec-first cho thay đổi behavior: cập nhật spec/BDD trước hoặc cùng lúc code.
- Mọi thay đổi quan trọng phải có traceability (`@trace.implements`, `@trace.verifies`).
- Với feature chuẩn: cần cả `dev_selftest=pass` và `qc_status=pass` trước merge.
- Mọi bug production phải có phân loại mức độ + rollback plan trước release.
- Tất cả quyết định kiến trúc vượt baseline phải ghi rationale ngắn.

## MUST NOT
- Không merge khi còn GAP blocker ở trace validation.
- Không bỏ qua test trong hotfix nếu không có phê duyệt exception rõ ràng.
- Không thay đổi behavior "silent" mà không cập nhật artifact liên quan.
- Không tạo abstraction mới nếu chưa có lý do đo lường được.

## Delivery Tracks
### Standard
- Dùng cho thay đổi có business logic/API/DB.
- Bắt buộc đủ flow: spec -> design -> tdd -> review -> qc -> trace -> ship.

### Fast
- Dùng cho typo/copy/config/UI change nhỏ, scope rõ, rủi ro thấp.
- Vẫn phải có test phù hợp + review + trace check tối thiểu.

### Hotfix
- Dùng cho production incident.
- Bắt buộc: classify bug, repro test, fix tối thiểu, rollback note, QC focused re-run.

## Quality Gates
- Gate 1: Spec/BDD clarity (không ambiguity blocker).
- Gate 2: Tests pass + không regression trọng yếu.
- Gate 3: Code review không còn Critical/Major issue.
- Gate 4: QC pass theo scope thay đổi.
- Gate 5: Trace validation không GAP blocker.

## Security & Safety Baseline
- Không hardcode secrets/credentials.
- Input validation + error handling phải theo global rules.
- Change liên quan auth/payment/data nhạy cảm cần security review.

## Exception Log
| Date | Decision | Reason | Approved by | TTL |
|------|----------|--------|-------------|-----|
| YYYY-MM-DD | (ghi ngoại lệ) | (vì sao) | (Tech Lead/Owner) | (ngày hết hiệu lực) |

## Review Cadence
- Review hàng sprint cho các ngoại lệ còn hiệu lực.
- Review hàng tháng để cập nhật nguyên tắc khi tổ chức hoặc stack thay đổi.

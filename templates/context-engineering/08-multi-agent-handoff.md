# Multi-Agent Handoff Template

<!--
Dùng khi một agent kết thúc công việc và chuyển giao cho agent tiếp theo.

Vấn đề handoff không tốt giải quyết:
- Agent mới bắt đầu cold → hỏi lại những gì đã rõ → waste 3-5 lượt chat
- Quyết định đã reject không được truyền → agent mới đề xuất lại → rework
- Output của agent trước không được validate rõ → agent sau build trên nền không chắc

Cách dùng:
- Agent A điền handoff note khi kết thúc nhiệm vụ
- Paste handoff note này vào đầu conversation với Agent B
- Hoặc lưu vào docs/logs/<date>-<uc-id>-handoff.md để audit trail

Luồng handoff phổ biến trong framework:
  Dev (tdd/implement) → Tester (qc-automation)
  Tester (bug report) → Dev (bug-flow/debugging)
  Dev (code-review ready) → Reviewer (code-review)
  TechLead (architecture approved) → Dev (writing-plans/tdd)
-->

---
handoff_id: "<YYYY-MM-DD>-<UC-ID>-<from>-to-<to>"
from_role: Dev | Tester | TechLead | Reviewer
to_role: Dev | Tester | TechLead | Reviewer
uc_id: <UC-ID hoặc BUG-XXX>
track: standard | fast | hotfix
---

## Tóm tắt: Đã làm gì

**Skill vừa hoàn thành:** <tdd | bdd-specification | code-review | ...>

**Output artifacts:**
```
<path artifact 1>   # ví dụ: docs/specs/bdd/UC-LMS-001.feature
<path artifact 2>   # ví dụ: src/.../GradeServiceTest.java
```

**Verification đã pass:**
- [ ] <verification step 1 — từ SKILL.md đã làm>
- [ ] <verification step 2>

## Việc cần làm tiếp

**Skill tiếp theo:** <tên skill>
**Artifacts cần đọc trước khi bắt đầu:**
```
<file 1>
<file 2>
```

**Acceptance criteria của handoff này thành công:**
- <điều kiện 1 — đo được>
- <điều kiện 2>

## Context quan trọng (không có trong artifacts)

<!--
Đây là phần quan trọng nhất. Ghi những gì KHÔNG suy ra được từ code/file.
Ví dụ: "SC3 đã bị PO đồng ý bỏ", "Không test trên DB thật được vì migration chưa chạy prod"
-->

- <fact 1>
- <fact 2>

## Quyết định đã loại bỏ

| Approach đã xem xét | Lý do không chọn |
|--------------------|-----------------|
| <approach A> | <lý do> |

## Rủi ro / Điểm cần chú ý

- **[HIGH]** <rủi ro ảnh hưởng lớn nếu agent tiếp theo bỏ qua>
- **[MED]** <rủi ro vừa>
- **[LOW]** <note nhỏ>

## Open questions (agent tiếp theo cần resolve)

- [ ] <câu hỏi 1 — ai cần trả lời?>
- [ ] <câu hỏi 2>

---

## Ví dụ thực tế: Dev → Tester handoff

```markdown
---
handoff_id: 2026-07-04-UC-LMS-001-dev-to-tester
from_role: Dev
to_role: Tester
uc_id: UC-LMS-001
track: standard
---

## Đã làm gì
Skill: tdd — implement GradeService + GradeController

Output:
  src/main/java/.../GradeService.java
  src/test/java/.../GradeServiceTest.java    # unit test, 12 cases
  docs/trace/UC-LMS-001-trace.tsv            # dev_selftest = pass SC1-SC4

Verification: mvn test PASS, @trace.implements gắn đủ SC1-SC4

## Việc tiếp theo
Skill: qc-automation
Đọc trước: docs/specs/bdd/UC-LMS-001.feature, docs/specs/tech-design/UC-LMS-001-tech-design.md

Thành công khi: qc_status = pass SC1-SC4 trong trace TSV

## Context không có trong file
- SC5 (xem điểm lớp) đã được PO defer sang sprint sau — không cần cover
- Staging DB chưa có data fixture sẵn — tester cần seed trước khi chạy

## Rủi ro
- [HIGH] GradeController trả 403 khi token expired — cần test case này riêng
```

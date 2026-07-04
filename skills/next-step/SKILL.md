---
name: next-step
description: Xác định bước tiếp theo trong flow dựa trên skill vừa xong, track hiện tại và trạng thái trace. Use when user hỏi "giờ làm gì?", "bước tiếp theo là gì?", hoặc agent không chắc chắn nên chuyển sang skill nào.
keywords: [next step, tiếp theo, giờ làm gì, what next, bước tiếp, đang ở đâu, where am i, which phase]
not_for: [thực thi task cụ thể — skill này chỉ navigate, không làm việc]
requires_rules:
  - _global/governance
on_success: []
on_failure: []
---

# Purpose
Trả lời chính xác "bước tiếp theo là gì" mà không cần agent tự đọc toàn bộ workflow file — dựa trên skill vừa hoàn thành, track đang dùng, và trạng thái trace hiện tại.

# Inputs
- Skill vừa hoàn thành (hoặc output/artifact vừa tạo)
- Track hiện tại: `standard` | `fast` | `hotfix`
- Trạng thái trace file nếu có (`docs/trace/{UC-ID}-trace.tsv`)

# Lookup table — on_success routing

| Skill vừa xong | Track | Next skill |
|----------------|-------|-----------|
| product-discovery | any | brainstorming |
| brainstorming | standard | spec-driven-development |
| brainstorming | fast | writing-plans |
| spec-driven-development | standard | bdd-specification |
| spec-driven-development | fast | writing-plans |
| bdd-specification | standard (dev) | tech-docs |
| bdd-specification | standard (tester) | qc-automation |
| tech-docs | standard | writing-plans |
| writing-plans | any | tdd |
| tdd (1 task done) | any | progress-logging → tdd (task tiếp) |
| tdd (tất cả tasks done) | standard | code-review |
| tdd (tất cả tasks done) | fast | trace-validation |
| code-review (APPROVE) | standard | trace-validation |
| code-review (APPROVE) | fast | shipping |
| qc-automation (pass) | any | trace-validation |
| trace-validation (pass) | any | shipping |
| security-review | any | code-review |
| performance-optimization | any | code-review |
| refactoring | any | code-review |
| debugging | any | tdd |
| root-cause-tracing | any | tdd |
| bug-flow | hotfix | debugging → tdd |
| bug-flow | standard | debugging → tdd → code-review |
| progress-logging | any | tdd (task tiếp theo trong plan) |
| shipping | any | — (done) |
| sprint-retro | any | — (done) |

# Lookup table — on_failure routing

| Skill vừa fail | Nguyên nhân | Quay về |
|----------------|-------------|---------|
| bdd-specification | Requirement chưa rõ | spec-driven-development |
| bdd-specification | Domain chưa hiểu | product-discovery |
| tech-docs | BDD thiếu scenario | bdd-specification |
| tdd | Test fail - logic sai | debugging |
| tdd | Test fail - kiến trúc sai | refactoring → tdd |
| code-review | Critical issue | tdd |
| qc-automation | Code bug | bug-flow → tdd |
| qc-automation | Spec sai/thiếu | bug-flow → bdd-specification |
| trace-validation | GAP (no impl/test) | tdd |
| trace-validation | DRIFT (spec changed) | bdd-specification → tdd |
| shipping | Production rollback | bug-flow → hotfix track |

# Steps

1. **Xác định skill vừa xong** — hỏi nếu chưa rõ: "Bạn vừa hoàn thành skill nào?"
2. **Xác định track** — đọc từ trace file (`current_track`) hoặc hỏi: "Đang chạy standard / fast / hotfix?"
3. **Tra lookup table** theo `on_success` hoặc `on_failure`.
4. **Kiểm tra precondition** của next skill:
   - Nếu next = `tdd` → BDD spec và writing-plans đã tồn tại chưa?
   - Nếu next = `shipping` → governance-check pass chưa?
   - Nếu next = `trace-validation` → `dev_selftest` và `qc_status` đã pass chưa?
5. **Đề xuất cụ thể** — không chỉ nói tên skill, mà nói rõ:
   - Skill nào cần chạy
   - Artifact cần đọc trước
   - Lệnh verification nếu có

# Output

```
## Next Step

**Bạn vừa xong:** <skill>
**Track:** <standard|fast|hotfix>
**Bước tiếp theo:** <skill-name>

### Việc cần làm
- Đọc: <file cần đọc trước>
- Chạy: <lệnh hoặc skill>
- Verify: <điều kiện để coi là xong>

### Preconditions còn thiếu (nếu có)
- [ ] <điều kiện chưa đạt>
```

# Ghi chú
- Skill này chỉ navigate — không thực thi bất kỳ task nào.
- Nếu user chưa rõ track → hỏi trước khi lookup.
- Nếu trace file có `current_phase` → ưu tiên dùng để xác định vị trí chính xác hơn.

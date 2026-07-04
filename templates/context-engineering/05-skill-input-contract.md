# Skill Input Contract

<!--
Điền trước khi gọi một skill bất kỳ.
Mục đích: agent có đủ thông tin để chạy skill mà không hỏi lại lần 1.

Tại sao cần:
- Skill không có "memory" — mỗi lần gọi là cold start
- Thiếu input → agent đoán → output sai track
- Input đầy đủ → agent skip clarification loop → tiết kiệm 2-4 lượt chat

Cách dùng:
1. Copy phần tương ứng với skill cần gọi
2. Điền đầy đủ (bỏ trống = agent sẽ hỏi lại)
3. Paste trước khi gọi /skill hoặc describe task
-->

---

## Universal Fields (mọi skill đều cần)

```yaml
skill: <tên skill>          # brainstorming | tdd | bdd-specification | ...
uc_id: <UC-ID hoặc BUG-XXX> # nếu có
stack: <spring|laravel|...> # resolve từ project-context.yaml
track: standard | fast | hotfix
```

---

## brainstorming

```yaml
trigger: <Điều gì khiến bắt đầu brainstorm — pain point, opportunity, vague idea>
known_constraints:
  - <constraint cứng đã biết>
success_looks_like: <Kết thúc brainstorm khi nào là đủ tốt>
not_exploring: <Ý tưởng đã loại, không cần khám phá lại>
```

---

## spec-driven-development (Product Brief)

```yaml
feature_name: <tên tính năng>
objective: <Tại sao làm — business value, không phải mô tả kỹ thuật>
user_type: <Ai dùng — student | teacher | admin | ...>
acceptance_criteria_draft: |
  - <tiêu chí 1 — đo được>
  - <tiêu chí 2>
out_of_scope: <Những gì KHÔNG thuộc feature này>
deadline_pressure: none | soft | hard   # ảnh hưởng đến track chọn
```

---

## bdd-specification

```yaml
charter_file: docs/specs/<date>-<feature>.md
scenarios_to_cover:
  - <happy path>
  - <edge case 1>
  - <error case 1>
existing_bdd: <UC-ID nếu có BDD cũ cần extend, không phải viết mới>
```

---

## tdd

```yaml
spec_file: docs/specs/bdd/<UC-ID>.feature
scenario_ids:
  - SC1
  - SC2
implementation_target: <class / function / endpoint cần implement>
test_type: unit | integration | e2e
existing_tests: <path đến test file nếu đang extend>
```

---

## code-review

```yaml
pr_diff: <git diff hoặc PR URL>
spec_file: docs/specs/bdd/<UC-ID>.feature   # để verify behavior đúng spec
focus:                # bỏ trống = review tất cả 5 trục
  - correctness
  - security
known_issues: <Vấn đề đã biết, không cần report lại>
verdict_needed: true | false   # false nếu chỉ cần suggestions
```

---

## debugging

```yaml
symptom: <Điều gì xảy ra — exact error message hoặc behavior>
expected: <Đáng lẽ phải xảy ra gì>
repro_steps:
  - <step 1>
  - <step 2>
first_seen: <commit hash hoặc date nếu biết>
already_tried:
  - <approach đã thử và kết quả>
affected_files: <danh sách file nghi ngờ>
```

---

## qc-automation

```yaml
bdd_file: docs/specs/bdd/<UC-ID>.feature
qc_stack: playwright | cypress | selenium
environment: local | staging
scenarios_to_automate: all | [SC1, SC3]   # "all" nếu muốn cover hết
existing_test_plan: docs/test-plans/<UC-ID>-test-plan.md   # nếu có
```

---

## shipping

```yaml
what_ships: <tên feature / fix>
uc_ids: [UC-LMS-001, UC-LMS-002]
environment: staging → production
feature_flag: true | false
rollback_plan: <1 câu — sẽ làm gì nếu cần rollback trong 30 phút>
monitoring_ready: true | false   # đã có alert chưa
```

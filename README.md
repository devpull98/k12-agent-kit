# uniclass-workflow

Framework cho AI agent làm việc theo Spec-Driven Design, tách rõ 3 trục:

- **Rule** = static knowledge (WHAT) — coding convention, architecture theo stack
- **Skill** = execution knowledge (HOW) — process, checklist, không hardcode convention
- **Workflow** = navigation (WHEN/NEXT) — thứ tự skill được gọi, không chứa logic quyết định

## Cấu trúc
```
rules/_global/        rule áp dụng mọi project/stack
rules/<stack>/         rule riêng theo stack (laravel, spring, golang...)
skills/<name>/SKILL.md frontmatter: name, description, keywords, not_for, requires_rules
workflows/<flow>.md    step -> skill, on_fail
router.yaml            intent -> skill, strict-first, fallback free-match
config.yaml             set stack cho project hiện tại
AGENTS.md               hướng dẫn agent cách dùng router + nguyên tắc bất biến
```

## Cách dùng skill load đúng rule theo stack
`requires_rules` trong skill dùng placeholder `{stack}`, resolve theo `config.yaml` lúc session-start.
Thêm ngôn ngữ mới: chỉ tạo `rules/<stack-mới>/`, không sửa skill.

## Tránh load nhầm/thừa skill
1. Router (`router.yaml`) match intent trước — strict path.
2. Không match → fallback free-match, agent phải log lý do chọn.
3. `not_for_skills` loại bớt khi nhiều skill overlap.
4. Skill chỉ load đúng rule khai báo trong `requires_rules`, không tự quét `rules/`.

## Checklist trước khi thêm rule/skill/workflow mới
- Đúng trách nhiệm (rule/skill/workflow) không lẫn lộn?
- Có trùng nội dung file khác không?
- Rule có chứa step-by-step không (sai)?
- Skill có hardcode convention cụ thể không (sai, phải qua requires_rules)?
- Workflow có chứa logic theo stack không (sai)?
- Đã thêm vào `router.yaml` nếu là intent phổ biến chưa?

## Skill hiện có (`skills/<name>/SKILL.md`)
- `brainstorming` — khám phá ý định, thiết kế trước khi viết spec
- `spec-driven-development` — viết spec có cấu trúc trước khi code
- `writing-plans` — phân rã spec thành task nhỏ có thứ tự
- `tdd` — viết test trước implementation (Red-Green-Refactor + Prove-It Pattern cho bug fix)
- `debugging` — tìm root cause có hệ thống trước khi sửa lỗi
- `root-cause-tracing` — trace lỗi ngược qua nhiều layer/call stack
- `code-review` — review 5 trục + quy trình request/receive feedback
- `refactoring` — đơn giản hóa code không đổi behavior
- `shipping` — checklist pre-launch, feature flag, rollout, rollback

## Rule global bổ sung (`rules/_global/*.mdc`)
- `security-baseline` — input validation, secret, auth, SSRF, LLM output
- `performance-baseline` — pagination, N+1, đo trước khi tối ưu
- `observability` — structured log, correlation ID, RED metric, alert theo symptom

## Agent persona (`agents/*.md`)
- `code-reviewer` — review 5 trục, dùng cho review sâu trước merge
- `security-auditor` — audit bảo mật, threat modeling, OWASP
- `test-engineer` — thiết kế test suite, phân tích coverage gap
- `web-performance-auditor` — audit Core Web Vitals (chỉ project có frontend web)
# k12-agent-kit

# Framework Kit — Agent Integration Guide

## Folder map

| Folder | Vai trò | Nội dung |
|--------|---------|---------|
| `rules/` | **Static knowledge** — WHAT | Conventions, patterns, baselines. `_global/`, `{stack}/`, `_template/`, `_examples/` |
| `skills/` | **Execution knowledge** — HOW | Quy trình + checklist. Tham chiếu rule qua `requires_rules` |
| `workflows/` | **Navigation** — WHEN & NEXT | `canonical-flow.md` là single source of truth |
| `scripts/` | **Governance runtime** — ENFORCE | validate-trace, validate-sdd-gate, validate-stack, governance-check |
| `agents/` | **Personas** — WHO | Vai trò và output format |
| `templates/` | **Artifact scaffolds** | Spec, BDD, PR template, ... |
| `router.yaml` | **Intent routing** | intent → skill, strict-first + fallback |
| `project-context.yaml` | **Project config** | Stack, QC stack, domains, paths — copy vào root project |

## Canonical flow (đọc trước mọi task)

**Single source of truth:** `workflows/canonical-flow.md`

```
product-discovery → brainstorming → Product Brief → BDD → tech-docs → plan → tdd → review → qc → trace → ship
```

| Spec layer | Skill | Artifact |
|------------|-------|----------|
| Product Brief | spec-driven-development | `docs/specs/{date}-{feature}.md` |
| Behavior | bdd-specification | `docs/specs/bdd/{UC-ID}.feature` |
| Technical | tech-docs | `docs/specs/tech-design/{UC-ID}-tech-design.md` |

## Governance runtime (bắt buộc trước merge)

```bash
bash scripts/governance-check.sh          # all checks
bash scripts/validate-sdd-gate.sh       # code ↔ spec
bash scripts/validate-trace.sh          # BDD ↔ @trace
bash scripts/validate-stack.sh          # stack rules exist
```

Chi tiết escape hatch (fast/hotfix): `rules/_global/governance.mdc`

## Stack rules — dev tự viết per stack

Framework ship **reference stacks** (spring, laravel, golang, nodejs) + **template** (`rules/_template/`).

**`rules/_examples/`** — Convention cụ thể của từng project thật (không phải rule generic). Ví dụ: `rules/_examples/nodejs-k12-product-api/architecture.mdc` chứa convention riêng của service đó. Agent đọc file này khi làm việc với đúng project đó — không áp dụng chéo sang project khác.

Thêm stack mới:

1. Copy `rules/_template/architecture.mdc` → `rules/{stack}/architecture.mdc`
2. Copy `rules/_template/test-patterns.mdc` → `rules/{stack}/test-patterns.mdc`
3. Set `stack: {stack}` trong `project-context.yaml`
4. Chạy `bash scripts/validate-stack.sh` — phải pass

Project-specific convention (ví dụ k12-product-api) → `docs/principles.md` hoặc `rules/_examples/`, không nhét vào rule generic.

## Cách agent chọn skill

1. Đọc `router.yaml`, so khớp keyword với intent.
2. 1 route match → dùng skill đó. Nhiều match → loại theo `not_for_skills`.
3. Không match → fallback: quét `skills/*/SKILL.md`, **bắt buộc nêu lý do**.
4. Resolve `{stack}` trong `requires_rules` theo `project-context.yaml`.
5. Nếu `rules/{stack}/` thiếu file → **dừng**, hướng dẫn dev tạo từ `_template/` (không bịa convention).

## Orchestration — bước tiếp theo sau mỗi skill

Mỗi skill khai báo `on_success` và `on_failure` trong frontmatter YAML.
Sau khi skill hoàn thành, agent đọc field này để biết bước tiếp — không cần tự đọc lại workflow file.

- **Không chắc bước tiếp theo** → gọi skill `next-step` (hoặc user hỏi "giờ làm gì?")
- **on_success** → skill tiếp theo khi output đạt yêu cầu
- **on_failure** → skill cần quay lại khi output không đạt / gate fail
- **on_skip** → skip skill hiện tại (fast track) và đi thẳng sang đây

## Delivery tracks

| Track | Spec pipeline | Governance |
|-------|---------------|------------|
| Standard | Product Brief → BDD → Tech → Plan | Full gate |
| Fast | Plan rút gọn | `[fast-track]` escape SDD gate |
| Hotfix | bug-flow + repro test | `[hotfix]` escape SDD gate |

## Traceability

- Implement: `// @trace.implements: {UC-ID}-SC{N}`
- Verify: `// @trace.verifies: {UC-ID}-SC{N}`
- Signals: `dev_selftest` (dev) vs `qc_status` (tester) — cả hai pass trước merge
- Trace dir: `docs/trace/` (xem `rules/_global/traceability.mdc`)

## Nguyên tắc bất biến

- AI Agent **TUYỆT ĐỐI KHÔNG** được chủ động commit hoặc đẩy mã nguồn trực tiếp lên các nhánh bảo vệ (`master`, `main`, `test`). Mọi thay đổi bắt buộc phải được thực hiện trên nhánh tính năng mới (checkout từ nhánh chính) và đưa qua Pull Request.
- Rule không chứa workflow/step-by-step.
- Skill không hardcode convention — luôn qua `requires_rules`.
- Workflow không chứa logic theo stack — tham chiếu `canonical-flow.md`.
- Script governance là source of truth cuối — không thay bằng lời hứa trong chat.
- Skill mới chỉ xuất hiện sau session mới.

# Framework Kit — Agent Integration Guide

## Folder map

| Folder | Vai trò | Nội dung |
|--------|---------|---------|
| `rules/` | **Static knowledge** — WHAT | Conventions, patterns, baselines. Scoped theo `_global/` (mọi stack) hoặc `{stack}/` (per stack). |
| `skills/` | **Execution knowledge** — HOW | Quy trình + checklist. Tham chiếu rule qua `requires_rules`, không hardcode convention. |
| `workflows/` | **Navigation** — WHEN & NEXT | Map step → skill theo role/track (`enterprise-flow`, `dev-flow`, `qc-flow`, `feature`). |
| `agents/` | **Personas** — WHO | Định nghĩa vai trò và output format cho từng loại agent. |
| `templates/` | **Artifact scaffolds** | Markdown/feature templates để tạo artifact chuẩn. |
| `router.yaml` | **Intent routing** | intent → skill, strict-first + fallback free-match. |
| `project-context.yaml` | **Project config** | Stack, role, qc stack, domains, modules, paths. Copy vào root project thật. |

## 2 lớp discovery — đừng nhầm router.yaml là cơ chế chặn cứng

1. **Lớp native** (luôn chạy): Claude Code tự quét `description` trong frontmatter mọi `skills/*/SKILL.md`. Đây là tuyến chính — nếu `description` không đủ nghĩa, agent có thể chọn sai dù router đúng.
2. **Lớp custom** (chỉ chạy khi agent chủ động đọc file này): `router.yaml`, `keywords`, `not_for`, `requires_rules` chỉ có tác dụng khi agent tham chiếu. Coi đây là lớp tinh chỉnh, không phải engine ép buộc.

## Cách agent chọn skill
1. Đọc `router.yaml`, so khớp keyword với intent của task.
2. 1 route match → dùng skill đó. Nhiều match → loại theo `not_for_skills`.
3. Không match → fallback: quét `skills/*/SKILL.md`, chọn theo description, **bắt buộc nêu lý do** trước khi tiến hành.
4. Resolve `{stack}` trong `requires_rules` theo `project-context.yaml` → load đúng rule.

## Stack rules (`rules/{stack}/`)
Mỗi stack có các file:
- `architecture.mdc` — layer pattern, DI, naming, module structure
- `test-patterns.mdc` — cách viết test, annotations, runner command

Stack hiện có: `spring`, `laravel`, `golang`.
Thêm stack mới: tạo folder `rules/{stack}/` với tối thiểu `architecture.mdc`.

## Workflows theo role/track
- **Enterprise baseline**: `workflows/enterprise-flow.md` — lifecycle 9 phase + gate + failure loop.
- **Dev**: `workflows/dev-flow.md` — ticket → bdd-specification → tech-docs → tdd → review → ship.
- **Tester**: `workflows/qc-flow.md` — BDD spec → qc-automation → bug-flow → trace-validation.
- **Feature navigation**: `workflows/feature.md` — chọn track (standard/fast/hotfix) và next-step.

## Traceability convention
- Code implement scenario: `// @trace.implements: {UC-ID}-SC{N}`
- Test verify scenario: `// @trace.verifies: {UC-ID}-SC{N}`
- Hai signal test độc lập: `dev_selftest` (dev) vs `qc_status` (tester)
- Chi tiết: xem `rules/_global/traceability.mdc`

## Enterprise operating model
- **3 track delivery**: `standard` (đầy đủ), `fast` (thay đổi nhỏ), `hotfix` (production incident).
- **Spec-first, code-second**: behavior thay đổi phải phản ánh vào spec/BDD trước hoặc cùng lúc code.
- **Feedback loop bắt buộc**: bug/gap từ QC phải quay lại `bug-flow`, fix xong phải re-run gate bị fail.
- **DoD tối thiểu trước merge**: `dev_selftest=pass`, `qc_status=pass`, trace không GAP blocker.

## Project principles (khuyến nghị enterprise)
- Project có thể thêm `docs/principles.md` (MUST/MUST NOT riêng của tổ chức).
- Agent phải coi file này là governance layer của project; nếu vi phạm, ghi rõ exception và lý do.

## Nguyên tắc bất biến
- Rule không chứa workflow/step-by-step.
- Skill không hardcode convention — luôn qua `requires_rules`.
- Workflow không chứa logic theo stack — chỉ navigate giữa skills.
- Skill mới chỉ xuất hiện trong "available skills" sau khi mở session mới.
- Luôn viết `description` tự đủ nghĩa trước khi thêm route vào `router.yaml`.

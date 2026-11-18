# Changelog

Theo dõi thay đổi của kit `uniclass-workflow`. Format theo `templates/changelog-template.md`.
`sprint-retro` đọc file này để đối chiếu feature ship trong sprint.

## [Unreleased]

## [0.5.0] - 2026-11-18
Tổ chức tài liệu kiểu "GitHub Issues trong repo" — dựa trên khảo sát 2 project thật (k12-backend-java: 52 package, ~30 không parse được state, 39 `NOJIRA`; k12-product-api).

### Added
- `rules/_global/work-items.mdc` — mô hình work item: ID (Jira key hoặc `<PREFIX>-<NNN>`), frontmatter phẳng có enum (type/status/priority/phase), `modules` theo registry, link `fixes/relates_to/supersedes/prs`, quy ước bug 2 nơi, branch/commit chứa ID.
- `scripts/work.sh` — `new` (cấp ID, slug bỏ dấu), `set` (validate enum, tự `updated/closed`), `index` (board `docs/work/INDEX.md`: đang chạy + stale, bug đang mở, backlog, lịch sử theo module), `list`, `history <module|ID> [--git]`, `migrate [--apply]` (dry-run mặc định; map type/status/module/ngày từ git; gợi ý xử lý `docs/plans/*`, report trong `docs/architecture/`).
- `scripts/validate-work-items.sh` (gắn vào `governance-check.sh`) — frontmatter/enum/ID trùng/module lạ/closed; cấm file mới trong thư mục legacy; WARN stale >14 ngày và `INDEX.md` lỗi thời. `work_items_strict: false` cho giai đoạn migrate.
- `templates/modules.template.yaml`, skill `work-tracker`, route mới.
- Hook `prepare-commit-msg`: tự thêm trailer `Work-Item: <ID>` từ branch `<type>/<ID>-<slug>`.

### Changed
- `templates/_context.template.md`: frontmatter thay state block (ship gate đọc được cả 2). `bug-report-template.md`: heading `## <ID>-B<n>` + `Status/Severity` máy đọc được.
- Skill `progress-logging`, `bug-flow`, `shipping`, `spec-driven-development`, `sprint-retro`, `next-step`, `onboarding`, `using-kit` dùng `work.sh` thay vì sửa tay.
- Hook `route-hint`: chỉ hiện item đang chạy (tối đa 5) + item của branch hiện tại, thay vì mọi package chưa `done`.
- Reference example `UC-LMS-001` chuyển sang frontmatter; thêm `docs/modules.yaml`, `docs/work/INDEX.md`.

### Fixed
- Hook `session-start`/`route-hint` đọc `project-context.yaml`, `docs/work`, `docs/principles.md` từ **plugin root** thay vì project đang mở → nay dùng `CLAUDE_PROJECT_DIR` (fallback plugin root).
- `route-hint` fallback không-jq bẹp xuống dòng.

### ⚠️ BREAKING (consumer)
- `governance-check` thêm gate **Work items**: package thiếu frontmatter / module không có trong `docs/modules.yaml` → FAIL. Lộ trình: tạo `docs/modules.yaml` → `work_items_strict: false` → `bash scripts/work.sh migrate` (duyệt) → `--apply` trên nhánh riêng → bỏ `work_items_strict`.

## [0.4.0] - 2026-11-18
Tham chiếu: obra/superpowers (kỷ luật thực thi) + github/spec-kit (chất lượng spec).

### Added
- Skill `using-kit` — bootstrap "kiểm skill trước mọi hành động", bảng red flags; hook `session-start` nạp sẵn (chạy lại sau compaction).
- Skill `verification-before-completion` — iron law: không tuyên bố xong khi chưa chạy lệnh verify trong message; bảng bằng chứng hợp lệ cho `dev_selftest`/governance.
- Skill `clarify-spec` — quét 10 nhóm ambiguity, ≤5 câu hỏi từng câu một có khuyến nghị, ghi `## Clarifications` vào spec, gỡ marker `[NEEDS CLARIFICATION]`.
- Skill `spec-analyze` — phân tích read-only Brief ↔ BDD ↔ Tech ↔ Plan ↔ principles (6 pass, severity, coverage FR/SC→Task) + requirement-quality checklist.
- Skill `executing-plans` — thực thi plan inline hoặc subagent-driven, review 2 tầng (spec compliance → code quality), status DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED, ledger, chọn model.
- Skill `writing-skills` — contract skill của kit + pressure-test (TDD cho skill).
- Script `validate-spec-clarity.sh` (gắn vào `governance-check.sh`): FAIL nếu `docs/specs/**` còn `[NEEDS CLARIFICATION]` ngoài HTML comment; WARN với `docs/work/**`.

### Changed
- Canonical flow: `Brief → clarify → BDD → tech → plan → analyze → executing-plans → review…`; thêm bảng "Kỷ luật xuyên suốt" + failure map cho gate mới.
- `tdd`: iron law (code trước test → xóa), verify RED đúng lý do, bảng rationalization.
- `debugging`: iron law "không sửa khi chưa có root cause"; verify regression test fail-khi-revert.
- `writing-plans`: Principles Check gate, task ID `T0xx`, marker `[P]`, `Covers: FR/SC`, bước 2–5 phút; `on_success` → `spec-analyze`.
- `spec-driven-development`: requirement `FR-xxx`, chỉ WHAT/WHY, marker `[NEEDS CLARIFICATION]` thay vì đoán; `on_success` → `clarify-spec | bdd-specification`.
- `code-review`: review 2 tầng (spec compliance trước, quality sau) + tự verify trước Approve.
- `brainstorming`: hard gate không code trước khi thiết kế được duyệt. `progress-logging`, `shipping`: bắt buộc bằng chứng verify mới.
- Template `spec-template.md` (Requirements, Assumptions, Clarifications), `plan-template.md` (Principles Check, Complexity Tracking, task T0xx/[P]/Covers/Steps).
- Router: 5 route mới; `next-step` lookup table đồng bộ.

### ⚠️ BREAKING (consumer)
- `governance-check.sh` thêm gate **Spec clarity** — spec đã merge còn `[NEEDS CLARIFICATION]` sẽ FAIL. Xử lý: chạy `clarify-spec`, hoặc tạm `GOVERNANCE_SKIP=1`.

## [0.3.0] - 2026-07-06
### Added
- Validate command path trong `validate-skill-graph.sh` (section 5): `commands/*.md` phải trỏ file tồn tại, cấm `.claude/skills/` — chặn tái diễn lỗi command path chết.
- Workflow drift-guard: role-view workflow phải tham chiếu `canonical-flow.md`.
- `CHANGELOG.md` làm input thật cho `sprint-retro`.
- 2 agent persona: `solution-architect` (thiết kế/ADR) và `orchestrator` (điều phối đa domain, delegate qua Task) — tổng 9 persona.

### Changed
- Bump plugin `0.2.0 → 0.3.0`.
- Mỏng hóa 4 role-view workflow (dev/enterprise/qc/feature): bỏ phần flow/gate/failure-map trùng, single-source về `canonical-flow.md`. Sửa drift thật (code-review fail: role-view cũ nói `refactoring`, canonical nói `tdd`).

### ⚠️ BREAKING (consumer)
- **`validate-stack.sh`: thiếu `project-context.yaml` hoặc `stack:` rỗng → FAIL** (trước chỉ WARN). Đóng lỗ hổng onboarding, nhưng **project chưa có `project-context.yaml` sẽ bắt đầu fail `governance-check`**.
  - **Cách xử lý:** tạo `project-context.yaml` ở root (chạy skill `onboarding`), hoặc tạm `GOVERNANCE_SKIP=1`.

### Rollback note
- Trigger rollback: gate `project-context.yaml` chặn nhầm CI/consumer hợp lệ.
- Đã rollback: no. Escape: `GOVERNANCE_SKIP=1`.

## [0.2.0] - 2026-07-06
### Added
- `commands/` ở plugin root: `feature`, `product-discovery` giờ do plugin phân phối (tự tới project cài plugin, hết cần copy tay).
- Reference example đầy đủ vòng đời theo Work Package: `docs/work/UC-LMS-001-teacher-create-assignment/` (ship-ready, governance verify được).
- Wire 4 template trước đây orphan (migration-plan, spike, tech-debt, few-shot) vào skill/router.
- Khai báo `docs/retros/` trong `rules/_global/doc-scoping.mdc`.

### Changed
- Bump plugin `0.1.0 → 0.2.0` để `/plugin update` nhận diện.
- `docs/README.md` + `docs/command-skill-pattern.md` đồng bộ về mô hình Work Package + layout plugin (`skills/`, `commands/` ở root).

### Fixed
- Command `/product-discovery` trỏ path chết `.claude/skills/...` → `skills/product-discovery/SKILL.md`.
- Ref chết `config.yaml` trong `spec-template.md` → `project-context.yaml`.
- Di dời reference example khỏi layout legacy (`docs/bugs|logs|test-plans`) sang `docs/work/` cho khớp rule kit tự enforce.

## [0.1.0] - 2026-07-03
### Added
- Bộ khung Rule / Skill / Workflow + router intent→skill, scoped theo tech stack.
- Governance runtime: `validate-sdd-gate`, `validate-trace`, `validate-stack`, `governance-check`.
- Enterprise flow, canonical-flow, delivery tracks (standard/fast/hotfix), branch protection hook.

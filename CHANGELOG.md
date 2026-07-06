# Changelog

Theo dõi thay đổi của kit `uniclass-workflow`. Format theo `templates/changelog-template.md`.
`sprint-retro` đọc file này để đối chiếu feature ship trong sprint.

## [Unreleased]

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

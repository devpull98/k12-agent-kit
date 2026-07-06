# Changelog

Theo dõi thay đổi của kit `uniclass-workflow`. Format theo `templates/changelog-template.md`.
`sprint-retro` đọc file này để đối chiếu feature ship trong sprint.

## [Unreleased]

## [0.2.0] - 2026-07-06
### Added
- `commands/` ở plugin root: `feature`, `product-discovery` giờ do plugin phân phối (tự tới project cài plugin, hết cần copy tay).
- Reference example đầy đủ vòng đời theo Work Package: `docs/work/UC-LMS-001-teacher-create-assignment/` (ship-ready, governance verify được).
- Governance coverage: gate cứng cho `project-context.yaml` (thiếu file/stack → FAIL), validate command path, workflow drift-guard trong `validate-skill-graph.sh`.
- Wire 4 template trước đây orphan (migration-plan, spike, tech-debt, few-shot) vào skill/router.
- Khai báo `docs/retros/` trong `rules/_global/doc-scoping.mdc`.

### Changed
- Bump plugin `0.1.0 → 0.2.0` để `/plugin update` nhận diện.
- `docs/README.md` + `docs/command-skill-pattern.md` đồng bộ về mô hình Work Package + layout plugin (`skills/`, `commands/` ở root).

### Fixed
- Command `/product-discovery` trỏ path chết `.claude/skills/...` → `skills/product-discovery/SKILL.md`.
- Ref chết `config.yaml` trong `spec-template.md` → `project-context.yaml`.
- Di dời reference example khỏi layout legacy (`docs/bugs|logs|test-plans`) sang `docs/work/` cho khớp rule kit tự enforce.

### Rollback note
- Trigger rollback: `/plugin update` gây lỗi load ở consumer, hoặc gate `project-context.yaml` chặn nhầm CI hợp lệ.
- Đã rollback: no. Escape gate mới: `GOVERNANCE_SKIP=1`.

## [0.1.0] - 2026-07-03
### Added
- Bộ khung Rule / Skill / Workflow + router intent→skill, scoped theo tech stack.
- Governance runtime: `validate-sdd-gate`, `validate-trace`, `validate-stack`, `governance-check`.
- Enterprise flow, canonical-flow, delivery tracks (standard/fast/hotfix), branch protection hook.

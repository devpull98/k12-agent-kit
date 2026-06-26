# Hướng dẫn dùng uniclass-workflow cho developer

## 1. Framework này làm gì
uniclass-workflow là 1 plugin Claude Code ép agent làm việc theo Spec-Driven Design: không code khi
chưa có spec được duyệt (xem `rules/_global/sdd-gate.mdc`), và tách rõ 3 loại kiến thức để agent không
load nhầm/load thừa context:

| Loại | Trả lời câu hỏi | Nằm ở đâu |
|---|---|---|
| Rule | Project này phải làm như thế nào? | `rules/_global/`, `rules/<stack>/` |
| Skill | Làm task này theo quy trình nào? | `skills/<name>/SKILL.md` |
| Workflow | Sau bước này làm gì tiếp? | `workflows/<flow>.md` |

## 2. Bắt đầu 1 project mới — checklist

Làm đúng thứ tự, đừng nhảy bước:

1. **Cài plugin vào project**
   - Copy thư mục `uniclass-workflow/` (hoặc symlink) vào root project, hoặc cài như Claude Code plugin qua `.claude-plugin/plugin.json`.
2. **Chọn stack**
   - Mở `config.yaml`, set `stack:` đúng ngôn ngữ project (`laravel` / `spring` / `golang`, hoặc tạo stack mới — xem mục 4).
   - Nếu project polyglot (nhiều service, nhiều ngôn ngữ): đặt 1 `config.yaml` riêng theo từng service/module, không dùng 1 `stack` chung cho cả repo.
3. **Kiểm tra rule đã đủ chưa**
   - Đọc `rules/<stack>/architecture.mdc` có sẵn — nếu project có convention riêng (ví dụ chuẩn đặt tên DB, chuẩn API response), thêm file rule mới trong `rules/<stack>/` trước khi code, không để skill tự bịa convention.
4. **Tạo khung thư mục lưu vết** (nếu project chưa có)
   ```
   docs/specs/      # spec từng feature
   docs/plans/       # plan từng feature
   docs/logs/        # progress log từng feature
   CHANGELOG.md      # copy từ templates/changelog-template.md
   ```
5. **Mở Claude Code trong project**
   - Hook `session-start` tự đọc `AGENTS.md` + `stack`, inject vào context — không cần làm gì thêm.
6. **Bắt đầu feature đầu tiên bằng `brainstorm`**
   - Không viết code ngay cả khi ý tưởng "có vẻ rõ" — đi qua `brainstorm → spec → plan` trước (xem mục 3) để có artefact spec/plan làm chuẩn cho toàn project sau này (coding style, boundaries...).
7. **Xác nhận gate đang hoạt động**
   - Thử yêu cầu agent code thẳng 1 feature lớn mà chưa có spec — agent phải dừng lại và yêu cầu qua `spec-driven-development` trước (theo `rules/_global/sdd-gate.mdc`). Nếu agent code luôn không hỏi, kiểm tra lại `AGENTS.md`/hook có load đúng không.

## 3. Quy trình làm 1 feature mới (gate bắt buộc)
```
brainstorm → spec → plan → tdd → review → ship
```
Xem chi tiết step → skill ở `workflows/feature.md`. Mỗi bước phải có artefact xác nhận xong (file spec
duyệt, file plan duyệt, test pass, review pass) mới qua bước sau — đây là **gate**, không phải gợi ý.

- Task < 30 phút, scope tự rõ (fix 1 dòng, đổi config): được bỏ qua spec, đi thẳng `tdd`/implement.
- Task lớn hơn: bắt buộc qua `spec-driven-development` trước, dùng `templates/spec-template.md`.

## 4. Dùng theo từng ngôn ngữ

### Laravel
- `stack: laravel` trong `config.yaml`.
- Rule áp dụng: `rules/laravel/architecture.mdc` (Controller→Service→Repository, không query Eloquent ngoài Repository).
- Khi viết code mới, agent tự load rule này qua `requires_rules: ["{stack}/architecture"]` trong skill `tdd`, `spec-driven-development`.
- Nếu project có convention riêng ngoài architecture (ví dụ validation, queue, event) — thêm file mới trong `rules/laravel/`, ví dụ `rules/laravel/validation.mdc`, theo đúng format Purpose/Required/Forbidden/Examples.

### Spring (Java/Kotlin)
- `stack: spring`.
- Rule áp dụng: `rules/spring/architecture.mdc` (Controller→Service→Repository, DTO riêng, `@Transactional` ở Service).
- Thêm rule riêng nếu cần: `rules/spring/exception-handling.mdc`, `rules/spring/testing.mdc`...

### Golang
- `stack: golang`.
- Rule áp dụng: `rules/golang/architecture.mdc` (Handler→UseCase→Repository qua interface, error wrap context).
- Thêm rule riêng nếu cần: `rules/golang/concurrency.mdc`, `rules/golang/error-handling.mdc`...

### Ngôn ngữ/stack mới chưa có (ví dụ Node.js, .NET)
1. Tạo `rules/<stack-mới>/architecture.mdc` theo đúng format 4 mục (Purpose/Required/Forbidden/Examples) — copy 1 file rule có sẵn làm mẫu.
2. Set `stack: <stack-mới>` trong `config.yaml` của project đó.
3. Không cần sửa skill nào — mọi skill dùng `{stack}` placeholder sẽ tự resolve.

## 5. Skill hiện có — dùng khi nào

| Skill | Dùng khi |
|---|---|
| `brainstorming` | Ý tưởng/feature chưa rõ, cần khám phá hướng trước khi viết spec |
| `spec-driven-development` | Bắt đầu feature mới, cần spec được duyệt |
| `writing-plans` | Spec đã duyệt, cần cắt task breakdown |
| `tdd` | Viết code có test, theo Red-Green-Refactor |
| `progress-logging` | Sau mỗi task pass test — ghi vết + báo tiến độ |
| `debugging` | Có lỗi cụ thể cần sửa |
| `root-cause-tracing` | Lỗi xuyên nhiều layer, cần trace ngược |
| `code-review` | Trước khi merge PR |
| `security-review` | Code đụng auth/input/secret/external call |
| `performance-optimization` | Có báo cáo chậm, cần đo và tối ưu có dữ liệu |
| `refactoring` | Đơn giản hóa code, không đổi behavior |
| `shipping` | Chuẩn bị deploy production |
| `sprint-retro` | Kết thúc sprint, cần tổng hợp velocity/block từ nhiều feature |

Agent không tự chọn skill cảm tính — nó tra `router.yaml` theo keyword trước (xem `AGENTS.md` mục
"Cách agent chọn skill"). Nếu bạn thấy agent chọn sai skill liên tục cho 1 loại task, thêm route mới
vào `router.yaml` thay vì sửa description skill.

## 6. Thêm skill mới khi project cần

### Agent "hiểu" skill mới qua 2 lớp khác nhau (đọc kỹ trước khi viết skill)
- **Lớp native** (Claude Code tự làm, không cần bạn cấu hình gì): quét `description` trong frontmatter
  mọi `SKILL.md`, tự liệt kê skill khả dụng. Đây là tuyến chính — `description` phải tự đủ nghĩa.
- **Lớp custom** (do uniclass-workflow tự định nghĩa, chỉ chạy nếu agent đọc `AGENTS.md`/`router.yaml`):
  `keywords`, `not_for`, `requires_rules` — chỉ là tinh chỉnh thêm, KHÔNG phải cơ chế engine ép buộc.
- Sau khi tạo skill mới, phải mở **session mới** (`/exit` rồi `claude` lại) — skill không tự xuất hiện
  giữa session đang chạy.

Khi gặp 1 loại task lặp lại nhiều lần mà chưa có skill nào khớp (ví dụ: viết migration DB, viết API
documentation, xử lý queue job...), tạo skill mới theo 5 bước:

1. Tạo `skills/<ten-skill>/SKILL.md` với frontmatter bắt buộc:
   ```yaml
   ---
   name: <ten-skill>
   description: <verb> <object>. Use when <trigger cụ thể>.
   keywords: [<từ khóa match router>]
   not_for: [<skill dễ bị nhầm, nếu có>]
   requires_rules:
     - "{stack}/<rule-can-thiet>"   # chỉ ghi nếu skill phụ thuộc convention theo ngôn ngữ
   ---
   ```
2. Viết nội dung theo 4 mục: `# Purpose`, `# Inputs`, `# Steps`, `# Output` — không vượt 150 dòng.
3. **Không nhúng convention cụ thể vào Steps** — nếu thấy mình đang viết "trong Laravel thì làm X", dừng
   lại, tách phần đó ra rule riêng trong `rules/<stack>/`, rồi skill chỉ reference qua `requires_rules`.
4. Thêm 1 route vào `router.yaml`:
   ```yaml
   - intent: "<mô tả intent>"
     keywords: [<keyword>]
     skill: <ten-skill>
     confidence: strict
   ```
5. Nếu skill này là 1 bước trong flow có sẵn (feature/bugfix), thêm vào `workflows/<flow>.md`; nếu là
   skill độc lập (không thuộc flow nào), không cần.

### Checklist trước khi merge skill mới (đối chiếu README.md mục Checklist)
- Description có dạng `<verb> <object>. Use when ...` không?
- Có convention cứng nhúng trong Steps không (phải chuyển ra rule)?
- Đã thêm route vào `router.yaml` chưa?
- Có skill nào overlap cần khai báo `not_for` không?

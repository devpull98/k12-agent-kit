# Quickstart — plugin `uniclass-workflow`

> **Stack-agnostic** — dùng cho project bất kỳ (Spring / Laravel / Go / Node...). Cài chi tiết: [INSTALL.md](INSTALL.md).

Plugin cài **1 lần / máy**, dùng chung mọi project. Mỗi project chỉ cần **1 file config**. Đừng lẫn 2 việc này.

---

## A. Máy mới (1 lần / máy)

| # | Việc | Ghi chú |
|---|------|---------|
| 1 | Cài **Git Bash** ([Git for Windows](https://git-scm.com/download/win)) hoặc bash sẵn (macOS/Linux) | Hook `SessionStart` chạy `bash` — bắt buộc |
| 2 | Cài **jq** (`winget install jqlang.jq` / `brew install jq` / `apt install jq` → mở lại shell) | Hook inject `AGENTS.md`; thiếu vẫn chạy fallback |
| 3 | Cài **Claude Code** | |
| 4 | `/plugin marketplace add devpull98/k12-agent-kit` | Trong Claude Code |
| 5 | `/plugin install uniclass-workflow` | Lưu `~/.claude` → global |
| 6 | `/exit` → `claude` (restart) | Cho `SessionStart` hook chạy. Check: `/plugin` thấy plugin enabled |

Thiếu Git Bash/jq → plugin cài xong vẫn **không hoạt động** (hook fail âm thầm, agent code thẳng, bỏ qua spec).

---

## B. Project mới (mỗi project — KHÔNG cài lại plugin)

Plugin đã global. Chỉ cần bật cho project:

**1. Tạo `project-context.yaml` ở root** — hook đọc file này để chọn `rules/<stack>/`:
```yaml
stack: spring          # spring | laravel | golang | nodejs | <stack-của-bạn>
test_runner: junit5    # junit5 | phpunit | jest | vitest | go-test | pytest — để trống = suy từ stack
```

**2. `CLAUDE.md`** — mô tả build/test command + convention riêng của project (nguồn context chính cho agent).

**3. Thư mục tài liệu (Work Package model — xem `rules/_global/doc-scoping.mdc`):**
```
docs/work/            # 1 task = 1 folder <KEY>-<slug>/ : _context, plan, checklist, note, bugs
docs/specs/modules/   # stable truth per module + _index.md
```

**4. Nếu stack KHÔNG có sẵn** (`rules/<stack>/` chưa tồn tại):
- Copy `rules/_template/architecture.mdc` + `test-patterns.mdc` → `rules/<stack>/`, điền convention.
- Chạy `bash scripts/validate-stack.sh` — phải pass.
- Convention RIÊNG của project → `CLAUDE.md` / `docs/principles.md` / `rules/_examples/<project>/`, KHÔNG nhét vào rule generic.

**5. Restart Claude Code trong project → smoke test:** gõ yêu cầu mơ hồ (vd "thêm login OTP") → agent phải tự trigger `brainstorming` → `spec-driven-development`, **không code thẳng**. Nếu code thẳng → hook chưa chạy (check bash trong PATH, `/plugin` enabled).

---

## Tóm gọn

| Tình huống | Việc |
|---|---|
| **Máy mới** | Git Bash/bash + jq + Claude Code → `/plugin install uniclass-workflow` |
| **Project mới (cùng máy)** | Chỉ thêm `project-context.yaml` + `CLAUDE.md` (+ `rules/<stack>/` nếu stack mới) |

**Stack built-in:** spring, laravel, golang, nodejs. Stack khác → copy `rules/_template/`.

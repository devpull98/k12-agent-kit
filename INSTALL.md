# Cài uniclass-workflow vào Claude Code

Có 2 cách cài: làm **plugin** (khuyến nghị, dùng được cho nhiều project) hoặc **copy thẳng vào project**
(đơn giản, chỉ dùng cho 1 project).

## Cách 1 — Cài như Claude Code plugin (khuyến nghị)

### 1. Cài qua marketplace local (chưa publish lên marketplace công khai)
```bash
# Trong Claude Code, mở project bất kỳ rồi chạy:
/plugin marketplace add "E:\Agent Workflow\uniclass-workflow"
/plugin install uniclass-workflow
```
Nếu sau này push repo lên GitHub, có thể thay path local bằng URL repo:
```bash
/plugin marketplace add <owner>/<repo>
/plugin install uniclass-workflow
```

### 2. Restart session
```bash
/exit
claude
```
Hook `SessionStart` trong `hooks/hooks.json` sẽ tự chạy `hooks/session-start`, đọc `AGENTS.md` +
`config.yaml` rồi inject vào context — không cần làm gì thêm.

### 3. Kiểm tra plugin đã load
```bash
/plugin
```
Phải thấy `uniclass-workflow` trong danh sách plugin đã enable.

## Cách 2 — Copy thẳng vào 1 project cụ thể

Dùng khi không muốn cài plugin global, chỉ cần dùng cho 1 repo.

1. Copy toàn bộ thư mục `uniclass-workflow/` vào root project, đổi tên thành `.claude/uniclass-workflow/`
   (hoặc giữ tên gốc, không bắt buộc).
2. Trong `.claude/settings.json` của project (tạo nếu chưa có), trỏ hook session-start vào đúng path:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash .claude/uniclass-workflow/hooks/session-start"
             }
           ]
         }
       ]
     }
   }
   ```
3. Copy `.claude/commands/feature.md` từ uniclass-workflow vào `.claude/commands/` của project (để dùng
   `/feature` ngay trong project, không cần gọi qua đường dẫn dài).

## Sau khi cài — việc bắt buộc phải làm trong từng project

Cài plugin xong KHÔNG có nghĩa là dùng được ngay — còn 1 bước riêng cho từng project, xem
[GUIDE.md](GUIDE.md) mục 2 "Bắt đầu 1 project mới":

1. Set `stack:` trong `config.yaml` (laravel/spring/golang/...).
2. Tạo `docs/specs/`, `docs/plans/`, `docs/logs/`, `docs/retros/`, `CHANGELOG.md` nếu project chưa có.
3. Kiểm tra `rules/<stack>/architecture.mdc` đã khớp convention thật của project, bổ sung rule riêng nếu thiếu.

## Kiểm tra cài đặt đúng (smoke test)

Trong Claude Code, gõ thử 1 yêu cầu mơ hồ kiểu "thêm tính năng đăng nhập bằng OTP" — agent phải:
1. Tự trigger skill `brainstorming` (không code thẳng).
2. Sau khi thiết kế chốt, chuyển sang `spec-driven-development`, tạo file trong `docs/specs/`.
3. Không cho phép viết code trước khi spec được bạn duyệt (theo `rules/_global/sdd-gate.mdc`).

Nếu agent code thẳng không qua các bước trên — kiểm tra lại:
- Hook `SessionStart` có chạy không (`/plugin` xem plugin có enable, hoặc xem `.claude/settings.json` có đúng path).
- `bash` có sẵn trong PATH không (hook dùng shebang `#!/usr/bin/env bash`) — trên Windows cần Git Bash/WSL.
- `jq` có cài không (không bắt buộc, hook có fallback nếu thiếu jq nhưng output sẽ kém escape hơn).

## Gỡ cài đặt
```bash
/plugin uninstall uniclass-workflow
```
Hoặc với cách 2: xóa thư mục `.claude/uniclass-workflow/` và phần hook đã thêm trong `.claude/settings.json`.

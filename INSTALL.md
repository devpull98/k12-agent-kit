# Cài đặt & Thiết lập Môi trường (Installation Guide)

Tài liệu này hướng dẫn cách cài đặt bộ công cụ `uniclass-workflow` (thuộc repo `k12-agent-kit`) vào môi trường làm việc của bạn (Claude Code, Cursor, Windsurf...).

---

## 1. Tiền đề (Prerequisites)

Để bộ công cụ hoạt động chính xác (đặc biệt là các hook tự động kích hoạt khi mở phiên làm việc), máy tính của bạn cần được cài đặt các công cụ sau:

1. **Git Bash** (Dành riêng cho **Windows**):
   - Hook khởi động sử dụng môi trường `bash`.
   - Tải và cài đặt từ [Git for Windows](https://git-scm.com/download/win). Hãy đảm bảo `bash` đã được thêm vào biến môi trường `PATH`.
2. **jq** (Trình xử lý JSON dòng lệnh):
   - Hook sử dụng `jq` để đọc/ghi file cấu hình dự án.
   - **Windows**: Chạy lệnh `winget install jqlang.jq` trong PowerShell, sau đó khởi động lại terminal.
   - **macOS**: Chạy lệnh `brew install jq`.
   - **Linux**: Chạy lệnh `sudo apt install jq` hoặc lệnh tương đương của bản phân phối.
3. **Claude Code** (hoặc AI IDE tương thích như Cursor, Windsurf).

> [!WARNING]
> Nếu thiếu Git Bash hoặc `jq`, các hook tự động có thể bị lỗi âm thầm, khiến AI agent không tự động nhận diện được spec/rules và bỏ qua quy trình Spec-Driven Design.

---

## 2. Các phương thức cài đặt

Tùy thuộc vào IDE và quy trình làm việc của bạn, hãy chọn một trong hai cách cài đặt dưới đây:

### Cách A: Cài đặt dạng Claude Code Plugin (Khuyến nghị)
*Phương thức này cài đặt plugin ở mức global (trong thư mục `~/.claude/`), giúp bạn sử dụng chung cho mọi dự án trên máy mà không cần copy code.*

1. **Thêm và cài đặt plugin trong Claude Code:**
   Mở Claude Code ở một thư mục bất kỳ và chạy các lệnh sau:
   ```bash
   /plugin marketplace add devpull98/k12-agent-kit
   /plugin install uniclass-workflow
   ```
   *(Hoặc nếu bạn muốn trỏ trực tiếp vào thư mục mã nguồn đã tải về máy local)*:
   ```bash
   /plugin marketplace add "E:\Agent Workflow\uniclass-workflow"
   /plugin install uniclass-workflow
   ```

2. **Khởi động lại session:**
   Để hook `SessionStart` của plugin bắt đầu hoạt động, bạn cần thoát và mở lại Claude Code:
   ```bash
   /exit
   # Mở lại Claude Code
   claude
   ```

3. **Kiểm tra trạng thái cài đặt:**
   Gõ lệnh sau trong Claude Code:
   ```bash
   /plugin
   ```
   Đảm bảo bạn nhìn thấy `uniclass-workflow` nằm trong danh sách các plugin đã được kích hoạt (enabled).

---

### Cách B: Sao chép thủ công vào Project (Dành cho Cursor, Windsurf, v.v.)
*Dùng khi bạn không sử dụng Claude Code CLI toàn cục, hoặc muốn nhúng trực tiếp bộ công cụ vào một repository cụ thể để chạy với các AI IDE khác.*

1. **Sao chép mã nguồn:**
   Copy toàn bộ thư mục `k12-agent-kit` vào thư mục gốc (root) của dự án của bạn (ví dụ đổi tên thư mục copy thành `.claude/uniclass-workflow/`).
   
2. **Cấu hình hook khởi động (Chỉ cho Claude Code cục bộ):**
   Nếu bạn vẫn dùng Claude Code nhưng muốn cấu hình theo từng project riêng lẻ, hãy tạo/chỉnh sửa file `.claude/settings.json` trong project của bạn:
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

3. **Phím tắt `/feature`, `/product-discovery`:**
   Đã được plugin cung cấp sẵn (thư mục `commands/` ở plugin root) — không cần copy tay. Sau khi `/plugin install uniclass-workflow`, lệnh tự xuất hiện ở session mới.

---

## 3. Xác minh cài đặt thành công

Sau khi cài đặt xong, hãy mở dự án của bạn và chạy thử các kiểm tra tự động để xác nhận mọi thứ hoạt động:
```bash
# Kiểm tra các quy tắc thiết kế (stack rules) của dự án
bash scripts/validate-stack.sh
```

Tiếp tục chuyển sang tài liệu [QUICKSTART.md](file:///e:/k12-agent-kit/QUICKSTART.md) để bắt đầu cấu hình dự án mới và chạy thử nghiệm tính năng Smoke Test.

---

## 4. Gỡ bỏ cài đặt (Uninstall)

Nếu bạn muốn gỡ cài đặt plugin global khỏi Claude Code:
```bash
/plugin uninstall uniclass-workflow
```

Đối với cài đặt thủ công (Cách B), bạn chỉ cần xóa thư mục `.claude/uniclass-workflow/` và phần cấu hình hook tương ứng trong `.claude/settings.json`.

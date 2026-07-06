# Khởi tạo Dự án & Chạy thử (Quickstart Guide)

Tài liệu này giúp bạn cấu hình nhanh bộ công cụ `uniclass-workflow` trên một project mới sau khi đã hoàn thành cài đặt plugin (nếu chưa cài, vui lòng xem [INSTALL.md](file:///e:/k12-agent-kit/INSTALL.md)).

---

## Các bước khởi tạo dự án mới

Thực hiện các bước sau tại thư mục gốc (root) của dự án để kích hoạt các tính năng của framework:

### Bước 1: Tạo file cấu hình `project-context.yaml`
Tạo file `project-context.yaml` tại thư mục root của dự án để AI agent nhận biết được môi trường công nghệ đang dùng:
```yaml
stack: spring          # spring | laravel | golang | nodejs | <stack-của-bạn>
test_runner: junit5    # junit5 | phpunit | jest | vitest | go-test | pytest (để trống = tự suy từ stack)
```

> [!NOTE]
> Nếu dự án của bạn sử dụng một ngôn ngữ chưa được cấu hình sẵn (ngoài Spring, Laravel, Go, Node.js), hãy xem hướng dẫn tạo stack mới trong phần **Tùy biến Stack** ở [GUIDE.md](file:///e:/k12-agent-kit/GUIDE.md).

---

### Bước 2: Tạo file chỉ dẫn ngữ cảnh `CLAUDE.md`
Tạo file `CLAUDE.md` tại root dự án (bạn có thể copy mẫu từ `templates/context-engineering/03-claude-md-template.md`). File này chứa các chỉ dẫn về:
- Các lệnh build, chạy test, chạy dev server của dự án.
- Quy chuẩn code riêng biệt của dự án (nếu có).

---

### Bước 3: Thiết lập cấu trúc thư mục lưu vết (Work Package)
Bộ công cụ quản lý các thay đổi dựa trên cấu trúc thư mục quy chuẩn để kiểm soát dung lượng context. Hãy tạo sẵn các thư mục sau nếu dự án chưa có:
- `docs/work/` — Nơi chứa thông tin thực thi của từng task (mỗi task là 1 thư mục riêng, ví dụ: `docs/work/JIRA-123-add-login/`).
- `docs/specs/modules/` — Nơi lưu trữ tài liệu đặc tả (specification) ổn định của từng module nghiệp vụ trong hệ thống.

---

### Bước 4: Kích hoạt Git Hooks kiểm soát chất lượng
Chạy lệnh sau để tự động cài đặt Git Hooks. Hook này giúp ngăn chặn việc commit code trực tiếp lên các nhánh bảo vệ (`main`, `master`, `test`) và chuẩn hóa nội dung commit của AI:
```bash
bash scripts/hooks/install-hooks.sh
```

---

## Kiểm tra hoạt động (Smoke Test)

Để đảm bảo mọi cấu hình và quality gate đang hoạt động bình thường, hãy thực hiện kiểm thử khói (smoke test) sau:

1. Mở Claude Code trong thư mục dự án của bạn.
2. Nhập một yêu cầu phát triển tính năng mơ hồ (Ví dụ: *"Hãy viết code thêm tính năng đăng nhập bằng OTP qua SMS"*).
3. **Kết quả mong đợi**:
   - AI agent **không được phép viết code ngay lập tức**.
   - Agent phải tự động nhận diện yêu cầu, kích hoạt skill `brainstorming` để thảo luận hoặc chuyển sang `spec-driven-development` để viết tài liệu đặc tả spec trước.
   - Nếu agent cố tình viết code ngay mà không qua spec, quy tắc bảo vệ của dự án (`rules/_global/sdd-gate.mdc`) sẽ chặn và cảnh báo agent.

> [!TIP]
> Nếu agent vẫn trực tiếp sửa code mà không thảo luận hay viết spec:
> - Hãy kiểm tra xem plugin đã được kích hoạt chưa bằng lệnh `/plugin` trong Claude Code.
> - Đảm bảo rằng file `project-context.yaml` đã được khai báo đúng định dạng ở thư mục root.
> - Kiểm tra xem `bash` và `jq` có hoạt động bình thường trong terminal của bạn không.

---

## Bước tiếp theo

Khi dự án đã được thiết lập xong và chạy smoke test thành công, hãy đọc tài liệu [GUIDE.md](file:///e:/k12-agent-kit/GUIDE.md) để hiểu sâu hơn về quy trình làm việc hàng ngày (Standard, Fast, Hotfix tracks) và cách custom rules theo đặc thù dự án.

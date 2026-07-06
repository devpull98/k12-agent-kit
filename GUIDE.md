# Hướng dẫn Sử dụng & Tùy biến (Developer Guide)

Tài liệu này hướng dẫn chi tiết cách vận hành hàng ngày của developer với bộ công cụ `uniclass-workflow` và cách tùy biến, mở rộng hệ thống (như thiết lập stack mới, viết skill hoặc cấu hình rules bổ sung).

---

## 1. Cơ chế hoạt động & Triết lý Core

`uniclass-workflow` được thiết kế để định hướng AI agent làm việc theo quy trình **Spec-Driven Design (SDD)**: tuyệt đối không viết code khi chưa có đặc tả nghiệp vụ được duyệt. Đồng thời, bộ công cụ phân tách tri thức làm 3 lớp độc lập để tối ưu hóa Context Budget và tránh tình trạng AI bị ảo tưởng (hallucination):

| Lớp Tri Thức | Câu hỏi giải quyết | Vị trí lưu trữ |
|---|---|---|
| **Rule (WHAT)** | Dự án/ngôn ngữ này quy chuẩn viết code như thế nào? | `rules/_global/`, `rules/<stack>/` |
| **Skill (HOW)** | Làm loại task này theo trình tự và checklist nào? | `skills/<name>/SKILL.md` |
| **Workflow (WHEN)** | Kết thúc bước hiện tại thì làm gì tiếp theo? | `workflows/<flow>.md` |

---

## 2. Quy trình làm việc hàng ngày (Delivery Tracks)

Để biết bước tiếp theo cần thực hiện là gì hoặc khi bạn/agent không chắc chắn, hãy gõ **"giờ làm gì?"** hoặc chạy lệnh `/feature` để gọi skill điều phối `next-step`.

Hệ thống hỗ trợ 3 tuyến phát triển (Delivery Tracks) chính:

### A. Standard Track (Dành cho tính năng mới hoặc thay đổi logic lớn)
- **Luồng đi:** `brainstorming` $\rightarrow$ `spec-driven-development` $\rightarrow$ `bdd-specification` $\rightarrow$ `tech-docs` $\rightarrow$ `writing-plans` $\rightarrow$ Vòng lặp `tdd` (code & test) $\rightarrow$ `code-review` $\rightarrow$ `shipping`.
- **Đặc trưng:** Bắt buộc phải viết tài liệu đặc tả nghiệp vụ (Spec/BDD) trước khi code. Lỗi sẽ bị chặn cứng bởi SDD Gate nếu cố tình code trước.

### B. Fast Track (Dành cho thay đổi nhỏ, rủi ro thấp < 30 phút)
- **Luồng đi:** Bỏ qua spec pipeline, đi thẳng từ `writing-plans` $\rightarrow$ `tdd` $\rightarrow$ `code-review`.
- **Cách kích hoạt:** Thêm tag `[fast-track]` vào câu lệnh gửi cho agent hoặc trong commit message.

### C. Hotfix Track (Sự cố sản xuất khẩn cấp)
- **Luồng đi:** `bug-flow` (triage) $\rightarrow$ `debugging` $\rightarrow$ Viết test tái hiện lỗi (Prove-It Pattern) $\rightarrow$ `tdd` (sửa lỗi) $\rightarrow$ `shipping`.
- **Cách kích hoạt:** Thêm tag `[hotfix]` vào câu lệnh hoặc commit message.

---

## 3. Cấu hình và Sử dụng theo từng Tech Stack

Khi bạn khai báo `stack` trong file `project-context.yaml`, hệ thống sẽ tự động liên kết các quy chuẩn thiết kế từ thư mục `rules/<stack>/` vào ngữ cảnh của AI agent thông qua placeholder `{stack}`.

### Laravel (`stack: laravel`)
- Quy tắc áp dụng mặc định: [architecture.mdc](file:///e:/k12-agent-kit/rules/laravel/architecture.mdc) (Controller $\rightarrow$ Service $\rightarrow$ Repository, không truy vấn Eloquent trực tiếp ngoài Repository).
- Test Runner mặc định: `phpunit`.

### Spring (`stack: spring`)
- Quy tắc áp dụng mặc định: [architecture.mdc](file:///e:/k12-agent-kit/rules/spring/architecture.mdc) (Controller $\rightarrow$ Service $\rightarrow$ Repository, sử dụng DTO riêng biệt, đặt `@Transactional` đúng phạm vi Service).
- Test Runner mặc định: `junit5`.

### Golang (`stack: golang`)
- Quy tắc áp dụng mặc định: [architecture.mdc](file:///e:/k12-agent-kit/rules/golang/architecture.mdc) (Handler $\rightarrow$ UseCase $\rightarrow$ Repository qua interface, wrap context cho error).
- Test Runner mặc định: `go-test`.

### Node.js (`stack: nodejs`)
- Quy tắc áp dụng mặc định: [architecture.mdc](file:///e:/k12-agent-kit/rules/nodejs/architecture.mdc) (Controller $\rightarrow$ Service $\rightarrow$ Repository / Model).
- Test Runner mặc định: `vitest` hoặc `jest`.

---

## 4. Tùy biến Stack mới (Ví dụ: .NET, Python, Django...)

Nếu dự án của bạn sử dụng ngôn ngữ hoặc framework chưa có sẵn trong danh sách trên, hãy tự tạo stack rule theo các bước:

1. Tạo thư mục mới: `rules/<tên-stack-mới>/`.
2. Sao chép các file rule mẫu từ thư mục `rules/_template/`:
   ```bash
   cp -r rules/_template rules/<tên-stack-mới>
   ```
3. Mở các file `architecture.mdc` và `test-patterns.mdc` mới tạo và điền các quy chuẩn thiết kế, coding style, cũng như test framework thật của dự án bạn vào đó.
4. Cập nhật `stack: <tên-stack-mới>` vào file `project-context.yaml` ở dự án của bạn.
5. Chạy script kiểm tra hợp lệ:
   ```bash
   bash scripts/validate-stack.sh
   ```

---

## 5. Bản đồ các Skill hiện có

Dưới đây là danh sách các kỹ năng (skills) được định nghĩa sẵn mà AI agent sẽ tự động kích hoạt thông qua router (`router.yaml`):

| Tên Skill | Trường hợp sử dụng |
|---|---|
| `brainstorming` | Phân tích yêu cầu sơ bộ khi đặc tả chưa rõ ràng. |
| `spec-driven-development` | Viết/cập nhật tài liệu đặc tả nghiệp vụ (Spec). |
| `bdd-specification` | Viết kịch bản kiểm thử hành vi Given-When-Then (`.feature`). |
| `tech-docs` | Thiết kế kiến trúc kỹ thuật chi tiết (Database schema, API contracts). |
| `writing-plans` | Lên kế hoạch thực hiện, phân rã task chi tiết (checklist.md). |
| `tdd` | Thực hiện viết code đi kèm test (Red-Green-Refactor). |
| `debugging` / `root-cause-tracing` | Khắc phục lỗi và tìm nguyên nhân gốc của bug. |
| `code-review` | Rà soát chất lượng code trước khi merge PR. |
| `shipping` | Chuẩn bị và deploy release lên môi trường kiểm thử/thực tế. |

---

## 6. Viết Skill mới cho Dự án

Nếu dự án có các nghiệp vụ đặc thù lặp đi lặp lại nhiều lần (ví dụ: tạo file DB migration, viết API doc, cấu hình Docker...), bạn có thể định nghĩa thêm skill mới:

1. **Tạo thư mục skill:**
   Tạo `skills/<tên-skill-mới>/SKILL.md`.
2. **Khai báo Frontmatter (Bắt buộc):**
   ```yaml
   ---
   name: <tên-skill-mới>
   description: <Động từ> + <Đối tượng>. Dùng khi <Điều kiện kích hoạt cụ thể>.
   keywords: [<danh sách từ khóa để router nhận diện>]
   requires_rules:
     - "{stack}/architecture" # Nếu skill cần tham chiếu đến rule của stack hiện tại
   ---
   ```
3. **Viết nội dung skill:**
   Cấu trúc nội dung gồm 4 phần: `# Purpose`, `# Inputs`, `# Steps`, và `# Output`. Nên viết ngắn gọn và súc tích (dưới 150 dòng).
4. **Đăng ký vào Intent Router (`router.yaml`):**
   Thêm một cấu hình định tuyến mới vào file `router.yaml`:
   ```yaml
   - intent: "Mô tả intent"
     keywords: [<từ khóa>]
     skill: <tên-skill-mới>
     confidence: strict
   ```
5. **Khởi động lại session:**
   Để AI agent quét và tải skill mới, hãy gõ `/exit` và mở lại phiên Claude Code.

---
name: onboarding
description: Tự động thiết lập (setup) framework, phát hiện stack công nghệ, cài đặt Git hooks, tạo project-context.yaml và CLAUDE.md cho dự án mới. Use khi bắt đầu làm việc với một repo mới clone hoặc chưa cấu hình kit.
keywords: [setup, onboarding, cài đặt kit, init project, cấu hình dự án, setup framework, install framework]
on_success: [product-discovery]
on_failure: [brainstorming]
---

# Purpose
Tự động hóa hoàn toàn quy trình onboarding của lập trình viên và thiết lập bộ kit lên dự án mới mục tiêu. Loại bỏ việc con người phải tự copy files, viết cấu hình và cài đặt hooks thủ công.

# Inputs
- Mã nguồn của dự án thật (để quét và phát hiện stack/dependencies).

# Steps
1.  **Phát hiện Stack công nghệ (Auto-detection):**
    *   Quét thư mục gốc để phát hiện loại dự án:
        *   Có `pom.xml` hoặc `build.gradle` $\rightarrow$ Stack: `spring` (Java/Kotlin).
        *   Có `composer.json` $\rightarrow$ Stack: `laravel` (PHP).
        *   Có `go.mod` $\rightarrow$ Stack: `golang`.
        *   Có `package.json` $\rightarrow$ Stack: `nodejs` (hoặc `react`/`nextjs` nếu có dependencies tương ứng).
        *   Có `requirements.txt` hoặc `pyproject.toml` $\rightarrow$ Stack: `django` / `python`.
        *   Có `pubspec.yaml` $\rightarrow$ Stack: `flutter`.
2.  **Tạo File Cấu Hình Dự Án (`project-context.yaml`):**
    *   Tự động copy mẫu `project-context.yaml` từ kit ra root của dự án thật.
    *   Tự động điền giá trị `stack:` đã phát hiện được ở Bước 1.
    *   Tự động detect các lệnh chạy test (ví dụ: `mvn test`, `npm test`, `go test ./...`) và điền vào trường `test_runner`.
3.  **Chuẩn bị Rules Stack:**
    *   Kiểm tra thư mục `rules/{stack}/` xem đã có file `architecture.mdc` chưa.
    *   Nếu chưa có $\rightarrow$ Tự động sao chép các file mẫu `.mdc` từ `rules/_template/` sang thư mục `rules/{stack}/` của dự án và báo cho lập trình viên biết để điền các convention riêng (nếu có).
4.  **Cài đặt Git Hooks:**
    *   Thực thi lệnh shell cài đặt Git Hook chặn AI-spam:
        ```bash
        bash scripts/hooks/install-hooks.sh
        ```
5.  **Tạo File `CLAUDE.md` ở Root:**
    *   Tự động tạo file `CLAUDE.md` ở root dự án thật bằng cách điền thông tin stack, cấu trúc thư mục phát hiện được và các lệnh build/test/run phổ biến lấy từ `package.json` hoặc cấu hình build (sử dụng template `templates/context-engineering/03-claude-md-template.md`).
6.  **Chạy Kiểm Tra Tổng Thể (Self-validation):**
    *   Chạy kiểm định tính hợp lệ của stack rules:
        ```bash
        bash scripts/validate-stack.sh
        ```
    *   Báo cáo trạng thái setup thành công cho lập trình viên.

# Output
- File `project-context.yaml` hoàn chỉnh được tạo ở root dự án.
- Thư mục rules stack `rules/{stack}/` chứa các files `.mdc` mẫu.
- Git Hooks đã được cài đặt và liên kết (symlinked).
- File `CLAUDE.md` cấu hình sẵn các lệnh build/test cho Agent.

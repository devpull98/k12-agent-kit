# CLAUDE.md Template

<!--
CLAUDE.md là "context budget đầu tiên" của mọi session.
Claude Code đọc file này trước khi làm bất cứ điều gì.

Nguyên tắc viết CLAUDE.md hiệu quả:
- Đặt thông tin quan trọng nhất LÊN ĐẦU (bị truncate từ cuối)
- Không copy convention đã có trong rules/ — chỉ override hoặc extend
- Mỗi section phải trả lời: "nếu Claude không biết điều này, điều gì sẽ sai?"
- Dưới 400 dòng (tối ưu < 200). Dài hơn = loãng context.

Lưu file này tại: CLAUDE.md (root của project thật, không phải kit)
-->

# <Tên Project>

## Tóm tắt 1 câu
<Dự án làm gì, cho ai — đủ để agent hiểu domain trước khi đọc code>

## Stack
- **Language / Framework:** <ví dụ: Java 21 / Spring Boot 3.2>
- **Database:** <ví dụ: MySQL 8 + Redis>
- **Test runner:** <ví dụ: JUnit 5, Mockito>
- **Build:** <ví dụ: Maven — `mvn test`, `mvn spring-boot:run`>
- **QC:** <ví dụ: Playwright — `npx playwright test`>

## Cấu trúc thư mục quan trọng
```
src/
  main/java/<package>/
    domain/          # Entity, Value Object, Domain Service
    application/     # Use case, DTO, port interface
    infrastructure/  # JPA, HTTP adapter, external service
    api/             # Controller, request/response mapping
docs/
  specs/bdd/         # BDD feature files (source of truth behavior)
  specs/tech-design/ # Tech design per UC
  trace/             # Traceability TSV files
```

## Quy ước bắt buộc (MUST)
<!--
CHỈ ghi những quy ước agent hay vi phạm, hoặc không suy ra được từ code.
Không lặp lại rules/_global/ — agent đã có qua session-start hook.
-->

- MUST đọc `docs/specs/bdd/{UC-ID}.feature` trước khi sửa code liên quan.
- MUST gắn `// @trace.implements: {UC-ID}-SC{N}` vào method implement scenario.
- MUST chạy `bash scripts/governance-check.sh` trước khi tạo PR.
- <quy ước riêng của project>

## Quy ước cấm (MUST NOT)
- MUST NOT commit trực tiếp lên `main` — luôn dùng branch theo NAMING-CONVENTIONS.
- MUST NOT hardcode URL / credential — dùng environment variable.
- <quy ước riêng>

## Điểm hỏi trước khi tự quyết (ASK FIRST)
- Thay đổi database schema → cần migration plan review.
- Sửa public API contract → cần backward-compat check.
- Thêm dependency mới → cần security scan + license check.

## Lệnh hay dùng
```bash
# Build & test
mvn clean test

# Chạy local
mvn spring-boot:run -Dspring-boot.run.profiles=local

# Governance check
bash scripts/governance-check.sh

# Load test
k6 run tests/load/baseline.js
```

## Tài liệu nội bộ
- **Spec:** `docs/specs/` — đọc trước khi code bất kỳ feature nào
- **Principles:** `docs/principles.md` — override mọi convention generic
- **Trace:** `docs/trace/` — check coverage trước khi merge

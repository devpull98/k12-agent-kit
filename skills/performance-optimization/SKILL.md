---
name: optimize-performance
priority: HIGH
triggers:
  - IF: Response time của API vượt ngưỡng p95, CPU DB tăng vọt, hoặc có yêu cầu tối ưu trước release.
    THEN: Kích hoạt skill này để tối ưu hóa.
requires_rules:
  - _global/performance-baseline
---

# Problem
Tối ưu hóa sớm (premature optimization) làm phức tạp hóa code mà không mang lại hiệu năng thực tế.

# Rules & Knowledge

## 1. Đo lường trước (Quy tắc)
*   **IF** Chưa có số liệu đo lường cụ thể (response time, số lượng query, memory) làm baseline:
    *   **THEN** Nghiêm cấm tối ưu hóa code theo cảm tính.

## 2. Khắc phục N+1 và Heavy Payload (Quy tắc)
*   **IF** Có truy vấn nằm trong vòng lặp:
    *   **THEN** Bắt buộc chuyển sang Bulk Query (`IN` clause).
*   **IF** Chỉ cần lấy 1-2 trường dữ liệu từ Mongo/MySQL:
    *   **THEN** Bắt buộc sử dụng Projection, nghiêm cấm nạp full Entity/Document.

## Bad vs Good
*   **Bad (Query MySQL trong vòng for):**
    ```java
    for (Integer id : ids) {
        K12Contest contest = contestService.findById(id); // MySQL Query N lần
    }
    ```
*   **Good (Bulk Query + Projection):**
    ```java
    List<ContestTypeDto> contests = contestService.findProjectionByIdIn(ids); // 1 Query duy nhất
    ```

# Checklist
- [ ] Đo đạc baseline hiệu năng (số query, thời gian thực thi) trước khi sửa.
- [ ] Áp dụng Projection và Bulk query cho các điểm nóng.
- [ ] Đo lại hiệu năng sau khi sửa và so sánh số liệu.

# Output Expectation
- Chỉ số trước/sau cụ thể (ví dụ: MongoDB Query: 12 -> 1, API Latency: 350ms -> 45ms).

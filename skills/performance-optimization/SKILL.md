---
name: performance-optimization
description: Đo và tối ưu hiệu năng có dữ liệu, không tối ưu theo cảm tính. Use when có báo cáo chậm, query N+1 nghi ngờ, hoặc trước khi release feature chịu tải cao.
keywords: [performance, tối ưu, chậm, N+1, latency, profiling]
not_for: [tối ưu code chưa có bằng chứng chậm — ưu tiên refactoring nếu mục tiêu là đọc code dễ hơn]
requires_rules:
  - _global/performance-baseline
---

# Purpose
Tối ưu hiệu năng dựa trên đo lường thật, tránh "tối ưu sớm" làm phức tạp code không cần thiết.

# Inputs
- Báo cáo/triệu chứng chậm (endpoint nào, response time bao nhiêu)
- `rules/_global/performance-baseline.mdc`

# Steps
1. Đo trước khi sửa: xác định baseline (response time, query count, memory) bằng profiler/log thật — không đoán.
2. Xác định bottleneck cụ thể: N+1 query, thiếu index, thiếu cache, thiếu pagination, blocking I/O.
3. Đối chiếu `performance-baseline.mdc` để biết pattern nào bị cấm (ví dụ query trong loop).
4. Sửa đúng 1 bottleneck tại 1 thời điểm, đo lại ngay sau mỗi thay đổi.
5. So sánh kết quả đo trước/sau — nếu không cải thiện rõ, revert thay đổi đó.
6. Không tối ưu phần code chưa được đo là bottleneck thật.

# Output
- Số đo trước/sau (response time, query count...)
- Thay đổi cụ thể đã áp dụng, kèm lý do dựa trên số đo

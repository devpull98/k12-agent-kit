# @trace.uc_id: {UC-ID}
# @trace.domain: {domain}
# @trace.status: draft   # draft | approved | deprecated
# @trace.version: 1.0

Feature: {Tên feature ngắn gọn}
  As a {actor}
  I want to {hành động}
  So that {lợi ích / mục đích}

  # SC1 — Happy path
  Scenario: {Mô tả luồng chính thành công}
    Given {trạng thái ban đầu — điều kiện tiên quyết}
    When  {hành động xảy ra}
    Then  {kết quả mong đợi — đủ cụ thể để assert}

  # SC2 — Alternate path (nếu có)
  Scenario: {Luồng thành công thay thế}
    Given {điều kiện khác}
    When  {hành động}
    Then  {kết quả}

  # SC3 — Error case
  Scenario: {Tên case lỗi}
    Given {điều kiện dẫn đến lỗi}
    When  {hành động}
    Then  {hệ thống phải trả về / hiển thị gì — cụ thể}

  # SC4 — Edge case / boundary
  Scenario: {Boundary condition}
    Given {edge case}
    When  {hành động}
    Then  {behavior đúng}

# ---
# Checklist trước khi mark approved:
# [ ] Tất cả actors được xác định rõ
# [ ] Mỗi Then đủ cụ thể để viết test assertion
# [ ] Có ít nhất 1 error scenario
# [ ] Dev và tester đã review và đồng ý
# [ ] UC-ID và @trace.domain đã điền

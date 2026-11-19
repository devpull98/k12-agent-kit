---
name: spec-analyze
description: Phân tích nhất quán READ-ONLY giữa Product Brief ↔ BDD ↔ Tech Design ↔ Plan ↔ principles TRƯỚC khi implement — bắt trùng lặp, mơ hồ, thiếu coverage, mâu thuẫn, vi phạm principles; kèm checklist chất lượng requirement ("unit test cho tiếng Việt"). Use when writing-plans vừa xong, trước executing-plans/tdd, hoặc khi nghi spec các tầng lệch nhau.
keywords: [analyze, phân tích nhất quán, consistency, cross-artifact, coverage gap, spec analyze, requirement checklist, checklist spec]
not_for: [kiểm trace code↔BDD sau implement — dùng trace-validation, review code — dùng code-review]
requires_rules:
  - _global/sdd-gate
  - _global/traceability
on_success: [executing-plans]
on_failure: [writing-plans, bdd-specification, clarify-spec]
---

# Purpose
Chặn lỗi spec trước khi nó thành lỗi code. `trace-validation` kiểm code↔spec **sau** implement; skill này kiểm spec↔spec↔plan **trước** implement.

# Nguyên tắc
- **READ-ONLY**: không sửa file nào. Chỉ xuất report + đề xuất remediation; chỉ sửa khi user duyệt.
- **Principles là luật**: xung đột với MUST trong `docs/principles.md` → luôn CRITICAL; sửa spec/plan, không "diễn giải lại" principle.
- **Không bịa**: section/constraint thiếu → báo thiếu, không tự điền.
- **Deterministic**: chạy lại không đổi gì → cùng ID, cùng số liệu. Tối đa 50 finding, phần dư tóm tắt overflow.

# Inputs (chỉ đọc path trong `_context.md`)
- Product Brief (`FR-xxx`, success criteria), BDD `.feature` (`SC{N}`), tech design (nếu có), `plan.md` (`T0xx`), `docs/principles.md`

# Detection passes
| Pass | Tìm gì |
|------|--------|
| A. Duplication | Requirement/scenario gần trùng nhau |
| B. Ambiguity | Từ mơ hồ không có số đo; placeholder `TODO`, `???`, `[NEEDS CLARIFICATION]` |
| C. Underspecification | Requirement thiếu đối tượng/kết quả; scenario thiếu Then đo được; task trỏ file/component chưa định nghĩa |
| D. Principles alignment | Vi phạm MUST/MUST NOT; thiếu section/gate bắt buộc |
| E. Coverage gap | FR không có scenario; scenario không có task (`Covers:`); task không map FR/SC nào; NFR (perf/security/compliance) không có task |
| F. Inconsistency | Lệch thuật ngữ; entity có ở tech design mà không có ở brief; thứ tự task mâu thuẫn dependency; tech choice mâu thuẫn |

# Severity
- **CRITICAL** — vi phạm principle MUST, thiếu artifact lõi, scenario lõi 0 coverage → **chặn implement**.
- **HIGH** — requirement mâu thuẫn/trùng, security/perf mơ hồ, tiêu chí không test được.
- **MEDIUM** — lệch thuật ngữ, thiếu task NFR, edge case thiếu.
- **LOW** — wording, dư thừa nhỏ.

# Steps
1. Đọc artifact, dựng inventory: FR keys, SC keys, task IDs + `Covers:`.
2. Chạy pass A–F, gắn severity.
3. **Requirement-quality checklist** (tùy chọn, khi user yêu cầu hoặc feature rủi ro cao): ghi `docs/work/<KEY>-<slug>/checklists/<domain>.md` (vd `api.md`, `security.md`), ID `CHK001…`, append nếu file đã có.
   - Mỗi item là **câu hỏi về chất lượng requirement**, KHÔNG phải test hành vi: ✅ "Ngưỡng 'tải nhanh' đã được lượng hóa chưa? [Clarity, Brief §SC]" — ❌ "Verify trang tải nhanh".
   - Tag dimension: Completeness / Clarity / Consistency / Measurability / Coverage / Edge Case; ≥80% item có ref (`[Brief §x]`, `[SC3]`) hoặc marker `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Assumption]`.
   - Cấm item bắt đầu bằng "Verify/Test/Confirm/Check" + hành vi implement.
4. Xuất report (format dưới), đề xuất top remediation, hỏi user có muốn áp dụng không.

# Output format
```markdown
## Spec Analysis — <UC-ID>
| ID | Category | Severity | Location | Summary | Recommendation |
|----|----------|----------|----------|---------|----------------|
| A1 | Coverage | HIGH | UC-xxx.feature SC4 | Không task nào Covers SC4 | Thêm task hoặc gộp vào T003 |

### Coverage
| Key | Has task? | Task IDs | Notes |
|-----|-----------|----------|-------|

### Principles issues (nếu có) · Unmapped tasks (nếu có)

### Metrics
FR: n · SC: n · Tasks: n · Coverage: x% · Ambiguity: n · Duplication: n · CRITICAL: n

### Next
CRITICAL > 0 → sửa trước (on_failure). Không → executing-plans.
```
- State block: `last_skill: spec-analyze`, `next_skill: executing-plans` (hoặc skill sửa lỗi)

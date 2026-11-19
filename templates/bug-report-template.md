<!--
Bug sống ở 1 trong 2 nơi (rules/_global/work-items.mdc):
  A. Phát hiện TRONG lúc làm item (review/QC trước merge) → thêm entry vào docs/work/<ITEM-ID>-<slug>/bugs.md
     Heading BẮT BUỘC:  ## <ITEM-ID>-B<n> — <tóm tắt>   (vd ## SOCKETIO-012-B1 — Drain bỏ sót message)
  B. Phát hiện SAU khi item đã done / trên production → tạo work item riêng:
     bash scripts/work.sh new bug <module> "<tóm tắt>" --fixes <ITEM-ID-gốc>
Hai dòng **Status:** và **Severity:** được scripts/work.sh index đọc để dựng "Bug đang mở" — giữ đúng enum.
-->
## {ITEM-ID}-B{n} — {tóm tắt 1 dòng}

- **Status:** open            <!-- open | fixed | verified | closed | wontfix | deferred -->
- **Severity:** high          <!-- critical | high | medium | low -->
- **Date:** {YYYY-MM-DD} · **Reporter:** {tên / role} · **Fixed in:** {commit/PR}

---

## Thông tin cơ bản

| Field | Value |
|-------|-------|
| UC-ID | {UC-ID} |
| Scenario | SC{N} — {tên scenario} |
| Bug case | Case {1-6} — {tên case} |
| Severity | Critical / High / Medium / Low |
| Assignee | {dev / PO / tester / devops} |

### Bug case classification
- [ ] Case 1 — Code bug (code ≠ BDD; BDD đúng → Dev fix code)
- [ ] Case 2 — Spec bug (code đúng theo spec nhưng spec sai → update BDD trước)
- [ ] Case 3 — Ambiguous spec (BDD mơ hồ → clarify rồi update)
- [ ] Case 4 — Spec changed (spec update sau khi code done → confirm rồi update code)
- [ ] Case 5 — Test bug (test sai, code đúng → Tester fix test)
- [ ] Case 6 — Env/Data bug (spec+code+test đều đúng → check infra/data)

---

## Mô tả bug

**Expected behavior** (theo BDD spec):
> {Trích dẫn từ Then của scenario}

**Actual behavior**:
> {Điều thực tế xảy ra}

**Steps to reproduce:**
1. ...
2. ...
3. ...

---

## Evidence

**Test output / log:**
```
{paste log hoặc test failure message}
```

**Environment:** dev / staging / production
**Build / commit:** {hash hoặc version}

---

## Fix history

| Date | Action | By |
|------|--------|----|
| {date} | Bug reported | {reporter} |
| | Fix implemented | |
| | QC re-verified | |
| | Closed | |

## Summary
<!-- Mô tả ngắn thay đổi + track (standard / fast-track / hotfix) -->

## Delivery track
- [ ] Standard
- [ ] Fast-track `[fast-track]`
- [ ] Hotfix `[hotfix]`

## Governance checklist (bắt buộc trước merge)
- [ ] `bash scripts/governance-check.sh` pass
- [ ] `dev_selftest: pass` (lệnh test đã chạy: ___)
- [ ] `qc_status: pass` (tester xác nhận hoặc N/A cho fast/hotfix nội bộ)
- [ ] Spec/BDD updated nếu đổi behavior (standard track)
- [ ] `@trace.implements` / `@trace.verifies` khớp BDD (nếu có BDD)

## Artifacts
| Loại | Path |
|------|------|
| Product Brief | |
| BDD | |
| Tech design | |
| Plan | |

## Test plan
- [ ] Unit/integration tests pass
- [ ] Manual verification (nếu có)

## Rollback (hotfix/release)
<!-- Cách rollback nếu deploy fail -->

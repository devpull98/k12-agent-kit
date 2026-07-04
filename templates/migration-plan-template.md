# Migration Plan: <migration-name>

<!--
UC-ID:          (nếu có BDD spec)
Track:          standard | fast | hotfix
Type:           db-schema | data | service | dependency-upgrade | infra
Estimated size: XS (<2h) | S (<1d) | M (<3d) | L (<1w) | XL (>1w)
Reversible:     yes | no | partial
-->

## Context
<!-- Tại sao cần migrate? Trạng thái before → after. -->

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Data loss | low/med/high | low/med/high | ... |
| Downtime | | | |
| Rollback blocked | | | |

## Pre-Migration Checklist
- [ ] Backup tạo xong và đã verify restore được
- [ ] Migration chạy thành công trên staging/preprod
- [ ] Estimated migration time đo trên dữ liệu thật
- [ ] Maintenance window hoặc zero-downtime strategy xác nhận
- [ ] Rollback procedure đã test

## Migration Steps

### Phase 1: Prepare (có thể deploy trước, không breaking)
| # | Task | Command / File | Verify |
|---|------|---------------|--------|
| 1 | | | |

### Phase 2: Execute (breaking change nếu có)
| # | Task | Command / File | Verify |
|---|------|---------------|--------|
| 1 | | | |

### Phase 3: Cleanup (sau khi stable)
| # | Task | Command / File | Verify |
|---|------|---------------|--------|
| 1 | | | |

## Rollback Plan

| Trigger | Action | Command | Estimated time |
|---------|--------|---------|---------------|
| Data corruption | Restore backup | `...` | ~Xmin |
| Service down > Xmin | Revert deploy | `git revert ... && deploy` | ~Xmin |

## Post-Migration Verify
- [ ] Row count / checksum khớp trước và sau
- [ ] Smoke test key flows pass
- [ ] Monitoring không có anomaly sau 15 phút

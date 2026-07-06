#!/usr/bin/env bash
# Skill graph integrity: mọi skill được reference (router.yaml + on_success/on_failure/on_skip)
# phải resolve tới skills/<name>/SKILL.md, và mỗi SKILL.md có name khớp folder.
# Bắt "dangling skill reference" (vd skill mới chưa load, hoặc typo) TRƯỚC khi thành bug runtime.
# Usage: ./scripts/validate-skill-graph.sh
# Exit 0 = OK; Exit 1 = có reference gãy hoặc name mismatch.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAIL=0
echo "=== Skill Graph Integrity ==="

# ── Tập skill tồn tại (folder có SKILL.md) ───────────────────────────────────
exist=$(for d in skills/*/SKILL.md; do basename "$(dirname "$d")"; done | sort -u)
has() { grep -qxF "$1" <<<"$exist"; }

# ── 1. name frontmatter phải khớp tên folder ─────────────────────────────────
for f in skills/*/SKILL.md; do
  folder=$(basename "$(dirname "$f")")
  name=$(grep -m1 '^name:' "$f" | sed 's/name:[[:space:]]*//' | tr -d '\r')
  if [[ "$name" != "$folder" ]]; then
    echo "  MISMATCH: skills/$folder/SKILL.md có name: '$name' (phải là '$folder')"
    FAIL=1
  fi
done

# ── Hàm kiểm 1 reference ─────────────────────────────────────────────────────
check_ref() {
  local skill="$1" src="$2"
  [[ -z "$skill" ]] && return 0
  if ! has "$skill"; then
    echo "  DANGLING: '$skill' (referenced in $src) — không có skills/$skill/SKILL.md"
    FAIL=1
  fi
}

# ── 2. router.yaml: mọi `skill:` phải resolve ────────────────────────────────
while IFS= read -r skill; do
  check_ref "$skill" "router.yaml"
done < <(grep -hoE '^[[:space:]]+skill:[[:space:]]*\S+' router.yaml | sed 's/.*skill:[[:space:]]*//' | tr -d '\r' | sort -u)

# ── 3. on_success/on_failure/on_skip trong mọi SKILL.md phải resolve ──────────
for f in skills/*/SKILL.md; do
  folder=$(basename "$(dirname "$f")")
  refs=$(grep -hoE '^(on_success|on_failure|on_skip):[[:space:]]*\[.*\]' "$f" \
    | grep -oE '\[.*\]' | tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' || true)
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    check_ref "$skill" "skills/$folder/SKILL.md"
  done <<<"$refs"
done

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "PASS: Mọi skill reference resolve, name khớp folder."
  exit 0
else
  echo "FAIL: Có reference gãy hoặc name mismatch — xem trên."
  echo "  Lưu ý: skill MỚI thêm chỉ được Claude Code load ở SESSION MỚI."
  echo "  Nếu folder đã tồn tại mà agent không gọi được → khởi động lại session."
  exit 1
fi

#!/usr/bin/env bash
# Spec clarity gate: stable truth (docs/specs/**) KHÔNG được còn marker [NEEDS CLARIFICATION].
# Marker trong work package (docs/work/**) chỉ WARN — đang trong quá trình làm rõ.
# Marker nằm trong HTML comment (<!-- ... -->, vd hướng dẫn của template) được bỏ qua.
# Fix: chạy skill clarify-spec để hỏi + ghi đáp án vào spec.
# Usage: ./scripts/validate-spec-clarity.sh
# Escape: GOVERNANCE_SKIP=1
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "${GOVERNANCE_SKIP:-}" == "1" ]]; then
  echo "SKIP: GOVERNANCE_SKIP=1"; exit 0
fi

echo "=== Spec Clarity Gate ==="

# Spec dirs: mặc định docs/specs + đường dẫn khai báo trong project-context.yaml
SPEC_DIRS="docs/specs"
if [[ -f project-context.yaml ]]; then
  for key in bdd_specs tech_design; do
    v=$(grep -E "^\s*${key}:" project-context.yaml 2>/dev/null \
      | head -1 | sed "s/.*${key}:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//" | tr -d '\r"' || true)
    [[ -n "$v" ]] && SPEC_DIRS="$SPEC_DIRS $v"
  done
fi

# In "file:line: text" cho marker nằm NGOÀI HTML comment.
scan() {
  awk '
    FNR==1 { inc=0 }
    {
      line=$0; out=""
      while (length(line) > 0) {
        if (inc) {
          p=index(line,"-->"); if (p==0) { line=""; break }
          line=substr(line,p+3); inc=0
        } else {
          p=index(line,"<!--"); if (p==0) { out=out line; line=""; break }
          out=out substr(line,1,p-1); line=substr(line,p+4); inc=1
        }
      }
      if (index(out,"[NEEDS CLARIFICATION") > 0) printf "%s:%d: %s\n", FILENAME, FNR, $0
    }
  ' "$@"
}

collect() {  # $@ = dirs → danh sách file .md/.feature
  for d in "$@"; do
    [[ -d "$d" ]] || continue
    find "$d" -type f \( -name '*.md' -o -name '*.feature' \)
  done | sort -u
}

FAIL=0
mapfile -t spec_files < <(collect $SPEC_DIRS)
if [[ ${#spec_files[@]} -gt 0 ]]; then
  hits=$(scan "${spec_files[@]}" || true)
  if [[ -n "$hits" ]]; then
    echo "  ✗ Spec (stable truth) còn marker chưa làm rõ:"
    printf '%s\n' "$hits" | sed 's/^/    /'
    FAIL=1
  fi
fi

mapfile -t work_files < <(collect docs/work)
if [[ ${#work_files[@]} -gt 0 ]]; then
  whits=$(scan "${work_files[@]}" || true)
  if [[ -n "$whits" ]]; then
    echo "  ⚠ Work package còn marker (WARN — xử lý trước khi chốt spec):"
    printf '%s\n' "$whits" | sed 's/^/    /'
  fi
fi

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "PASS: Không còn [NEEDS CLARIFICATION] trong spec."
  exit 0
else
  echo "FAIL: Chạy skill clarify-spec để chốt các điểm trên (hoặc GOVERNANCE_SKIP=1)."
  exit 1
fi

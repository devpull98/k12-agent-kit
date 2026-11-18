#!/usr/bin/env bash
# Ship gate: đọc state block trong docs/work/<KEY>-<slug>/_context.md và enforce
# handoff dev→QC→ship. Biến "dev_selftest + qc_status + trace phải pass" từ lời hứa
# thành check chặn được.
#
# Usage:
#   ./scripts/validate-context-state.sh [path/to/_context.md]   # 1 package cụ thể
#   ./scripts/validate-context-state.sh                          # scan mọi docs/work/*/
#
# Ship-ready khi: dev_selftest=pass  &&  qc_status ∈ {pass,na}  &&  trace=pass
# Escape hatch: FAST_TRACK=1 | HOTFIX=1 → qc_status=na được chấp nhận, vẫn cần dev_selftest.
# GOVERNANCE_SKIP=1 → bỏ qua hoàn toàn.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "${GOVERNANCE_SKIP:-}" == "1" ]]; then
  echo "SKIP: GOVERNANCE_SKIP=1"; exit 0
fi

# Đọc 1 field trong YAML state block (fenced ```yaml ... ```) của 1 file.
field() { grep -m1 "^[[:space:]]*$2:" "$1" 2>/dev/null | sed "s/^[[:space:]]*$2:[[:space:]]*//" | sed 's/[[:space:]]*#.*//' | tr -d '\r"' | xargs || true; }

# Artifact hygiene: _context/plan là index, không phải nhật ký (doc-scoping).
FORBIDDEN_HEADINGS='^#{1,6}[[:space:]]*(Session|Changelog|Nhật ký|Tóm tắt phiên|Progress|Handoff note|Working notes|What we did|Implementation notes)\b'

# plan.md có task → MUST có Non-goals/Restrictions + Verification (lệnh copy-run).
plan_structure() {
  local plan="$1" fail=0
  # Heuristic: có Task Matrix hoặc heading Task → coi là plan có task breakdown.
  if ! grep -Eiq '^#{1,6}[[:space:]]*(Task Matrix|Task [0-9]|T[0-9]+:)' "$plan" \
     && ! grep -Eiq '^\|[[:space:]]*Task ID[[:space:]]*\|' "$plan"; then
    return 0
  fi
  if ! grep -Eiq '^#{1,6}[[:space:]]*(Non-goals|Restrictions)\b' "$plan"; then
    echo "   ✗ plan.md thiếu ## Non-goals / Restrictions — ghi việc cấm đợt này"
    fail=1
  fi
  if ! grep -Eiq 'Verification|^\*\*Verify:\*\*' "$plan"; then
    echo "   ✗ plan.md thiếu Verification — mỗi task cần lệnh copy-run được"
    fail=1
  fi
  return $fail
}

hygiene() {
  local ctx="$1" dir plan note lines plines fail=0
  dir="$(dirname "$ctx")"
  plan="$dir/plan.md"
  note="$dir/note.md"
  lines=$(wc -l < "$ctx" | tr -d ' \r')
  if [[ "$lines" -gt 90 ]]; then
    echo "   ✗ _context.md quá dài ($lines > 90 dòng) — recap/spec copy phải ở spec hoặc note.md"
    fail=1
  fi
  if [[ -f "$plan" ]]; then
    plines=$(wc -l < "$plan" | tr -d ' \r')
    if [[ "$plines" -gt 250 ]]; then
      echo "   ✗ plan.md quá dài ($plines > 250 dòng) — không nhồi recap sau mỗi task"
      fail=1
    fi
    if grep -Eiq "$FORBIDDEN_HEADINGS" "$plan"; then
      echo "   ✗ plan.md có heading nhật ký cấm — chuyển sang note.md"
      fail=1
    fi
    plan_structure "$plan" || fail=1
  fi
  if grep -Eiq "$FORBIDDEN_HEADINGS" "$ctx"; then
    echo "   ✗ _context.md có heading nhật ký cấm — chỉ được patch YAML state"
    fail=1
  fi
  # Compact-on-DONE: khi ship/done, Working notes trong note.md phải trống (không còn bullet/paragraph sau heading).
  local phase
  phase=$(field "$ctx" phase)
  if [[ -f "$note" && ( "$phase" == "ship" || "$phase" == "done" ) ]]; then
    if awk '
      BEGIN { insec=0; dirty=0 }
      /^#{1,6}[[:space:]]*Working notes/ { insec=1; next }
      /^#{1,6}[[:space:]]/ {
        if (insec) { exit (dirty ? 0 : 1) }
      }
      insec && /^[[:space:]]*$/ { next }
      insec && /^[[:space:]]*<!--/ { next }
      insec && NF { dirty=1; exit 0 }
      END { if (insec) exit (dirty ? 0 : 1); exit 1 }
    ' "$note"; then
      echo "   ✗ note.md còn Working notes khi phase=$phase — compact-on-DONE (xem doc-scoping)"
      fail=1
    fi
  fi
  return $fail
}

check_one() {
  local f="$1" fail=0
  local phase track dev qc trace
  phase=$(field "$f" phase);       track=$(field "$f" track)
  dev=$(field "$f" dev_selftest);  qc=$(field "$f" qc_status); trace=$(field "$f" trace)

  echo "── $f"
  echo "   phase=$phase track=$track | dev_selftest=$dev qc_status=$qc trace=$trace"
  hygiene "$f" || fail=1

  # Chỉ enforce khi package tuyên bố đang/đã tới ship.
  case "$phase" in
    ship|done)
      [[ "$dev" == "pass" ]] || { echo "   ✗ dev_selftest chưa pass"; fail=1; }
      if [[ "${FAST_TRACK:-}" == "1" || "${HOTFIX:-}" == "1" || "$track" == "fast" || "$track" == "hotfix" ]]; then
        [[ "$qc" == "pass" || "$qc" == "na" ]] || { echo "   ✗ qc_status phải pass hoặc na (fast/hotfix)"; fail=1; }
      else
        [[ "$qc" == "pass" ]] || { echo "   ✗ qc_status chưa pass (standard track)"; fail=1; }
      fi
      [[ "$trace" == "pass" ]] || { echo "   ✗ trace chưa pass"; fail=1; }
      [[ $fail -eq 0 ]] && echo "   ✓ ship-ready"
      ;;
    "")
      echo "   ⚠ không tìm thấy state block — _context.md cần cập nhật theo template mới"
      ;;
    *)
      echo "   … chưa tới ship (phase=$phase) — bỏ qua ship gate"
      ;;
  esac
  return $fail
}

echo "=== Context State / Ship Gate ==="
FAIL=0

if [[ $# -ge 1 ]]; then
  [[ -f "$1" ]] || { echo "FAIL: không thấy file $1"; exit 1; }
  check_one "$1" || FAIL=1
else
  shopt -s nullglob
  found=0
  for f in docs/work/*/_context.md; do
    found=1
    check_one "$f" || FAIL=1
  done
  [[ $found -eq 0 ]] && echo "(không có docs/work/*/_context.md — chưa có work package nào)"
fi

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "PASS: state OK."
  exit 0
else
  echo "FAIL: hygiene hoặc ship-ready — xem trên. Escape: FAST_TRACK=1 / HOTFIX=1 / GOVERNANCE_SKIP=1"
  exit 1
fi

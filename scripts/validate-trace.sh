#!/usr/bin/env bash
# Validate @trace.implements / @trace.verifies against BDD specs.
# Usage: ./scripts/validate-trace.sh [--uc UC-LMS-001] [root-dir]
# Exit 0 = no GAP blockers; Exit 1 = GAP found; Exit 2 = config error.
set -euo pipefail

ROOT="${1:-.}"
if [[ "${1:-}" == "--uc" ]]; then
  UC_FILTER="${2:-}"
  ROOT="${3:-.}"
else
  UC_FILTER=""
  [[ -d "${1:-}" ]] && ROOT="$1"
fi

# ── Resolve paths from project-context.yaml ──────────────────────────────────
BDD_DIR="docs/specs/bdd"
TRACE_DIR="docs/trace"
if [[ -f "$ROOT/project-context.yaml" ]]; then
  _bdd=$(grep -E '^\s*bdd_specs:' "$ROOT/project-context.yaml" 2>/dev/null \
    | sed 's/.*bdd_specs:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//' | tr -d '\r' || true)
  _trace=$(grep -E '^\s*trace_dir:' "$ROOT/project-context.yaml" 2>/dev/null \
    | sed 's/.*trace_dir:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//' | tr -d '\r' || true)
  [[ -n "$_bdd" ]]   && BDD_DIR="$_bdd"
  [[ -n "$_trace" ]] && TRACE_DIR="$_trace"
fi

BDD_PATH="$ROOT/$BDD_DIR"
if [[ ! -d "$BDD_PATH" ]]; then
  echo "WARN: BDD directory not found: $BDD_PATH (skip trace validation)"
  exit 0
fi

# ── Validation ────────────────────────────────────────────────────────────────
shopt -s globstar nullglob 2>/dev/null || true

GAP_COUNT=0
OK_COUNT=0
WARN_COUNT=0

echo "=== Trace Validation ==="
echo "BDD: $BDD_PATH"
echo "Trace Dir: $TRACE_DIR"
echo ""

validate_uc() {
  local feature_file="$1"
  local uc_id
  uc_id=$(grep -E '# @trace\.uc_id:' "$feature_file" 2>/dev/null | head -1 \
    | sed 's/.*uc_id:[[:space:]]*//' | tr -d '\r' || true)
  [[ -z "$uc_id" ]] && uc_id=$(basename "$feature_file" .feature)

  echo "## UC: $uc_id ($feature_file)"

  local sc_ids=()
  while IFS= read -r line; do
    sc_ids+=("$line")
  done < <(grep -oE 'SC[0-9]+' "$feature_file" 2>/dev/null | sort -u || true)

  if [[ ${#sc_ids[@]} -eq 0 ]]; then
    echo "  WARN: No SC-IDs found (add # SC1 comments before scenarios)"
    ((WARN_COUNT++)) || true
    echo ""
    return
  fi

  local tsv_file="$ROOT/$TRACE_DIR/${uc_id}-trace.tsv"
  if [[ ! -f "$tsv_file" ]]; then
    echo "  FAIL: Trace TSV file missing: $tsv_file"
    for sc in "${sc_ids[@]}"; do
      echo "  ${uc_id}-${sc}: GAP (no trace TSV)"
      ((GAP_COUNT++)) || true
    done
    echo ""
    return
  fi

  for sc in "${sc_ids[@]}"; do
    local tag="${uc_id}-${sc}"
    
    local row
    row=$(grep -E "^${uc_id}[[:space:]]+${sc}[[:space:]]" "$tsv_file" | tr -d '\r' | head -1 || echo "")
    
    if [[ -z "$row" ]]; then
      echo "  $tag: GAP (no entry in trace TSV)"
      ((GAP_COUNT++)) || true
      continue
    fi

    local impl_val
    local verify_val
    impl_val=$(echo "$row" | cut -d$'\t' -f4 | xargs 2>/dev/null || echo "-")
    verify_val=$(echo "$row" | cut -d$'\t' -f5 | xargs 2>/dev/null || echo "-")

    [[ -z "$impl_val" ]] && impl_val="-"
    [[ -z "$verify_val" ]] && verify_val="-"

    local impl_ok=1
    local impl_msg=""
    if [[ "$impl_val" != "-" && -n "$impl_val" ]]; then
      if [[ "$impl_val" == *"::"* ]]; then
        local impl_path="${impl_val%%::*}"
        local impl_symbol="${impl_val##*::}"
        if [[ ! -f "$ROOT/$impl_path" ]]; then
          impl_ok=0
          impl_msg=" (file '$impl_path' not found)"
        elif ! grep -qF "$impl_symbol" "$ROOT/$impl_path"; then
          impl_ok=0
          impl_msg=" (symbol '$impl_symbol' not found in '$impl_path')"
        fi
      else
        impl_ok=0
        impl_msg=" (invalid format, expected path::symbol)"
      fi
    else
      impl_ok=0
      impl_msg=" (no mapping)"
    fi

    local verify_ok=1
    local verify_msg=""
    if [[ "$verify_val" != "-" && -n "$verify_val" ]]; then
      if [[ "$verify_val" == *"::"* ]]; then
        local verify_path="${verify_val%%::*}"
        local verify_symbol="${verify_val##*::}"
        if [[ ! -f "$ROOT/$verify_path" ]]; then
          verify_ok=0
          verify_msg=" (file '$verify_path' not found)"
        elif ! grep -qF "$verify_symbol" "$ROOT/$verify_path"; then
          verify_ok=0
          verify_msg=" (symbol '$verify_symbol' not found in '$verify_path')"
        fi
      else
        verify_ok=0
        verify_msg=" (invalid format, expected path::symbol)"
      fi
    else
      verify_ok=0
      verify_msg=" (no mapping)"
    fi

    local status="OK"
    if [[ $impl_ok -eq 0 && $verify_ok -eq 0 ]]; then
      status="GAP (impl error${impl_msg}, test error${verify_msg})"
      ((GAP_COUNT++)) || true
    elif [[ $impl_ok -eq 0 ]]; then
      status="GAP (impl error${impl_msg})"
      ((GAP_COUNT++)) || true
    elif [[ $verify_ok -eq 0 ]]; then
      status="GAP (test error${verify_msg})"
      ((GAP_COUNT++)) || true
    else
      ((OK_COUNT++)) || true
    fi

    echo "  $tag: impl='$impl_val' test='$verify_val' → $status"
  done
  echo ""
}

# ── 5. Validate Quality Signals in Trace TSVs ────────────────────────────────
validate_tsv_signals() {
  local tsv_path="$ROOT/$TRACE_DIR"
  if [[ ! -d "$tsv_path" ]]; then
    return 0
  fi

  local tsv_fail=0
  for tsv in "$tsv_path"/*.tsv; do
    [[ -f "$tsv" ]] || continue
    echo "## Checking TSV: $(basename "$tsv")"

    # Schema 10 cột (xem rules/_global/traceability.mdc):
    # uc_id scenario_id spec_file implements_tag verifies_tag dev_selftest qc_status last_updated owner note
    local line_num=1
    while IFS=$'\t' read -r uc_id scenario_id spec_file implements_tag verifies_tag dev_selftest qc_status last_updated owner note || [[ -n "$uc_id" ]]; do
      ((line_num++)) || true
      uc_id=$(echo "$uc_id" | tr -d '\r' | xargs 2>/dev/null || echo "")
      [[ "$uc_id" == "uc_id" || -z "$uc_id" ]] && continue    # skip header + dòng trống

      local row_id="${uc_id}-$(echo "$scenario_id" | tr -d '\r' | xargs)"
      implements_tag=$(echo "$implements_tag" | tr -d '\r' | xargs 2>/dev/null || echo "-")
      verifies_tag=$(echo "$verifies_tag" | tr -d '\r' | xargs 2>/dev/null || echo "-")
      dev_selftest=$(echo "$dev_selftest" | tr -d '\r' | xargs 2>/dev/null || echo "-")
      qc_status=$(echo "$qc_status" | tr -d '\r' | xargs 2>/dev/null || echo "-")

      if [[ -n "$implements_tag" && "$implements_tag" != "-" && "$dev_selftest" != "pass" ]]; then
        echo "  FAIL: Line $line_num ($row_id): có implements_tag '$implements_tag' nhưng dev_selftest='$dev_selftest' (expected 'pass')"
        tsv_fail=1
      fi

      if [[ -n "$verifies_tag" && "$verifies_tag" != "-" && "$qc_status" != "pass" ]]; then
        echo "  FAIL: Line $line_num ($row_id): có verifies_tag '$verifies_tag' nhưng qc_status='$qc_status' (expected 'pass')"
        tsv_fail=1
      fi
    done < "$tsv"
  done

  if [[ $tsv_fail -eq 1 ]]; then
    echo "FAIL: Quality signals (dev_selftest / qc_status) failed validation in TSV trace files."
    GAP_COUNT=$((GAP_COUNT + 1))
  else
    echo "  OK: TSV quality signals satisfied."
  fi
  echo ""
}

for f in "$BDD_PATH"/*.feature; do
  [[ -f "$f" ]] || continue
  base=$(basename "$f" .feature)
  if [[ -n "$UC_FILTER" && "$base" != "$UC_FILTER" && "$UC_FILTER" != *"$base"* ]]; then
    continue
  fi
  validate_uc "$f"
done

# Chạy kiểm định tín hiệu chất lượng trong file TSV
validate_tsv_signals

echo "=== Summary ==="
echo "OK: $OK_COUNT | GAP: $GAP_COUNT | WARN: $WARN_COUNT"

if [[ $GAP_COUNT -gt 0 ]]; then
  echo "FAIL: $GAP_COUNT scenario(s) missing implementation, test coverage or quality signals."
  exit 1
fi

echo "PASS: No GAP blockers."
exit 0

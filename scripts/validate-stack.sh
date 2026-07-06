#!/usr/bin/env bash
# Verify stack rules exist for project-context.yaml stack value.
# Usage: ./scripts/validate-stack.sh
# Exit 0 = OK or stack not configured; Exit 1 = stack configured but rules missing.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

STACK=""
if [[ -f project-context.yaml ]]; then
  STACK=$(grep -E '^stack:' project-context.yaml 2>/dev/null | sed 's/stack:[[:space:]]*//' | tr -d '\r' | head -1)
fi

if [[ -z "$STACK" ]]; then
  echo "WARN: No stack configured in project-context.yaml"
  exit 0
fi

echo "=== Stack Validation ==="
echo "Stack: $STACK"

MISSING=0
for rule in architecture test-patterns; do
  path="rules/$STACK/$rule.mdc"
  if [[ -f "$path" ]]; then
    echo "  OK: $path"
  else
    echo "  MISSING: $path"
    echo "    → Copy from rules/_template/$rule.mdc and customize for your stack."
    MISSING=$((MISSING + 1))
  fi
done

if [[ $MISSING -gt 0 ]]; then
  echo ""
  echo "FAIL: $MISSING stack rule file(s) missing. Dev must create before qc-automation/tdd can load conventions."
  exit 1
fi

echo "PASS: Stack rules present."
exit 0

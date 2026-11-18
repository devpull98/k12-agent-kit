#!/usr/bin/env bash
# Work item gate: mọi docs/work/<ID>-<slug>/ phải có _context.md với frontmatter hợp lệ,
# module thuộc registry (docs/modules.yaml), ID duy nhất; không thêm file mới vào thư mục legacy.
# Usage: ./scripts/validate-work-items.sh [base-ref]
# Config (project-context.yaml): work_items_strict: false  → package thiếu frontmatter chỉ WARN (giai đoạn migrate)
# Escape: GOVERNANCE_SKIP=1
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${WORK_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || (cd "$SCRIPT_DIR/.." && pwd))}"
cd "$ROOT"
source "$SCRIPT_DIR/lib/work-lib.sh"

if [[ "${GOVERNANCE_SKIP:-}" == "1" ]]; then echo "SKIP: GOVERNANCE_SKIP=1"; exit 0; fi

STRICT=1
if [[ -f project-context.yaml ]] && grep -qE '^work_items_strict:[[:space:]]*false' project-context.yaml; then STRICT=0; fi

FAIL=0; WARN=0
fail() { echo "  ✗ $*"; FAIL=1; }
warn() { echo "  ⚠ $*"; WARN=$((WARN+1)); }
soft() { if [[ $STRICT -eq 1 ]]; then fail "$*"; else warn "$* (work_items_strict: false)"; fi; }

echo "=== Work Items Gate ($([[ $STRICT -eq 1 ]] && echo strict || echo lenient)) ==="

[[ -d "$WORK_DIR" ]] || { echo "(không có $WORK_DIR — bỏ qua)"; exit 0; }
items=$(wl_item_dirs)
if [[ -n "$items" && ! -f "$REGISTRY" ]]; then
  soft "Thiếu $REGISTRY — copy templates/modules.template.yaml và khai báo module (prefix, paths)"
fi
REG_KEYS=$(wl_registry_keys | tr '\n' ' ')

# Toàn bộ kiểm tra frontmatter trong 1 lần awk (spawn process/field quá chậm trên Windows).
# Ngày → số ngày theo công thức civil-from-days (không cần mktime — chạy được với mawk/busybox).
TODAY=$(wl_today)
while IFS=$'\t' read -r kind msg; do
  case "$kind" in
    F) fail "$msg" ;; S) soft "$msg" ;; W) warn "$msg" ;;
  esac
done < <(wl_fm_table id title type status priority modules created updated closed phase fixes relates_to supersedes | awk -F'\t' \
  -v types="$WL_TYPES" -v statuses="$WL_STATUSES" -v phases="$WL_PHASES" -v prios="$WL_PRIORITIES" \
  -v openst="$WL_OPEN_STATUSES" -v regkeys="$REG_KEYS" -v reg="$REGISTRY" -v today="$TODAY" -v stale="${WORK_STALE_DAYS:-14}" '
  function set(str, arr,   n, a, i) { n=split(str, a, " "); for (i=1;i<=n;i++) arr[a[i]]=1 }
  function days(d,   y, m, dd, era, yoe, doy, doe) {
    if (d !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) return -1
    y=substr(d,1,4)+0; m=substr(d,6,2)+0; dd=substr(d,9,2)+0; if (m<=2) y--
    era=int(y/400); yoe=y-era*400; doy=int((153*(m>2?m-3:m+9)+2)/5)+dd-1
    doe=yoe*365+int(yoe/4)-int(yoe/100)+doy; return era*146097+doe }
  BEGIN { set(types,T); set(statuses,ST); set(phases,PH); set(prios,PR); set(openst,OP); set(regkeys,RK)
          nreq=split("id title type status priority modules created updated", REQ, " ")
          COL["id"]=4; COL["title"]=5; COL["type"]=6; COL["status"]=7; COL["priority"]=8; COL["modules"]=9; COL["created"]=10; COL["updated"]=11
          td=days(today) }
  {
    d=$1
    if ($2==0) { print "S\t" d ": thiếu _context.md"; next }
    if ($3==0) { print "S\t" d ": _context.md chưa có frontmatter (bash scripts/work.sh migrate)"; next }
    for (i=1;i<=nreq;i++) { c=COL[REQ[i]]; if ($c=="!") print "F\t" d ": thiếu field \x27" REQ[i] "\x27" }
    id=$4; ty=$6; st=$7; pr=$8; mods=$9; up=$11; cl=$12; ph=$13
    if (id !~ /^[A-Z][A-Z0-9]*(-[A-Z][A-Z0-9]*)*-[0-9]+$/) print "F\t" d ": id \x27" id "\x27 sai format (vd SOCKETIO-012, EDC-5681)"
    if (d != id && index(d, id "-") != 1) print "F\t" d ": tên folder phải bắt đầu bằng id \x27" id "-\x27"
    if (id in SEEN) print "F\t" d ": id \x27" id "\x27 bị trùng với " SEEN[id]; else SEEN[id]=d
    if ($5=="-" || $5=="!") print "F\t" d ": title rỗng"
    if (!(ty in T)) print "F\t" d ": type \x27" ty "\x27 ∉ {" types "}"
    if (!(st in ST)) print "F\t" d ": status \x27" st "\x27 ∉ {" statuses "}"
    if (ph!="-" && ph!="!" && !(ph in PH)) print "F\t" d ": phase \x27" ph "\x27 ∉ {" phases "}"
    if (!(pr in PR)) print "F\t" d ": priority \x27" pr "\x27 ∉ {" prios "}"
    if (mods=="-" || mods=="!") print "F\t" d ": modules rỗng — mỗi item phải gắn ≥1 module"
    else if (regkeys!="") { n=split(mods, M, " "); for (i=1;i<=n;i++) if (!(M[i] in RK)) print "F\t" d ": module \x27" M[i] "\x27 không có trong " reg }
    if ((st=="done" || st=="cancelled") && (cl=="-" || cl=="!")) print "F\t" d ": status=" st " nhưng thiếu \x27closed\x27 (YYYY-MM-DD)"
    u=days(up); if ((st in OP) && u>=0 && td>=0 && td-u>stale) print "W\t" d ": status=" st " nhưng không cập nhật " (td-u) " ngày (stale)"
    LINKS[d]=$14 "|" $15 "|" $16
  }
  END {
    for (d in LINKS) { split(LINKS[d], L, "|"); names[1]="fixes"; names[2]="relates_to"; names[3]="supersedes"
      for (j=1;j<=3;j++) { if (L[j]=="-" || L[j]=="!") continue; n=split(L[j], R, " ")
        for (i=1;i<=n;i++) if (!(R[i] in SEEN)) print "W\t" d ": " names[j] " → \x27" R[i] "\x27 không phải work item đã biết" } }
  }')

# Không thêm file mới vào thư mục legacy (so với base)
BASE="${1:-}"
if [[ -z "$BASE" ]]; then
  # Chọn nhánh gốc GẦN HEAD nhất (ít commit chênh nhất) — repo có thể có origin/main bỏ hoang
  # trong khi trunk thật là master (hoặc ngược lại); lấy theo thứ tự cố định sẽ báo nhầm.
  best_n=""
  for b in origin/HEAD origin/main origin/master origin/develop main master develop; do
    git rev-parse --verify -q "$b" >/dev/null 2>&1 || continue
    mb=$(git merge-base "$b" HEAD 2>/dev/null) || continue
    n=$(git rev-list --count "$mb"..HEAD 2>/dev/null || echo 999999)
    if [[ -z "$best_n" || "$n" -lt "$best_n" ]]; then best_n=$n; BASE="$b"; fi
  done
fi
if [[ -n "$BASE" ]] && git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  added=$(git diff --name-only --diff-filter=A "$BASE"...HEAD -- docs/plans docs/features docs/test-plans docs/notes docs/logs docs/bugs 2>/dev/null || true)
  added="$added
$(git ls-files --others --exclude-standard -- docs/plans docs/features docs/test-plans docs/notes docs/logs docs/bugs 2>/dev/null || true)"
  while IFS= read -r a; do
    [[ -z "$a" ]] && continue
    fail "File mới trong thư mục legacy: $a → đặt vào docs/work/<ID>-<slug>/ (rules/_global/work-items.mdc)"
  done <<<"$added"
fi

# INDEX.md lỗi thời
if [[ -f "$WORK_DIR/INDEX.md" ]]; then
  tmpi=$(mktemp)
  WORK_INDEX_OUT="$tmpi" bash "$SCRIPT_DIR/work.sh" index >/dev/null 2>&1 || true
  if ! diff -q <(tr -d '\r' < "$tmpi") <(tr -d '\r' < "$WORK_DIR/INDEX.md") >/dev/null 2>&1; then
    warn "$WORK_DIR/INDEX.md lỗi thời — chạy: bash scripts/work.sh index"
  fi
  rm -f "$tmpi"
fi

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "PASS: work items hợp lệ ($WARN warning)."
  exit 0
else
  echo "FAIL: sửa các mục trên (bash scripts/work.sh set <ID> key=value | work.sh migrate). Escape: GOVERNANCE_SKIP=1"
  exit 1
fi

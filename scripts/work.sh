#!/usr/bin/env bash
# Work Item tracker — "GitHub Issues trong repo".
# Source of truth: frontmatter của docs/work/<ID>-<slug>/_context.md. Board sinh tự động.
#
# Usage:
#   bash scripts/work.sh new <type> <module> "<title>" [--jira KEY] [--fixes ID] [--priority P2] [--track standard]
#   bash scripts/work.sh set <ID> key=value [key=value ...]     # vd: status=review phase=review
#   bash scripts/work.sh index                                   # sinh docs/work/INDEX.md (board)
#   bash scripts/work.sh list [status|module|type ...]           # lọc nhanh ra terminal
#   bash scripts/work.sh history <module-key|ID> [--git]         # timeline module / chi tiết 1 item
#   bash scripts/work.sh migrate [--registry FILE] [--apply] [--report FILE]
#
# Xem rules/_global/work-items.mdc.
set -euo pipefail

# Chạy được cả khi script nằm trong plugin: project = WORK_ROOT | git toplevel của cwd | thư mục cha script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${WORK_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || (cd "$SCRIPT_DIR/.." && pwd))}"
cd "$ROOT"
# shellcheck source=lib/work-lib.sh
source "$SCRIPT_DIR/lib/work-lib.sh"

die() { echo "ERROR: $*" >&2; exit 1; }
need_registry() { [[ -f "$REGISTRY" ]] || die "Chưa có $REGISTRY — copy templates/modules.template.yaml và khai báo module."; }

# ─────────────────────────────────────────────────────────────────────────────
cmd_new() {
  local type="${1:-}" module="${2:-}" title="${3:-}"; shift 3 || die "Usage: work.sh new <type> <module> \"<title>\" [--jira KEY] [--fixes ID]"
  local jira="" fixes="" priority="P2" track="standard"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --jira) jira="$2"; shift 2 ;;
      --fixes) fixes="$2"; shift 2 ;;
      --priority) priority="$2"; shift 2 ;;
      --track) track="$2"; shift 2 ;;
      *) die "Tham số lạ: $1" ;;
    esac
  done
  wl_in "$type" "$WL_TYPES" || die "type '$type' không hợp lệ ($WL_TYPES)"
  wl_in "$priority" "$WL_PRIORITIES" || die "priority '$priority' không hợp lệ ($WL_PRIORITIES)"
  [[ -n "$title" ]] || die "Thiếu title"
  need_registry
  local prefix; prefix=$(wl_registry_get "$module" 2)
  [[ -n "$prefix" ]] || die "Module '$module' không có trong $REGISTRY (có: $(wl_registry_keys | tr '\n' ' '))"

  local id
  if [[ -n "$jira" ]]; then id="$jira"; else id=$(wl_next_id "$prefix"); fi
  [[ "$id" =~ $WL_ID_RE ]] || die "ID '$id' sai format (vd SOCKETIO-012, EDC-5681)"
  wl_find_item "$id" >/dev/null 2>&1 && die "ID $id đã tồn tại"

  local slug; slug=$(wl_slug "$title"); [[ -n "$slug" ]] || slug="item"
  local dir="$WORK_DIR/$id-$slug"
  mkdir -p "$dir"

  local tpl=""
  for t in "$ROOT/templates/_context.template.md" "$SCRIPT_DIR/../templates/_context.template.md" "${CLAUDE_PLUGIN_ROOT:-/nonexistent}/templates/_context.template.md"; do
    [[ -f "$t" ]] && { tpl="$t"; break; }
  done
  if [[ -n "$tpl" ]]; then cp "$tpl" "$dir/_context.md"; else printf -- '---\nid: x\n---\n# <ID> — <TITLE>\n' > "$dir/_context.md"; fi
  wl_has_fm "$dir/_context.md" || die "Template $tpl thiếu frontmatter"

  local today; today=$(wl_today)
  local esc_title=${title//\"/\'}
  wl_fm_set "$dir/_context.md" id "$id"
  wl_fm_set "$dir/_context.md" title "\"$esc_title\""
  wl_fm_set "$dir/_context.md" type "$type"
  wl_fm_set "$dir/_context.md" status "todo"
  wl_fm_set "$dir/_context.md" priority "$priority"
  wl_fm_set "$dir/_context.md" modules "[$module]"
  wl_fm_set "$dir/_context.md" track "$track"
  wl_fm_set "$dir/_context.md" phase "discovery"
  wl_fm_set "$dir/_context.md" created "$today"
  wl_fm_set "$dir/_context.md" updated "$today"
  wl_fm_set "$dir/_context.md" jira "\"$jira\""
  [[ -n "$fixes" ]] && wl_fm_set "$dir/_context.md" fixes "[$fixes]"
  local tmp; tmp=$(mktemp)
  sed -e "s|<ID>|$id|g" -e "s|<TITLE>|${esc_title//|/-}|g" -e "s|<module>|$module|g" "$dir/_context.md" > "$tmp" && cat "$tmp" > "$dir/_context.md"; rm -f "$tmp"

  echo "✓ Tạo $dir/_context.md"
  echo "  ID: $id · branch gợi ý: $( [[ $type == bug ]] && echo fix || echo feat )/$id-$slug"
  echo "  Commit sẽ tự gắn trailer 'Work-Item: $id' (hook prepare-commit-msg)."
}

# ─────────────────────────────────────────────────────────────────────────────
cmd_set() {
  local id="${1:-}"; shift || true
  [[ -n "$id" && $# -gt 0 ]] || die "Usage: work.sh set <ID> key=value ..."
  local d; d=$(wl_find_item "$id") || die "Không thấy work item $id"
  local f="$WORK_DIR/$d/_context.md"
  wl_has_fm "$f" || die "$f chưa có frontmatter — chạy work.sh migrate trước"
  local kv k v
  for kv in "$@"; do
    k="${kv%%=*}"; v="${kv#*=}"
    case "$k" in
      status)   wl_in "$v" "$WL_STATUSES"   || die "status '$v' ∉ {$WL_STATUSES}" ;;
      phase)    wl_in "$v" "$WL_PHASES"     || die "phase '$v' ∉ {$WL_PHASES}" ;;
      type)     wl_in "$v" "$WL_TYPES"      || die "type '$v' ∉ {$WL_TYPES}" ;;
      priority) wl_in "$v" "$WL_PRIORITIES" || die "priority '$v' ∉ {$WL_PRIORITIES}" ;;
      id) die "Không đổi id bằng set" ;;
      title) v="\"${v//\"/\'}\"" ;;
    esac
    wl_fm_set "$f" "$k" "$v"
    if [[ "$k" == "status" ]] && wl_in "$v" "done cancelled" && [[ -z "$(wl_fm "$f" closed)" ]]; then
      wl_fm_set "$f" closed "$(wl_today)"
    fi
  done
  wl_fm_set "$f" updated "$(wl_today)"
  echo "✓ $id: $*"
}

# ─────────────────────────────────────────────────────────────────────────────
# Cột rỗng → "-": IFS=tab là whitespace nên `read` gộp tab liên tiếp, làm lệch cột.
nz() { if [[ -n "$1" ]]; then printf '%s' "$1"; else printf -- '-'; fi; }

# Cache 1 lần/lần chạy (items + bugs) — tránh parse lại khi index gọi nhiều view.
_ITEMS_CACHE=""; _BUGS_CACHE=""
_load_cache() {
  [[ -n "$_ITEMS_CACHE" ]] && return 0
  _BUGS_CACHE=$(mktemp); _ITEMS_CACHE=$(mktemp)
  wl_all_bugs_tsv > "$_BUGS_CACHE"
  # id title type status priority modules created updated closed phase next_skill folder bugs_open bugs_total fixes
  wl_fm_table id title type status priority modules created updated closed phase next_skill fixes | awk -F'\t' -v bf="$_BUGS_CACHE" '
    BEGIN { while ((getline l < bf) > 0) { split(l, c, "\t"); T[c[1]]++; if (c[3]=="open" || c[3]=="unknown") O[c[1]]++ } }
    $3==1 { for (i=4;i<=15;i++) { v[i]=$i; if (v[i]=="!") v[i]="-" } gsub(/\|/," ",v[5])
            print v[4] "\t" v[5] "\t" v[6] "\t" v[7] "\t" v[8] "\t" v[9] "\t" v[10] "\t" v[11] "\t" v[12] "\t" v[13] "\t" v[14] "\t" $1 "\t" (O[$1]+0) "\t" (T[$1]+0) "\t" v[15] }' > "$_ITEMS_CACHE"
}
_cleanup_cache() { rm -f "${_ITEMS_CACHE:-}" "${_BUGS_CACHE:-}"; }
trap _cleanup_cache EXIT

# TSV mọi item có frontmatter (cột rỗng = "-"):
# id title type status priority modules created updated closed phase next_skill folder bugs_open bugs_total fixes
items_tsv() { _load_cache; cat "$_ITEMS_CACHE"; }

# Bug đang mở: item type=bug chưa đóng + entry trong bugs.md
# → TSV: bug_id severity status parent_id title folder
open_bugs_tsv() {
  _load_cache
  awk -F'\t' '$3=="bug" && $4!="done" && $4!="cancelled" { print $1 "\t" $5 "\t" $4 "\t" $15 "\t" $2 "\t" $12 }' "$_ITEMS_CACHE"
  awk -F'\t' -v itf="$_ITEMS_CACHE" '
    BEGIN { while ((getline l < itf) > 0) { split(l, c, "\t"); ID[c[12]]=c[1] } }
    $3=="open" || $3=="unknown" { pid=($1 in ID) ? ID[$1] : $1; t=$5; gsub(/\|/,"/",t); t=substr(t,1,90)
                                  print $2 "\t" ($4==""?"-":$4) "\t" $3 "\t" pid "\t" t "\t" $1 }' "$_BUGS_CACHE"
}

stale_mark() {  # stale_mark <status> <updated>
  local days; days=$(wl_days_since "$2")
  if wl_in "$1" "$WL_OPEN_STATUSES" && [[ -n "$days" ]] && (( days > ${WORK_STALE_DAYS:-14} )); then echo " ⚠${days}d"; fi
}

cmd_index() {
  local out="${WORK_INDEX_OUT:-$WORK_DIR/INDEX.md}" tsv; tsv=$(mktemp)
  items_tsv > "$tsv"
  {
    echo "# Work Board"
    echo
    echo "> Sinh tự động bởi \`bash scripts/work.sh index\` — **KHÔNG sửa tay**. Source of truth: frontmatter của \`docs/work/*/_context.md\`."
    echo "> Lịch sử 1 module: \`bash scripts/work.sh history <module> --git\` · 1 item: \`bash scripts/work.sh history <ID> --git\`"
    echo
    echo "## Tổng quan"
    echo
    echo "| Status | Số item |"
    echo "|--------|---------|"
    for s in $WL_STATUSES; do
      local c; c=$(awk -F'\t' -v s="$s" '$4==s' "$tsv" | wc -l | tr -d ' ')
      [[ "$c" != "0" ]] && echo "| $s | $c |"
    done
    echo
    echo "## 🔥 Đang chạy"
    echo
    echo "| ID | Title | Type | Modules | Status | Phase | Prio | Next skill | Bugs mở | Updated |"
    echo "|----|-------|------|---------|--------|-------|------|------------|---------|---------|"
    for s in blocked in-progress review qc ready; do
      awk -F'\t' -v s="$s" '$4==s' "$tsv" | sort -t$'\t' -k5,5 -k8,8r | while IFS=$'\t' read -r id title type status pr mods cr up cl ph nx folder bo bt fx; do
        echo "| [$id]($folder/_context.md) | $title | $type | $mods | **$status** | $ph | $pr | ${nx:--} | $bo | $up$(stale_mark "$status" "$up") |"
      done
    done
    echo
    echo "## 🐞 Bug đang mở"
    echo
    echo "| Bug | Severity | Status | Thuộc item | Tóm tắt |"
    echo "|-----|----------|--------|------------|---------|"
    open_bugs_tsv | sort -t$'\t' -k2,2 | while IFS=$'\t' read -r bid sev st pid btitle folder; do
      local link="$folder/_context.md"; [[ -f "$WORK_DIR/$folder/bugs.md" && "$bid" != "$pid" ]] && link="$folder/bugs.md"
      echo "| [$bid]($link) | $sev | $st | $pid | $btitle |"
    done
    echo
    echo "## 📋 Backlog / Todo"
    echo
    echo "| ID | Title | Type | Modules | Prio | Created |"
    echo "|----|-------|------|---------|------|---------|"
    awk -F'\t' '$4=="todo"||$4=="backlog"' "$tsv" | sort -t$'\t' -k5,5 -k7,7 | while IFS=$'\t' read -r id title type status pr mods cr up cl ph nx folder bo bt fx; do
      echo "| [$id]($folder/_context.md) | $title | $type | $mods | $pr | $cr |"
    done
    echo
    echo "## 🗂 Theo module (lịch sử, mới nhất trước)"
    local keys; keys=$( { wl_registry_keys; cut -f6 "$tsv" | tr ' ' '\n'; } | grep -v '^$' | awk '!seen[$0]++')
    for m in $keys; do
      local rows; rows=$(awk -F'\t' -v m="$m" '{ n=split($6,a," "); for(i=1;i<=n;i++) if(a[i]==m){print; break} }' "$tsv" | sort -t$'\t' -k7,7r)
      [[ -z "$rows" ]] && continue
      local total open; total=$(printf '%s\n' "$rows" | wc -l | tr -d ' ')
      open=$(printf '%s\n' "$rows" | awk -F'\t' '$4!="done"&&$4!="cancelled"' | wc -l | tr -d ' ')
      local mt; mt=$(wl_registry_get "$m" 3)
      echo
      echo "### $m${mt:+ — $mt} ($total item, $open chưa đóng)"
      echo
      echo "| ID | Type | Title | Status | Created | Closed | Bugs (mở/tổng) |"
      echo "|----|------|-------|--------|---------|--------|----------------|"
      printf '%s\n' "$rows" | while IFS=$'\t' read -r id title type status pr mods cr up cl ph nx folder bo bt fx; do
        echo "| [$id]($folder/_context.md) | $type | $title | $status | $cr | ${cl:--} | $bo/$bt |"
      done
    done
    echo
    local legacy=""
    legacy=$(wl_fm_table id | awk -F'	' '$3==0{printf " %s", $1}')
    if [[ -n "$legacy" ]]; then
      echo "## ⚠ Chưa chuẩn hóa (thiếu frontmatter — chạy \`bash scripts/work.sh migrate\`)"
      echo
      for d in $legacy; do echo "- \`$d\`"; done
      echo
    fi
  } > "$out"
  rm -f "$tsv"
  echo "✓ Ghi $out"
}

cmd_list() {
  local filters="$*"
  items_tsv | while IFS=$'\t' read -r id title type status pr mods cr up cl ph nx folder bo bt fx; do
    if [[ -n "$filters" ]]; then
      local hit=0 x
      for x in $filters; do
        { [[ "$status" == "$x" || "$type" == "$x" ]] || wl_in "$x" "$mods"; } && hit=1
      done
      [[ $hit -eq 1 ]] || continue
    fi
    printf '%-18s %-9s %-12s %-4s %-24s %s\n' "$id" "$type" "$status" "$pr" "$mods" "$title"
  done
}

cmd_history() {
  local target="${1:-}" git=0; [[ "${2:-}" == "--git" ]] && git=1
  [[ -n "$target" ]] || die "Usage: work.sh history <module-key|ID> [--git]"
  local tsv; tsv=$(mktemp); items_tsv > "$tsv"
  if awk -F'\t' -v t="$target" '$1==t{f=1} END{exit !f}' "$tsv"; then
    # ── 1 item ──
    local row folder; row=$(awk -F'\t' -v t="$target" '$1==t' "$tsv"); folder=$(cut -f12 <<<"$row")
    local f="$WORK_DIR/$folder/_context.md"
    echo "## $target — $(cut -f2 <<<"$row")"
    echo "type=$(cut -f3 <<<"$row") status=$(cut -f4 <<<"$row") phase=$(cut -f10 <<<"$row") modules=[$(cut -f6 <<<"$row")]"
    echo "created=$(cut -f7 <<<"$row") updated=$(cut -f8 <<<"$row") closed=$(cut -f9 <<<"$row")"
    for k in fixes relates_to supersedes prs; do local v; v=$(wl_fm "$f" "$k"); [[ -n "$v" ]] && echo "$k: $v"; done
    echo; echo "### Item liên kết tới $target"
    local d; for d in $(wl_item_dirs); do
      local cf="$WORK_DIR/$d/_context.md"; wl_has_fm "$cf" || continue
      for k in fixes relates_to supersedes; do
        wl_in "$target" "$(wl_fm "$cf" "$k")" && echo "- $(wl_fm "$cf" id) ($k) — $(wl_fm "$cf" title) [$(wl_fm "$cf" status)]"
      done
    done
    if [[ -f "$WORK_DIR/$folder/bugs.md" ]]; then
      echo; echo "### Bugs"; wl_bugs_tsv "$WORK_DIR/$folder/bugs.md" | awk -F'\t' '{printf "- %s [%s/%s] %s\n",$1,$2,($3==""?"?":$3),$4}'
    fi
    if [[ $git -eq 1 ]] && git rev-parse --git-dir >/dev/null 2>&1; then
      echo; echo "### Commits (grep '$target' + đổi trong work package)"
      { git log --all --format='%as %h %s' --grep="$target" 2>/dev/null; git log --format='%as %h %s' -- "$WORK_DIR/$folder" 2>/dev/null; } | sort -ru | head -50
    fi
  else
    # ── module ──
    local rows; rows=$(awk -F'\t' -v m="$target" '{ n=split($6,a," "); for(i=1;i<=n;i++) if(a[i]==m){print; break} }' "$tsv" | sort -t$'\t' -k7,7)
    [[ -n "$rows" ]] || { rm -f "$tsv"; die "Không thấy item/module '$target'"; }
    echo "## Lịch sử module $target (cũ → mới)"
    printf '%s\n' "$rows" | while IFS=$'\t' read -r id title type status pr mods cr up cl ph nx folder bo bt fx; do
      printf '%s  %-16s %-9s %-11s bugs %s/%s  %s\n' "${cr:-????-??-??}" "$id" "$type" "$status" "$bo" "$bt" "$title"
    done
    echo; echo "### Bug đang mở"
    open_bugs_tsv | while IFS=$'\t' read -r bid sev st pid btitle folder; do
      printf '%s\n' "$rows" | cut -f1 | grep -qxF "$pid" && echo "- $bid [$sev] ($pid) $btitle"
    done || true
    if [[ $git -eq 1 ]] && git rev-parse --git-dir >/dev/null 2>&1; then
      local paths; paths=$(wl_registry_get "$target" 4)
      if [[ -n "$paths" ]]; then
        echo; echo "### 30 commit gần nhất chạm code module ($paths)"
        # shellcheck disable=SC2086
        git log -n 30 --format='%as %h %s' -- $paths 2>/dev/null || true
      fi
    fi
  fi
  rm -f "$tsv"
}

# ─────────────────────────────────────────────────────────────────────────────
# migrate: chuyển work package legacy → frontmatter. Mặc định DRY-RUN (chỉ báo cáo).
legacy_field() {  # legacy_field <file> <Label>   (dòng "- **Label:** value")
  grep -m1 -iE "^\-?[[:space:]]*\*\*$2:\*\*" "$1" 2>/dev/null | sed -E "s/^.*\*\*$2:\*\*[[:space:]]*//I" | tr -d '\r' || true
}
legacy_state() {  # legacy_state <file> <key>  (dòng "key: value" bất kỳ — state block cũ)
  grep -m1 -E "^[[:space:]]*$2:" "$1" 2>/dev/null | sed -E "s/^[[:space:]]*$2:[[:space:]]*//; s/[[:space:]]+#.*$//" | tr -d '\r"' || true
}
map_type() {
  local l; l=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  local first; first=$(printf '%s' "$l" | grep -oE '^[a-z]+' || true)
  [[ "$first" == "performance" ]] && first=perf
  if wl_in "$first" "$WL_TYPES"; then echo "$first"; return; fi
  if   [[ "$l" =~ secur|vuln|authz|^sec- ]]; then echo security
  elif [[ "$l" =~ bug|fix|race|leak|storm ]]; then echo bug
  elif [[ "$l" =~ perf|latency|n\+1|n-plus|getmore|slow|load|heap|cpu|index ]]; then echo perf
  elif [[ "$l" =~ refactor|migration|migrate|move|slim|split ]]; then echo refactor
  elif [[ "$l" =~ feature|feat ]]; then echo feature
  elif [[ "$l" =~ observab|ci|chore ]]; then echo chore
  else echo ""; fi
}
map_phase() {
  local l; l=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$l" in
    discovery|analysis|investigat*) echo discovery ;;
    spec) echo spec ;; bdd) echo bdd ;; tech) echo tech ;; plan) echo plan ;;
    done|implemented*|shipped|deployed|merged) echo done ;;
    implement*|fix-applied|in-progress) echo implement ;;
    review|mr*pending*) echo review ;;
    qc) echo qc ;; trace) echo trace ;;
    ship*) echo ship ;;
    *) echo "" ;;
  esac
}
phase_to_status() {
  case "$1" in
    discovery|spec|bdd|tech|plan) echo todo ;;
    implement) echo in-progress ;;
    review) echo review ;; qc|trace) echo qc ;;
    ship) echo ready ;; done) echo done ;;
    *) echo "" ;;
  esac
}

cmd_migrate() {
  local reg="$REGISTRY" apply=0 report=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --registry) reg="$2"; shift 2 ;;
      --apply) apply=1; shift ;;
      --report) report="$2"; shift 2 ;;
      *) die "Tham số lạ: $1" ;;
    esac
  done
  [[ -f "$reg" ]] || die "Thiếu registry $reg — tạo từ templates/modules.template.yaml (hoặc --registry <file>)"
  local regtsv; regtsv=$(mktemp); wl_registry_tsv "$reg" > "$regtsv"
  local counters; counters=$(mktemp)
  local out; out=$(mktemp)
  local n_total=0 n_ok=0 n_warn=0 n_skip=0
  local is_git=0; git rev-parse --git-dir >/dev/null 2>&1 && is_git=1
  local today; today=$(wl_today)

  next_num() {  # next_num <PREFIX> — đếm trong lần chạy (bắt đầu từ max hiện có)
    local p="$1" cur
    cur=$(awk -v p="$p" '$1==p{print $2}' "$counters")
    if [[ -z "$cur" ]]; then cur=$(wl_next_id "$p"); cur=$((10#${cur##*-} - 1)); fi
    cur=$((cur + 1))
    { grep -v "^$p " "$counters" || true; echo "$p $cur"; } > "$counters.tmp"; mv "$counters.tmp" "$counters"
    printf '%s-%03d' "$p" "$cur"
  }

  match_modules() {  # stdin: text lowercase → key module theo thứ tự xuất hiện
    awk -v regf="$regtsv" '
      BEGIN { while ((getline line < regf) > 0) { split(line, c, "\t"); nk++; key[nk]=c[1]
              toks = c[1] " " c[4] " " c[5]; gsub(/\/+/," ",toks); tk[nk]=tolower(toks) } }
      { buf = buf " " $0 }
      END { for (i=1;i<=nk;i++) { best=0; n=split(tk[i], t, " ")
              for (j=1;j<=n;j++) { if (length(t[j]) < 4) continue; p=index(buf, t[j]); if (p>0 && (best==0 || p<best)) best=p }
              if (best>0) printf "%d %s\n", best, key[i] }
      }' | sort -n | awk '{print $2}' | awk '!s[$0]++\'
  }

  {
    echo "# Migration report — work items"
    echo
    echo "Chế độ: $([[ $apply -eq 1 ]] && echo '**APPLY**' || echo '**DRY-RUN** (chưa ghi file nào)') · Registry: \`$reg\` · Ngày: $today"
    echo
    echo "| Folder cũ | → ID | Folder mới | Type | Status (phase cũ) | Modules | Created | Updated | Bugs mở/tổng | Cần duyệt |"
    echo "|-----------|------|------------|------|-------------------|---------|---------|---------|--------------|-----------|"
  } > "$out"

  local d
  for d in $(wl_item_dirs); do
    local f="$WORK_DIR/$d/_context.md"
    n_total=$((n_total+1))
    if wl_has_fm "$f"; then n_skip=$((n_skip+1)); continue; fi
    local warn=""
    [[ -f "$f" ]] || warn="${warn}thiếu _context.md; "

    # ── title ──
    local title=""
    [[ -f "$f" ]] && title=$(grep -m1 '^# ' "$f" | sed 's/^# //' | tr -d '\r')
    if [[ -z "$title" ]]; then
      local anymd; anymd=$(ls "$WORK_DIR/$d"/*.md 2>/dev/null | head -1 || true)
      [[ -n "$anymd" ]] && title=$(grep -m1 '^# ' "$anymd" | sed 's/^# //' | tr -d '\r')
    fi
    # Bỏ tiền tố key/slug cũ: "NOJIRA-first-join-trophy — First-Join…" / "EDC-123: …" / "_context — …"
    title=$(printf '%s' "${title:-$d}" | sed -E 's/^[^ ]+ +— +//; s/^[A-Z][A-Z0-9]*-[0-9]+ *(:|-) *//' | tr -d '"|' | cut -c1-90)

    # ── type ──
    local ttext=""; [[ -f "$f" ]] && ttext=$(legacy_field "$f" Type)
    local type; type=$(map_type "$ttext"); [[ -z "$type" ]] && type=$(map_type "$d")
    [[ -z "$type" ]] && { type="chore"; warn="${warn}type?; "; }

    # ── modules: match registry tokens trong phần đầu _context.md + tên folder ──
    local text; text="$d"
    if [[ -f "$f" ]]; then
      text="$text $(awk '/^## *(Do NOT read|State)/{exit} {print}' "$f")"
    else
      text="$text $(cat "$WORK_DIR/$d"/*.md 2>/dev/null | head -40)"
    fi
    # Module chính = token registry xuất hiện SỚM NHẤT (tên folder + phần đầu _context.md).
    # Module phụ CHỈ lấy từ dòng "**Module:**" khai báo rõ — quét cả file sẽ gán thừa.
    local primary; primary=$(printf '%s' "$text" | tr '[:upper:]' '[:lower:]' | match_modules | head -1)
    local mline=""; [[ -f "$f" ]] && mline=$(legacy_field "$f" Module)
    local mods="$primary"
    if [[ -n "$mline" ]]; then
      local extra; extra=$(printf '%s' "$mline" | tr '[:upper:]' '[:lower:]' | match_modules | head -4 | tr '\n' ' ')
      mods=$(printf '%s %s' "$primary" "$extra" | tr ' ' '\n' | grep -v '^$' | awk '!s[$0]++' | head -4 | tr '\n' ' ' | sed 's/ $//')
    fi
    [[ -z "$mods" ]] && warn="${warn}module?; "

    # ── id ──
    local id="" slug="$d"
    if [[ "$d" != NOJIRA-* ]] && [[ "$d" =~ ^([A-Z][A-Z0-9]*(-[A-Z][A-Z0-9]*)*-[0-9]+)-(.+)$ ]]; then
      id="${BASH_REMATCH[1]}"; slug="${BASH_REMATCH[3]}"
    else
      slug=$(printf '%s' "$d" | sed -E 's/^NOJIRA-//; s/^[A-Z][A-Z0-9-]*-([a-z])/\1/' | tr '[:upper:]' '[:lower:]')
      if [[ -n "$primary" ]]; then
        id=$(next_num "$(awk -F'\t' -v k="$primary" '$1==k{print $2}' "$regtsv")")
      else
        id="?"
      fi
    fi
    local newdir="$id-$slug"; [[ "$id" == "?" ]] && newdir="?"

    # ── phase/status ──
    local oldphase=""; [[ -f "$f" ]] && oldphase=$(legacy_state "$f" phase | cut -c1-30)
    local phase; phase=$(map_phase "$oldphase")
    local status; status=$(phase_to_status "$phase")
    if [[ -z "$status" ]]; then
      # Không có phase → suy từ checkbox trong checklist.md/plan.md (đánh dấu "status~" để người duyệt)
      local cdone=0 copen=0 cf
      for cf in "$WORK_DIR/$d/checklist.md" "$WORK_DIR/$d/plan.md"; do
        [[ -f "$cf" ]] || continue
        cdone=$((cdone + $(grep -ciE '^[[:space:]]*[-*] \[x\]' "$cf" || true)))
        copen=$((copen + $(grep -cE '^[[:space:]]*[-*] \[ \]' "$cf" || true)))
      done
      if (( cdone + copen > 0 )); then
        if (( copen == 0 )); then status="done"; phase="done"
        elif (( cdone > 0 )); then status="in-progress"; phase="implement"
        else status="todo"; fi
        warn="${warn}status~checklist ${cdone}/$((cdone+copen)); "
      else
        status="todo"; warn="${warn}status?; "
      fi
    fi

    # ── dates từ git ──
    local created="" updated=""
    if [[ $is_git -eq 1 ]]; then
      created=$(git log --diff-filter=A --format=%as -- "$WORK_DIR/$d" 2>/dev/null | tail -1 || true)
      updated=$(git log -1 --format=%as -- "$WORK_DIR/$d" 2>/dev/null || true)
    fi
    local lu=""; [[ -f "$f" ]] && lu=$(legacy_state "$f" updated | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)
    [[ -n "$lu" && ( -z "$updated" || "$lu" > "$updated" ) ]] && updated="$lu"
    [[ -z "$created" ]] && created="${updated:-$today}"
    [[ -z "$updated" ]] && updated="$created"
    local closed=""; [[ "$status" == "done" ]] && closed="$updated"

    # ── bugs ──
    local bo=0 bt=0
    if [[ -f "$WORK_DIR/$d/bugs.md" ]]; then
      local bu=0
      while IFS=$'\t' read -r _ st _ _; do bt=$((bt+1)); wl_bug_is_open "$st" && bo=$((bo+1)); [[ "$st" == unknown ]] && bu=$((bu+1)); done < <(wl_bugs_tsv "$WORK_DIR/$d/bugs.md")
      (( bu > 0 )) && warn="${warn}${bu} bug không rõ status; "
    fi

    [[ -z "$warn" ]] && n_ok=$((n_ok+1)) || n_warn=$((n_warn+1))
    echo "| \`$d\` | $id | \`$newdir\` | $type | $status (${oldphase:-—}) | ${mods:-?} | $created | $updated | $bo/$bt | ${warn:-—} |" >> "$out"

    # ── apply ──
    if [[ $apply -eq 1 && "$id" != "?" ]]; then
      local jira=""; [[ "$id" =~ ^[A-Z]{2,}-[0-9]{3,}$ && ! "$id" =~ ^($(cut -f2 "$regtsv" | paste -sd'|'))- ]] && jira="$id"
      local track; track=$([[ -f "$f" ]] && legacy_state "$f" track || true); wl_in "${track:-x}" "standard fast hotfix" || track="standard"
      local fm="---
id: $id
title: \"$title\"
type: $type
status: $status
priority: P2
modules: [$(printf '%s' "$mods" | sed 's/ /, /g')]
track: $track
phase: ${phase:-discovery}
created: $created
updated: $updated
closed: \"$closed\"
assignee: \"\"
jira: \"$jira\"
fixes: []
relates_to: []
supersedes: []
prs: []
last_skill: \"$([[ -f "$f" ]] && legacy_state "$f" last_skill || true)\"
next_skill: \"$([[ -f "$f" ]] && legacy_state "$f" next_skill || true)\"
dev_selftest: $([[ -f "$f" ]] && legacy_state "$f" dev_selftest | grep -E '^(pending|pass|fail)$' || echo pending)
qc_status: $([[ -f "$f" ]] && legacy_state "$f" qc_status | grep -E '^(pending|pass|fail|na)$' || echo pending)
trace: $([[ -f "$f" ]] && legacy_state "$f" trace | grep -E '^(pending|pass|fail)$' || echo pending)
migrated: $today
---"
      local tmp; tmp=$(mktemp)
      if [[ -f "$f" ]]; then
        # - bỏ state block cũ (```yaml có phase:) để tránh 2 nguồn sự thật
        # - bỏ mục "## Classification" (đã nằm trong frontmatter)
        # - H1 "# <folder cũ> — title" → "# <ID> — title"
        awk -v old="$d" -v nid="$id" 'BEGIN{buf="";inb=0;incls=0;h1=0}
             !h1 && /^# / { h1=1; if (index($0, "# " old) == 1) $0 = "# " nid substr($0, length(old)+3) }
             /^## / { incls = ($0 ~ /^## *Classification/) }
             incls { next }
             /^```yaml/ {inb=1; buf=$0 "\n"; hasphase=0; next}
             inb { buf=buf $0 "\n"; if ($0 ~ /^[ \t]*phase:/) hasphase=1;
                   if ($0 ~ /^```/) { inb=0; if (hasphase) print "_(State đã chuyển lên frontmatter — `scripts/work.sh set`)_"; else printf "%s", buf } ; next }
             { print }' "$f" > "$tmp.body"
        { printf '%s\n' "$fm"; cat "$tmp.body"; } > "$tmp"; rm -f "$tmp.body"
      else
        { printf '%s\n' "$fm"; echo "# $id — $title"; echo; echo "> Migrated $today — bổ sung Spec anchor / Read order theo templates/_context.template.md."; echo; echo "## Read order"; for x in "$WORK_DIR/$d"/*.md; do echo "- \`$(basename "$x")\`"; done; } > "$tmp"
      fi
      cat "$tmp" > "$f"; rm -f "$tmp"
      if [[ "$newdir" != "$d" ]]; then
        if [[ $is_git -eq 1 ]] && git ls-files --error-unmatch "$WORK_DIR/$d" >/dev/null 2>&1; then git mv "$WORK_DIR/$d" "$WORK_DIR/$newdir"; else mv "$WORK_DIR/$d" "$WORK_DIR/$newdir"; fi
        # rewrite reference docs/work/<old> → docs/work/<new>
        grep -rlF "docs/work/$d" docs CLAUDE.md CHANGELOG.md 2>/dev/null | while read -r rf; do
          sed -i "s#docs/work/$d\b#docs/work/$newdir#g" "$rf"
        done || true
      fi
    fi
  done

  # ── legacy flat dirs ──
  {
    echo
    echo "**Tổng:** $n_total package · $n_skip đã có frontmatter (bỏ qua) · $n_ok map sạch · $n_warn cần duyệt"
    echo
    echo "## File legacy ngoài work package"
    echo
    echo "| File | Gợi ý |"
    echo "|------|-------|"
    local lf
    for lf in docs/plans/*.md docs/features/*.md docs/test-plans/*.md docs/notes/features/*.md docs/logs/*.md docs/bugs/*.md; do
      [[ -f "$lf" ]] || continue
      local base; base=$(basename "$lf" .md | tr '[:upper:]' '[:lower:]' | sed -E 's/-(plan|checklist|consolidated-plan|test-plan|guide)$//; s/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//; s/^nojira-//')
      local best bestn
      read -r bestn best < <(wl_item_dirs | awk -v base="$base" '
        BEGIN { n=split(base, b, "-"); for (i=1;i<=n;i++) if (length(b[i])>=4) want[b[i]]=1 }
        { c=tolower($0); m=split(c, t, "-"); delete seen; k=0
          for (i=1;i<=m;i++) if ((t[i] in want) && !(t[i] in seen)) { seen[t[i]]=1; k++ }
          if (k>bn) { bn=k; bd=$0 } }
        END { print (bn+0), bd }')
      if (( bestn >= 2 )); then echo "| \`$lf\` | gộp vào \`docs/work/$best/\` ($bestn từ khóa trùng) |"
      else echo "| \`$lf\` | tạo work item mới (\`work.sh new …\`) hoặc archive nếu đã xong |"; fi
    done
    for lf in docs/architecture/*.md; do
      [[ -f "$lf" ]] || continue
      if basename "$lf" | grep -qiE 'investigation|report|cleanup|incident|debug'; then
        echo "| \`$lf\` | nghi là output điều tra/task → chuyển vào work package tương ứng; architecture/ chỉ giữ overview sống |"
      fi
    done
  } >> "$out"

  if [[ -n "$report" ]]; then cp "$out" "$report"; echo "✓ Report: $report"; else cat "$out"; fi
  rm -f "$out" "$counters" "$regtsv"
  [[ $apply -eq 1 ]] && { echo "✓ Đã apply. Chạy: bash scripts/work.sh index && bash scripts/validate-work-items.sh"; }
  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
sub="${1:-}"; shift || true
case "$sub" in
  new) cmd_new "$@" ;;
  set) cmd_set "$@" ;;
  index) cmd_index "$@" ;;
  list) cmd_list "$@" ;;
  history) cmd_history "$@" ;;
  migrate) cmd_migrate "$@" ;;
  *) sed -n '2,13p' "$0"; exit 1 ;;
esac

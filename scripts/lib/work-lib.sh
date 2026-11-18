#!/usr/bin/env bash
# Thư viện dùng chung cho Work Item tracker (scripts/work.sh, scripts/validate-work-items.sh).
# Source file này — không chạy trực tiếp.
#
# Mô hình: mỗi docs/work/<ID>-<slug>/_context.md có YAML frontmatter PHẲNG (key: value,
# list dạng [a, b]) — là source of truth cho board/issue/lịch sử. Xem rules/_global/work-items.mdc.

WORK_DIR="${WORK_DIR:-docs/work}"
REGISTRY="${REGISTRY:-docs/modules.yaml}"

WL_TYPES="feature bug perf refactor security chore spike"
WL_STATUSES="backlog todo in-progress blocked review qc ready done cancelled"
WL_OPEN_STATUSES="in-progress blocked review qc ready"
WL_PHASES="discovery spec bdd tech plan implement review qc trace ship done"
WL_PRIORITIES="P0 P1 P2 P3"
WL_REQUIRED="id title type status priority modules created updated"
WL_ID_RE='^[A-Z][A-Z0-9]*(-[A-Z][A-Z0-9]*)*-[0-9]+$'

wl_today() { date +%F; }

wl_in() {  # wl_in <value> <space-separated list>
  local v="$1" x; for x in $2; do [[ "$x" == "$v" ]] && return 0; done; return 1
}

# ── Frontmatter ──────────────────────────────────────────────────────────────
wl_has_fm() { [[ -f "$1" ]] && [[ "$(head -1 "$1" | tr -d '\r')" == "---" ]]; }

# wl_fm <file> <key> → value (bỏ quote, bỏ comment " # ..." nếu value không quote; list → "a b")
wl_fm() {
  awk -v k="$2" '
    NR==1 { if ($0 ~ /^---\r?$/) { infm=1; next } else exit }
    infm && /^---\r?$/ { exit }
    infm {
      sub(/\r$/,"")
      if (index($0, k ":") == 1) {
        v=substr($0, length(k)+2); sub(/^[ \t]+/,"",v)
        if (v ~ /^"/) { sub(/^"/,"",v); sub(/".*$/,"",v) }
        else { sub(/[ \t]+#.*$/,"",v); sub(/[ \t]+$/,"",v) }
        if (v ~ /^\[.*\]$/) { v=substr(v,2,length(v)-2); gsub(/[ \t]*,[ \t]*/," ",v); gsub(/["\x27]/,"",v); sub(/^[ \t]+/,"",v); sub(/[ \t]+$/,"",v) }
        print v; exit
      }
    }' "$1"
}

# wl_fm_has_key <file> <key>
wl_fm_has_key() {
  awk -v k="$2" 'NR==1{ if ($0 ~ /^---\r?$/) {infm=1; next} else exit } infm && /^---\r?$/{exit} infm && index($0,k ":")==1 {f=1; exit} END{exit !f}' "$1"
}

# wl_fm_set <file> <key> <raw-value>  — thay dòng key trong frontmatter, hoặc chèn trước '---' đóng
wl_fm_set() {
  local f="$1" k="$2" v="$3" tmp; tmp=$(mktemp)
  awk -v k="$k" -v v="$v" '
    NR==1 { print; infm=1; next }
    infm && /^---\r?$/ { if (!done) print k ": " v; infm=0; print; next }
    infm && index($0, k ":")==1 { print k ": " v; done=1; next }
    { print }' "$f" > "$tmp" && cat "$tmp" > "$f"; rm -f "$tmp"
}

# wl_fm_table <key...> — đọc frontmatter của MỌI item trong 1 lần awk (nhanh hơn ~15× so với gọi wl_fm
# từng field: spawn process trên Windows rất đắt).
# → TSV: folder  has_ctx(0|1)  has_fm(0|1)  <value của từng key>   ("-" = rỗng, "!" = thiếu key)
wl_fm_table() {
  local keys="$*" d dirs files=()
  dirs=$(wl_item_dirs)
  for d in $dirs; do
    if [[ -f "$WORK_DIR/$d/_context.md" ]]; then files+=("$WORK_DIR/$d/_context.md"); else printf '%s\t0\t0\n' "$d"; fi
  done
  [[ ${#files[@]} -gt 0 ]] || return 0
  awk -v keys="$keys" '
    function clean(v) {
      sub(/^[ \t]+/,"",v)
      if (v ~ /^"/) { sub(/^"/,"",v); sub(/".*$/,"",v) } else { sub(/[ \t]+#.*$/,"",v); sub(/[ \t]+$/,"",v) }
      if (v ~ /^\[.*\]$/) { v=substr(v,2,length(v)-2); gsub(/[ \t]*,[ \t]*/," ",v); gsub(/["\x27]/,"",v); sub(/^[ \t]+/,"",v); sub(/[ \t]+$/,"",v) }
      gsub(/\t/," ",v); return v }
    function emit(   f, n, parts, out, i, k, v) {
      f=prev; sub(/\/_context\.md$/,"",f); n=split(f,parts,"/"); out=parts[n] "\t1\t" fm
      for (i=1;i<=nk;i++) { k=K[i]; if (!(k in H)) v="!"; else if (V[k]=="") v="-"; else v=V[k]; out=out "\t" v }
      print out }
    BEGIN { nk=split(keys,K," ") }
    FNR==1 { if (prev!="") emit(); prev=FILENAME; fm=0; infm=0; split("",V); split("",H)
             if ($0 ~ /^---\r?$/) { fm=1; infm=1 } ; next }
    infm && /^---\r?$/ { infm=0; next }
    infm { line=$0; sub(/\r$/,"",line); p=index(line,":")
           if (p>1) { k=substr(line,1,p-1); if (k ~ /^[a-z_]+$/ && !(k in H)) { V[k]=clean(substr(line,p+1)); H[k]=1 } } }
    END { if (prev!="") emit() }' "${files[@]}"
}

# wl_all_bugs_tsv — bug trong mọi bugs.md → TSV: folder  bug_id  status  severity  title
wl_all_bugs_tsv() {
  local d
  for d in $(wl_item_dirs); do
    [[ -f "$WORK_DIR/$d/bugs.md" ]] || continue
    wl_bugs_tsv "$WORK_DIR/$d/bugs.md" | awk -v d="$d" '{ print d "\t" $0 }'
  done
}

# ── Items ────────────────────────────────────────────────────────────────────
# In ra tên folder các work package (bỏ _template, _archive, file lẻ)
wl_item_dirs() {
  local d
  for d in "$WORK_DIR"/*/; do
    d="${d%/}"; d="${d##*/}"
    [[ "$d" == _* ]] && continue
    [[ -d "$WORK_DIR/$d" ]] && echo "$d"
  done
}

# wl_find_item <ID> → folder name (khớp frontmatter id hoặc prefix folder)
wl_find_item() {
  local id="$1" d
  for d in $(wl_item_dirs); do
    local f="$WORK_DIR/$d/_context.md"
    if wl_has_fm "$f" && [[ "$(wl_fm "$f" id)" == "$id" ]]; then echo "$d"; return 0; fi
  done
  for d in $(wl_item_dirs); do
    [[ "$d" == "$id" || "$d" == "$id"-* ]] && { echo "$d"; return 0; }
  done
  return 1
}

# ── Module registry (docs/modules.yaml) ─────────────────────────────────────
# Format:
# modules:
#   - key: socketio
#     prefix: SOCKETIO
#     title: "Socket.IO realtime"
#     paths: [k12-socketio/, k12-socketio-worker/]
#     aliases: [k12-socketio, socket-io]
#     spec_dir: docs/specs/modules/k12-socketio
#     owner: ""
# → TSV: key prefix title paths aliases spec_dir owner
wl_registry_tsv() {
  local reg="${1:-$REGISTRY}"
  [[ -f "$reg" ]] || return 0
  awk '
    function val(s){ sub(/^[^:]*:[ \t]*/,"",s); sub(/\r$/,"",s);
      if (s ~ /^"/){ sub(/^"/,"",s); sub(/".*$/,"",s) } else { sub(/[ \t]+#.*$/,"",s) }
      if (s ~ /^\[.*\]$/){ s=substr(s,2,length(s)-2); gsub(/[ \t]*,[ \t]*/," ",s) }
      gsub(/\t/," ",s); return s }
    function flush(){ if (key!="") print key "\t" prefix "\t" title "\t" paths "\t" aliases "\t" spec "\t" owner;
      key=prefix=title=paths=aliases=spec=owner="" }
    /^[ \t]*- key:/      { flush(); key=val($0); next }
    /^[ \t]+prefix:/     { prefix=val($0); next }
    /^[ \t]+title:/      { title=val($0); next }
    /^[ \t]+paths:/      { paths=val($0); next }
    /^[ \t]+aliases:/    { aliases=val($0); next }
    /^[ \t]+spec_dir:/   { spec=val($0); next }
    /^[ \t]+owner:/      { owner=val($0); next }
    END { flush() }' "$reg"
}

wl_registry_keys() { wl_registry_tsv "$@" | cut -f1; }

# wl_registry_get <key> <col: 2=prefix 3=title 4=paths 5=aliases 6=spec_dir 7=owner>
wl_registry_get() { wl_registry_tsv | awk -F'\t' -v k="$1" -v c="$2" '$1==k{print $c; exit}'; }

# ── ID allocation ────────────────────────────────────────────────────────────
# wl_next_id <PREFIX> → PREFIX-NNN (max hiện có + 1, pad 3)
wl_next_id() {
  local p="$1" max=0 n d id
  for d in $(wl_item_dirs); do
    id=""
    wl_has_fm "$WORK_DIR/$d/_context.md" && id=$(wl_fm "$WORK_DIR/$d/_context.md" id)
    for x in "$id" "$d"; do
      if [[ "$x" =~ ^${p}-([0-9]+)($|-) ]]; then
        n=$((10#${BASH_REMATCH[1]})); (( n > max )) && max=$n
      fi
    done
  done
  printf '%s-%03d\n' "$p" $((max + 1))
}

# ── Slug (bỏ dấu tiếng Việt, ascii, kebab-case, ≤ 50 ký tự) ──────────────────
wl_slug() {
  # Mỗi ký tự có dấu là 1 lệnh s/// riêng (literal multibyte) — không dùng [..] vì sed ở locale C xử lý theo byte.
  printf '%s' "$1" | sed 's/à/a/g;s/á/a/g;s/ạ/a/g;s/ả/a/g;s/ã/a/g;s/â/a/g;s/ầ/a/g;s/ấ/a/g;s/ậ/a/g;s/ẩ/a/g;s/ẫ/a/g;s/ă/a/g;s/ằ/a/g;s/ắ/a/g;s/ặ/a/g;s/ẳ/a/g;s/ẵ/a/g;s/À/a/g;s/Á/a/g;s/Ạ/a/g;s/Ả/a/g;s/Ã/a/g;s/Â/a/g;s/Ầ/a/g;s/Ấ/a/g;s/Ậ/a/g;s/Ẩ/a/g;s/Ẫ/a/g;s/Ă/a/g;s/Ằ/a/g;s/Ắ/a/g;s/Ặ/a/g;s/Ẳ/a/g;s/Ẵ/a/g;s/è/e/g;s/é/e/g;s/ẹ/e/g;s/ẻ/e/g;s/ẽ/e/g;s/ê/e/g;s/ề/e/g;s/ế/e/g;s/ệ/e/g;s/ể/e/g;s/ễ/e/g;s/È/e/g;s/É/e/g;s/Ẹ/e/g;s/Ẻ/e/g;s/Ẽ/e/g;s/Ê/e/g;s/Ề/e/g;s/Ế/e/g;s/Ệ/e/g;s/Ể/e/g;s/Ễ/e/g;s/ì/i/g;s/í/i/g;s/ị/i/g;s/ỉ/i/g;s/ĩ/i/g;s/Ì/i/g;s/Í/i/g;s/Ị/i/g;s/Ỉ/i/g;s/Ĩ/i/g;s/ò/o/g;s/ó/o/g;s/ọ/o/g;s/ỏ/o/g;s/õ/o/g;s/ô/o/g;s/ồ/o/g;s/ố/o/g;s/ộ/o/g;s/ổ/o/g;s/ỗ/o/g;s/ơ/o/g;s/ờ/o/g;s/ớ/o/g;s/ợ/o/g;s/ở/o/g;s/ỡ/o/g;s/Ò/o/g;s/Ó/o/g;s/Ọ/o/g;s/Ỏ/o/g;s/Õ/o/g;s/Ô/o/g;s/Ồ/o/g;s/Ố/o/g;s/Ộ/o/g;s/Ổ/o/g;s/Ỗ/o/g;s/Ơ/o/g;s/Ờ/o/g;s/Ớ/o/g;s/Ợ/o/g;s/Ở/o/g;s/Ỡ/o/g;s/ù/u/g;s/ú/u/g;s/ụ/u/g;s/ủ/u/g;s/ũ/u/g;s/ư/u/g;s/ừ/u/g;s/ứ/u/g;s/ự/u/g;s/ử/u/g;s/ữ/u/g;s/Ù/u/g;s/Ú/u/g;s/Ụ/u/g;s/Ủ/u/g;s/Ũ/u/g;s/Ư/u/g;s/Ừ/u/g;s/Ứ/u/g;s/Ự/u/g;s/Ử/u/g;s/Ữ/u/g;s/ỳ/y/g;s/ý/y/g;s/ỵ/y/g;s/ỷ/y/g;s/ỹ/y/g;s/Ỳ/y/g;s/Ý/y/g;s/Ỵ/y/g;s/Ỷ/y/g;s/Ỹ/y/g;s/đ/d/g;s/Đ/d/g' \
    | tr '[:upper:]' '[:lower:]' | LC_ALL=C sed 's/[^a-z0-9]\{1,\}/-/g; s/^-//; s/-$//' | cut -c1-50 | sed 's/-$//'
}

# ── Bugs trong bugs.md (tolerant: chuẩn mới + legacy) ────────────────────────
# Chuẩn mới:  ## <ITEM-ID>-B<n> — <title>   +   - **Status:** open|fixed|verified|closed|wontfix|deferred
#             - **Severity:** critical|high|medium|low
# → TSV: bug_id  status_norm  severity  title
wl_bugs_tsv() {
  local f="$1"; [[ -f "$f" ]] || return 0
  awk '
    function norm_status(s,   l){ l=tolower(s)
      if (l ~ /wontfix|won.t fix/) return "wontfix"
      if (l ~ /defer|⏸|hoãn/) return "deferred"
      if (l ~ /verified|closed|done|resolved|✅|đã fix|fixed/) return "fixed"
      if (l ~ /partial|🟡/) return "open"
      if (l ~ /open|🔴|chưa|pending|todo|in.progress|active/) return "open"
      return "unknown" }
    function norm_sev(s,   l){ l=tolower(s)
      if (l ~ /critical|blocker|🔴|p0/) return "critical"
      if (l ~ /high|p1/) return "high"
      if (l ~ /medium|required|🟡|p2/) return "medium"
      if (l ~ /low|minor|nit|p3/) return "low"
      return "" }
    function flush(){ if (id!="") { if (st=="") st="unknown"; if (sev=="") sev="-"; if (title=="") title="-"; print id "\t" st "\t" sev "\t" title }; id=""; st=""; sev=""; title="" }
    { sub(/\r$/,"") }
    /^##[#]? / {
      h=$0; sub(/^##[#]? +/,"",h)
      tok=h; sub(/[ \t].*$/,"",tok); gsub(/[\[\]:]/,"",tok)
      if (tok ~ /^[A-Z][A-Z0-9]*(-[A-Z0-9]+)*$/ && tok ~ /[0-9]/) {
        flush(); id=tok; title=h; sub(/^[^ ]+[ \t]*(—|-|:)?[ \t]*/,"",title); gsub(/\t/," ",title)
        sev=norm_sev(h); if (h ~ /\(FIXED\)|✅/ || tok ~ /^FIXED-/) st="fixed"; next
      }
      next
    }
    id!="" && st=="" && tolower($0) ~ /(status|state|trạng thái)/ { st=norm_status($0); next }
    id!="" && sev=="" && tolower($0) ~ /(severity|mức)/ { sev=norm_sev($0) }
    END { flush() }' "$f"
}

wl_bug_is_open() { [[ "$1" == "open" || "$1" == "unknown" ]]; }

# ── Ngày ─────────────────────────────────────────────────────────────────────
# wl_days_since <YYYY-MM-DD> → số ngày (rỗng nếu không tính được)
wl_days_since() {
  local d="$1" a b
  [[ "$d" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 0
  a=$(date -d "$d" +%s 2>/dev/null) || return 0
  b=$(date +%s); echo $(( (b - a) / 86400 ))
}

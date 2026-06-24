#!/usr/bin/env bash
#
# leak-gate.sh — publish safety gate for the modulr-skills bundle.
#
# Two jobs:
#   1. LEAK GATE  — scan every published skill for internal markers (personal
#                   paths, client/prospect names, infra IDs, vault paths).
#                   Any hit FAILS the gate (exit 1). Run before every publish.
#   2. DRIFT CHECK — compare each published skill against its source in the
#                   global skills dir. Because published copies are HAND-
#                   scrubbed (not mechanically derived), a changed source means
#                   "re-scrub by hand" — the script can't auto-apply the scrub.
#                   Drift is a WARNING by default, or a failure with --strict.
#
# Usage:
#   scripts/leak-gate.sh                 # leak gate (fail on leak) + drift warnings
#   scripts/leak-gate.sh --strict        # also FAIL on drift
#   scripts/leak-gate.sh --no-drift      # leak gate only, skip drift check
#   SKILLS_SRC=/path scripts/leak-gate.sh   # override source dir for drift check
#
# Exit codes: 0 = clean, 1 = leak found (or drift in --strict).
#
# This file is the single source of truth for "what counts as a leak." When a
# new client, repo, or piece of infra appears, add it to PATTERNS below.

set -uo pipefail

# ---- locate the bundle (repo-relative, so it works from anywhere) -----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE="$REPO_ROOT/plugins/modulr-skills/skills"

# Source dir for the drift check (global skills are the source of truth).
SKILLS_SRC="${SKILLS_SRC:-$HOME/.claude/skills}"

STRICT=0
DO_DRIFT=1
RECORD=0
for arg in "$@"; do
  case "$arg" in
    --strict)   STRICT=1 ;;
    --no-drift) DO_DRIFT=0 ;;
    --record)   RECORD=1 ;;
    -h|--help)  grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$BUNDLE" ]]; then
  echo "FATAL: bundle not found at $BUNDLE" >&2
  exit 2
fi

# ---- the leak patterns ------------------------------------------------------
# Case-insensitive, matched with grep -E. Keep these specific enough not to
# false-positive on legitimate copy. Word-boundaried where a bare word would
# be too broad. Add new clients / repos / infra here as they appear.
PATTERNS=(
  # personal filesystem paths & machine
  '/Users/[a-z]'
  '/home/[a-z]'
  '~/(Downloads|Desktop|IWT|Documents)'
  '/1_repos/'
  'bradencousin'
  # internal repos / vaults
  '\balfred\b'
  'MODULR-brain'
  'modulr_brain'
  'customer.portal'
  'MODULR_customer_portal'
  # owner / person names (internal)
  '\bBraden\b'
  '\bJonathan\b'
  # client / prospect names
  'Lone Rock'
  '\blonerock\b'
  'Reading Horizons'
  'Greenhouse Fabrics'
  'Brooke Cornetet'
  'Upfit Insider'
  '\bUpfit\b'
  'Leyhan'
  'Social ?Coach'
  '\bTourNav\b'
  # infra IDs (HubSpot account / portal / owner ids seen in audit)
  '23479723'
  '43794645'
  '7454961'
  '274853791'
  '275314191'
  # private personas / orgs from internal skills
  '\bGretchen\b'
  'iwillteach\.atlassian'
  '\bMCRS\b'
)

# A couple of patterns are allowed in SPECIFIC contexts (e.g. an attributed
# credit line). Exemptions are exact full-line matches that the gate ignores.
# Keep this list tiny and justified.
EXEMPT_LINES=(
  # (none currently — published skills carry no exempted internal strings)
)

is_exempt() {
  local line="$1"
  # Empty-array-safe under `set -u` (old bash treats ${arr[@]} as unbound).
  (( ${#EXEMPT_LINES[@]} == 0 )) && return 1
  for ex in "${EXEMPT_LINES[@]}"; do
    [[ "$line" == *"$ex"* ]] && return 0
  done
  return 1
}

# ---- 1. LEAK GATE -----------------------------------------------------------
echo "== Leak gate: scanning $BUNDLE =="
LEAKS=0
# Build one alternation for a single fast pass, then re-grep per-pattern only
# on hits to give a precise report.
ALT="$(IFS='|'; echo "${PATTERNS[*]}")"

while IFS= read -r -d '' file; do
  # grep -nE: line numbers, extended regex, case-insensitive
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    lineno="${hit%%:*}"
    content="${hit#*:}"
    if is_exempt "$content"; then
      continue
    fi
    rel="${file#$REPO_ROOT/}"
    echo "  LEAK  $rel:$lineno  $(echo "$content" | sed 's/^[[:space:]]*//' | cut -c1-120)"
    LEAKS=$((LEAKS+1))
  done < <(grep -niE "$ALT" "$file" 2>/dev/null)
done < <(find "$BUNDLE" -type f \( -name '*.md' -o -name '*.json' -o -name '*.txt' \) -print0)

if [[ "$LEAKS" -gt 0 ]]; then
  echo ""
  echo "❌ LEAK GATE FAILED: $LEAKS internal marker(s) found in the published bundle."
  echo "   Genericize or remove them before publishing. (Edit PATTERNS in this"
  echo "   script if a hit is a genuine false positive.)"
  exit 1
fi
echo "✅ Leak gate passed — no internal markers in published skills."

# ---- 2. DRIFT CHECK ---------------------------------------------------------
if [[ "$DO_DRIFT" -eq 1 ]]; then
  echo ""
  echo "== Drift check: published vs source ($SKILLS_SRC) =="
  if [[ ! -d "$SKILLS_SRC" ]]; then
    echo "  (source dir not found — skipping drift check; set SKILLS_SRC to enable)"
  else
    DRIFTED=0
    for pub in "$BUNDLE"/*/; do
      name="$(basename "$pub")"
      src="$SKILLS_SRC/$name"
      pub_skill="$pub/SKILL.md"
      src_skill="$src/SKILL.md"
      if [[ ! -e "$src" ]]; then
        echo "  ?     $name — no source skill in $SKILLS_SRC (published-only; can't track drift)"
        continue
      fi
      if [[ ! -f "$src_skill" || ! -f "$pub_skill" ]]; then
        echo "  ?     $name — missing SKILL.md on one side"
        continue
      fi
      # The published copy is hand-scrubbed, so it will NEVER be byte-identical
      # to source. We can't diff for equality. Instead, detect whether the
      # SOURCE has changed since we last published, using a recorded hash.
      stamp="$pub/.source-hash"
      cur_hash="$(shasum -a 256 "$src_skill" | awk '{print $1}')"
      if [[ "$RECORD" -eq 1 ]]; then
        # Only reached after the leak gate passed (we exit before here on leak),
        # so stamping now blesses a clean, hand-verified publish.
        echo "$cur_hash" > "$stamp"
        echo "  stamp $name — recorded source hash."
        continue
      fi
      if [[ -f "$stamp" ]]; then
        old_hash="$(cat "$stamp")"
        if [[ "$cur_hash" != "$old_hash" ]]; then
          echo "  DRIFT $name — source SKILL.md changed since last publish; re-scrub by hand."
          DRIFTED=$((DRIFTED+1))
        else
          echo "  ok    $name — source unchanged since last publish."
        fi
      else
        echo "  new   $name — no source-hash recorded yet (run --record to stamp)."
      fi
    done

    if [[ "$DRIFTED" -gt 0 ]]; then
      echo ""
      echo "⚠️  $DRIFTED skill(s) drifted: the internal source changed but the"
      echo "    published copy may not reflect the scrubbed equivalent. Review,"
      echo "    re-genericize by hand, then re-run with --record to update stamps."
      if [[ "$STRICT" -eq 1 ]]; then
        echo "    (--strict) failing on drift."
        exit 1
      fi
    fi
  fi
fi

echo ""
echo "Done."
exit 0

#!/bin/bash
# Per-FAIL triage. For each verify cmd, extract:
#  - File paths (literal `app/...` or `tests/...` references)
#  - grep patterns (literal strings between quotes after `grep -r`)
# Then check if each EXISTS anywhere in the repo (broader than the bot's narrow path).
# Verdict:
#   HALLUCINATION    = no claimed file path exists AND no grep pattern matches anywhere
#   MISUNDERSTANDING = symbols/patterns exist somewhere, just not where bot looked
#   UNCLEAR          = ambiguous

cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
uuid="$1"
f=$(ls docs/adr/${uuid}*.md 2>/dev/null | head -1)
[ -z "$f" ] && echo "$uuid|FILE_NOT_FOUND" && exit 1
title=$(head -1 "$f" | sed 's/^# //' | tr '|' '/')

# Extract verify cmds
cmds=$(awk '/^Verify commands:/{flag=1;next} /^Accept when:/{flag=0} flag && /^- /{sub(/^- /,""); print}' "$f")

# Extract literal file paths from verify cmds (e.g. app/Domains/Foo/Bar.php, app/Foo, tests/Bar)
paths=$(echo "$cmds" | grep -oE '(app|tests|database|config|routes|resources)/[A-Za-z0-9_/\.\*-]*' | sort -u)

# Extract grep patterns: things between double-quotes after grep
patterns=$(echo "$cmds" | perl -ne 'while(/grep[^\"]*"([^"]+)"/g){print "$1\n"}' | sort -u)

# Test paths: does each base path (before any wildcard) exist as a directory or file?
paths_exist=0; paths_missing=0; missing_paths=""
for p in $paths; do
  base=$(echo "$p" | sed 's/\*.*//' | sed 's/\.php$//')
  # Try the path as-is and as a directory prefix
  if [ -e "$p" ] || [ -d "$base" ] || ls $p 2>/dev/null | head -1 >/dev/null 2>&1; then
    paths_exist=$((paths_exist+1))
  else
    # Glob check
    if compgen -G "$p" >/dev/null 2>&1; then
      paths_exist=$((paths_exist+1))
    else
      paths_missing=$((paths_missing+1))
      missing_paths="$missing_paths $p"
    fi
  fi
done

# Test patterns: grep entire repo (broader than verify's narrow path)
# A pattern with `\|` is grep alternation - split it, count as found if ANY alt matches
patterns_found=0; patterns_missing=0; missing_patterns=""
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  # Split on `\|` for grep alternation
  alts=$(echo "$pat" | sed 's/\\|/\n/g')
  any_match=0
  while IFS= read -r alt; do
    [ -z "$alt" ] && continue
    # Use basic grep (-F for fixed string if no regex chars, else -E)
    if grep -rq "$alt" app/ tests/ database/ config/ routes/ 2>/dev/null; then
      any_match=1
      break
    fi
  done <<< "$alts"
  if [ $any_match -eq 1 ]; then
    patterns_found=$((patterns_found+1))
  else
    patterns_missing=$((patterns_missing+1))
    missing_patterns="$missing_patterns||$pat"
  fi
done <<< "$patterns"

# Verdict
total_paths=$((paths_exist+paths_missing))
total_patterns=$((patterns_found+patterns_missing))

# If all paths missing AND all patterns missing → hallucination
# If at least one path exists AND patterns mostly missing → misunderstanding (right area, wrong details)
# If mostly fine → unclear (script issue more likely)
if [ $total_paths -eq 0 ] && [ $total_patterns -eq 0 ]; then
  verdict="UNCLEAR_NO_EXTRACTABLE_SYMBOLS"
elif [ $paths_missing -eq $total_paths ] && [ $patterns_missing -eq $total_patterns ] && [ $((total_paths+total_patterns)) -gt 0 ]; then
  verdict="HALLUCINATION"
elif [ $patterns_missing -eq $total_patterns ] && [ $paths_exist -gt 0 ] && [ $total_patterns -gt 0 ]; then
  verdict="MISUNDERSTANDING_PATTERNS_MISSING"
elif [ $patterns_found -gt 0 ] && [ $patterns_missing -eq 0 ]; then
  verdict="MISUNDERSTANDING_VERIFY_TOO_NARROW"
else
  verdict="MIXED"
fi

echo "$uuid|$title|paths:$paths_exist/$total_paths|patterns:$patterns_found/$total_patterns|$verdict|missing_paths:$missing_paths|missing_patterns:$missing_patterns"

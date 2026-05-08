#!/bin/bash
# v2 audit: fix bugs from v1
# - Skip cmds whose first binary isn't available (env-limited, not bot's fault)
# - Pass = stdout non-empty (and if pure number, >0)
# - Exit-code based for `grep -q` style cmds
cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
f="$1"
[ -z "$f" ] && exit 1
uuid=$(echo "$f" | cut -c1-36)
title=$(head -1 "docs/adr/$f" | sed 's/^# //' | tr '|' '/')

cmds=$(awk '/^Verify commands:/{flag=1;next} /^Accept when:/{flag=0} flag && /^- /{sub(/^- /,""); print}' "docs/adr/$f")

if [ -z "$cmds" ]; then
  echo "$uuid|$title|0|0|0|0|NO_VERIFY|"
  exit 0
fi

passed=0; failed=0; skipped=0; total=0; fail_cmds=""

while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  total=$((total+1))

  # Detect first binary token (skip leading parens/braces/redirects)
  first_bin=$(echo "$cmd" | sed -E 's/^[[:space:]]*[(){}!]*[[:space:]]*//' | awk '{print $1}')
  # Strip path prefix if any
  first_bin=$(basename "$first_bin")

  # If binary missing, skip
  if [ -n "$first_bin" ] && ! command -v "$first_bin" >/dev/null 2>&1; then
    # Check common known-missing tools we don't have locally
    case "$first_bin" in
      php|phpstan|phpunit|composer|artisan|node|npm|npx|yarn|pnpm|mysql|psql|redis-cli)
        skipped=$((skipped+1))
        continue ;;
    esac
  fi

  # Run cmd, capture stdout, stderr, exit code
  out=$(bash -c "$cmd" 2>/dev/null)
  rc=$?

  # Decide pass/fail:
  # 1. If cmd contains `grep -q` at end-ish, exit-code semantics: rc=0 → pass
  if echo "$cmd" | grep -qE 'grep -q[[:space:]]'; then
    if [ "$rc" -eq 0 ]; then passed=$((passed+1)); else failed=$((failed+1)); fail_cmds="$fail_cmds; $cmd"; fi
    continue
  fi

  # 2. If cmd ends in `wc -l`, parse the number, pass if >0
  if echo "$cmd" | grep -qE 'wc -l[[:space:]]*$'; then
    n=$(echo "$out" | tr -d ' \n' | grep -oE '[0-9]+' | head -1)
    if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
      passed=$((passed+1))
    else
      failed=$((failed+1)); fail_cmds="$fail_cmds; $cmd"
    fi
    continue
  fi

  # 3. Otherwise, pass if stdout has any non-whitespace content
  stripped=$(echo "$out" | tr -d ' \t\n\r')
  if [ -n "$stripped" ]; then
    passed=$((passed+1))
  else
    failed=$((failed+1)); fail_cmds="$fail_cmds; $cmd"
  fi
done <<< "$cmds"

# Result bucket — only consider passed/failed (skipped doesn't count either way)
runnable=$((passed+failed))
if [ $runnable -eq 0 ]; then result=ALL_SKIPPED
elif [ $failed -eq 0 ]; then result=PASS
elif [ $passed -eq 0 ]; then result=FAIL
else result=PARTIAL
fi

echo "$uuid|$title|$passed|$failed|$skipped|$total|$result|$fail_cmds"

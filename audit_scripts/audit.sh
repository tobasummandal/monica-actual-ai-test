#!/bin/bash
# Per-ADR audit worker. Designed to run INSIDE the laravelsail/php83-composer
# container where php/composer/phpstan/phpunit are native.
# Usage (inside container):
#   ls docs/adr | xargs -P 8 -I {} bash audit_scripts/audit.sh "{}" > audit_scripts/audit.csv
cd /var/www/html
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

  # Detect first binary
  first_bin=$(echo "$cmd" | sed -E 's/^[[:space:]]*[(){}!]*[[:space:]]*//' | awk '{print $1}')
  first_bin=$(basename "$first_bin")

  # Skip ONLY truly-missing binaries (mysql/psql/redis-cli/node/npm — not in this container)
  if ! command -v "$first_bin" >/dev/null 2>&1; then
    case "$first_bin" in
      mysql|psql|redis-cli|node|npm|npx|yarn|pnpm)
        skipped=$((skipped+1)); continue ;;
    esac
  fi

  out=$(bash -c "$cmd" 2>/dev/null)
  rc=$?

  if echo "$cmd" | grep -qE 'grep -q[[:space:]]'; then
    if [ "$rc" -eq 0 ]; then passed=$((passed+1)); else failed=$((failed+1)); fail_cmds="$fail_cmds; $cmd"; fi
    continue
  fi

  if echo "$cmd" | grep -qE 'wc -l[[:space:]]*$'; then
    n=$(echo "$out" | tr -d ' \n' | grep -oE '[0-9]+' | head -1)
    if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
      passed=$((passed+1))
    else
      failed=$((failed+1)); fail_cmds="$fail_cmds; $cmd"
    fi
    continue
  fi

  stripped=$(echo "$out" | tr -d ' \t\n\r')
  if [ -n "$stripped" ]; then
    passed=$((passed+1))
  else
    failed=$((failed+1)); fail_cmds="$fail_cmds; $cmd"
  fi
done <<< "$cmds"

runnable=$((passed+failed))
if [ $runnable -eq 0 ]; then result=ALL_SKIPPED
elif [ $failed -eq 0 ]; then result=PASS
elif [ $passed -eq 0 ]; then result=FAIL
else result=PARTIAL
fi

echo "$uuid|$title|$passed|$failed|$skipped|$total|$result|$fail_cmds"

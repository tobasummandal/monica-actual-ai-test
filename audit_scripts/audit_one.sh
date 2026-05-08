#!/bin/bash
# Audit one ADR file. Usage: audit_one.sh <adr_filename>
# Output: one CSV row to stdout: uuid|title|passed|failed|total|result|fail_cmds
cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
f="$1"
[ -z "$f" ] && exit 1
uuid=$(echo "$f" | cut -c1-36)
title=$(head -1 "docs/adr/$f" | sed 's/^# //' | tr '|' '/')

# Extract verify commands, strip env-dependent ones (artisan, composer, npm)
cmds=$(awk '/^Verify commands:/{flag=1;next} /^Accept when:/{flag=0} flag && /^- /{sub(/^- /,""); print}' "docs/adr/$f" \
       | grep -v 'artisan' | grep -v 'composer ' | grep -v 'npm ' | grep -v 'phpunit')

if [ -z "$cmds" ]; then
  echo "$uuid|$title|0|0|0|SKIP|"
  exit 0
fi

passed=0; failed=0; total=0; fail_cmds=""
while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  total=$((total+1))
  out=$(bash -c "$cmd" 2>/dev/null | tail -1)
  n=$(echo "$out" | tr -d ' ' | grep -oE '[0-9]+' | head -1)
  if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
    passed=$((passed+1))
  else
    failed=$((failed+1))
    fail_cmds="$fail_cmds; $cmd"
  fi
done <<< "$cmds"

if [ $total -eq 0 ]; then result=SKIP
elif [ $failed -eq 0 ]; then result=PASS
elif [ $passed -eq 0 ]; then result=FAIL
else result=PARTIAL
fi

echo "$uuid|$title|$passed|$failed|$total|$result|$fail_cmds"

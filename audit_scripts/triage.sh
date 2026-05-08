#!/bin/bash
# For each ADR uuid, show its verify cmds and run each one with full output
cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
while read uuid; do
  f=$(ls docs/adr/${uuid}*.md 2>/dev/null | head -1)
  [ -z "$f" ] && continue
  echo "================================================================"
  echo "UUID: $uuid"
  echo "TITLE: $(head -1 "$f" | sed 's/^# //')"
  echo "================================================================"
  cmds=$(awk '/^Verify commands:/{flag=1;next} /^Accept when:/{flag=0} flag && /^- /{sub(/^- /,""); print}' "$f" \
         | grep -v artisan | grep -v 'composer ' | grep -v 'npm ' | grep -v phpunit)
  while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    echo ""
    echo "CMD: $cmd"
    out=$(bash -c "$cmd" 2>&1)
    echo "OUT: $(echo "$out" | head -3)"
    echo "LINES: $(echo "$out" | wc -l)"
  done <<< "$cmds"
  echo ""
done < "$1"

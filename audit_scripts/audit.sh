#!/bin/bash
# Sample audit: run each ADR's own Verify commands, log result
cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
RESULTS=/tmp/audit_results.md
echo "# Sample Audit - 20 ADRs vs own verify commands" > "$RESULTS"
echo "" >> "$RESULTS"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)" >> "$RESULTS"
echo "" >> "$RESULTS"

PASS=0; FAIL=0; SKIP=0
while IFS= read -r f; do
  uuid=$(echo "$f" | cut -c1-36)
  title=$(head -1 "docs/adr/$f" | sed 's/^# //')
  echo "" >> "$RESULTS"
  echo "## $uuid" >> "$RESULTS"
  echo "**$title**" >> "$RESULTS"
  echo "" >> "$RESULTS"

  # Extract verify command lines (between "Verify commands:" and "Accept when:")
  cmds=$(awk '/^Verify commands:/{flag=1;next} /^Accept when:/{flag=0} flag && /^- /{sub(/^- /,""); print}' "docs/adr/$f")
  if [ -z "$cmds" ]; then
    echo "_no verify commands_  → SKIP" >> "$RESULTS"
    SKIP=$((SKIP+1))
    continue
  fi

  # Extract accept thresholds (numeric, like "returns > 0", ">= 2")
  accepts=$(awk '/^Accept when:/{flag=1;next} /^## /{flag=0} flag && /^- /{print}' "docs/adr/$f")

  any_pass=0; any_fail=0
  while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    # run and capture numeric output (last line, often a wc -l count)
    out=$(bash -c "$cmd" 2>/dev/null | tail -1)
    echo "- \`$cmd\`" >> "$RESULTS"
    echo "  → \`$out\`" >> "$RESULTS"
    # crude: count > 0 = pass for "returns > 0" rules
    n=$(echo "$out" | tr -d ' ' | grep -oE '[0-9]+' | head -1)
    if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
      any_pass=1
    else
      any_fail=1
    fi
  done <<< "$cmds"

  echo "" >> "$RESULTS"
  echo "Accept criteria:" >> "$RESULTS"
  echo "$accepts" >> "$RESULTS"
  echo "" >> "$RESULTS"

  if [ $any_pass -eq 1 ] && [ $any_fail -eq 0 ]; then
    echo "**Result: PASS** (all verify cmds returned >0)" >> "$RESULTS"
    PASS=$((PASS+1))
  elif [ $any_pass -eq 1 ] && [ $any_fail -eq 1 ]; then
    echo "**Result: PARTIAL**" >> "$RESULTS"
    FAIL=$((FAIL+1))
  else
    echo "**Result: FAIL** (verify cmds returned 0)" >> "$RESULTS"
    FAIL=$((FAIL+1))
  fi
done < /tmp/sample20.txt

echo "" >> "$RESULTS"
echo "---" >> "$RESULTS"
echo "## Summary: PASS=$PASS  FAIL/PARTIAL=$FAIL  SKIP=$SKIP  / 20" >> "$RESULTS"
echo "PASS=$PASS FAIL=$FAIL SKIP=$SKIP"

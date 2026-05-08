#!/bin/bash
# Stricter triage: extract specific NAMED symbols from each ADR (not generic terms),
# check if they exist anywhere in repo. A "named symbol" is:
# - A CamelCase compound noun length >= 8 chars
# - Or ends in: Exception, Service, Controller, Repository, Trait, Interface, Job, Action, Helper, Test, Resource, Dto, Manager, Factory, Provider, Listener, Middleware, Backend
# - Or is a class/interface/trait name found in `class X` or `interface X` or `trait X` patterns in the ADR

cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
uuid="$1"
f=$(ls docs/adr/${uuid}*.md 2>/dev/null | head -1)
[ -z "$f" ] && exit 1
title=$(head -1 "$f" | sed 's/^# //' | tr '|' '/')
content=$(cat "$f")

# Extract specifically-named symbols. Match CamelCase tokens (>=8 chars) with one of these suffixes:
suffixes='Exception|Service|Controller|Repository|Trait|Interface|Job|Action|Helper|Resource|Dto|Manager|Factory|Provider|Listener|Middleware|Backend|Formatter|Loggable|Test|Subscriber|Observer|Mailer|Notification|Component|ViewHelper'

named_symbols=$(echo "$content" \
  | grep -oE "[A-Z][A-Za-z0-9]*($suffixes)" \
  | sort -u)

# Also extract leading-I interface naming convention
i_interfaces=$(echo "$content" | grep -oE "\bI[A-Z][A-Za-z0-9]{4,}" | sort -u)

# Combine
all_symbols=$(printf "%s\n%s\n" "$named_symbols" "$i_interfaces" | sort -u | grep -v '^$')

# Check each
found=""; missing=""
for sym in $all_symbols; do
  if grep -rq "$sym" app/ tests/ database/ config/ routes/ resources/ 2>/dev/null; then
    found="$found $sym"
  else
    missing="$missing $sym"
  fi
done

n_found=$(echo $found | wc -w | tr -d ' ')
n_missing=$(echo $missing | wc -w | tr -d ' ')
n_total=$((n_found+n_missing))

# Verdict
if [ $n_total -eq 0 ]; then
  v="NO_SPECIFIC_SYMBOLS"
elif [ $n_missing -eq 0 ]; then
  v="ALL_SYMBOLS_EXIST"
elif [ $n_found -eq 0 ]; then
  v="ALL_SYMBOLS_MISSING_HALLUCINATION"
else
  pct=$((100*n_missing/n_total))
  if [ $pct -ge 50 ]; then
    v="MAJORITY_MISSING_LIKELY_HALLUCINATION"
  else
    v="MAJORITY_EXIST_LIKELY_MISUNDERSTANDING"
  fi
fi

echo "$uuid|$title|$n_found|$n_missing|$v|FOUND:$found|MISSING:$missing"

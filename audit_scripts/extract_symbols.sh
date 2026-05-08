#!/bin/bash
# For each FAIL ADR, extract claimed symbols (CamelCase classes/interfaces/traits, file paths)
# from the entire ADR text, then grep the codebase for each. If all symbols missing → hallucination.
cd /Users/tobasum/Downloads/g2c/monica-actual-ai-test
uuid="$1"
f=$(ls docs/adr/${uuid}*.md 2>/dev/null | head -1)
[ -z "$f" ] && echo "$uuid|FILE_NOT_FOUND" && exit 1

# Extract candidate symbols:
#   - CamelCase identifiers length >=4 (likely class/interface/trait names)
#   - File-path-looking tokens with .php
content=$(cat "$f")

# CamelCase symbols (start with uppercase, mix of upper+lower, length >=5, not in stopword list)
symbols=$(echo "$content" \
  | grep -oE '[A-Z][a-zA-Z]{4,}' \
  | sort -u \
  | grep -vE '^(MUST|MAY|SHOULD|NOT|TRUE|FALSE|This|These|Those|Status|Date|Deciders|Context|Problem|Decision|Policy|Block|Scope|Exceptions|Rationale|Consequences|Positive|Negative|Alternatives|Risks|Implementation|Notes|Continuation|Verify|Accept|Enforcement|Mitigation|Owner|Engineering|Team|Detection|Pipeline|Architecture|Architectural|Active|ADR|Pull|Request|Code|Review|Pattern|Patterns|System|Application|Operations|Operation|Service|Services|Controller|Controllers|Model|Models|Domain|Domains|Test|Tests|Class|Classes|Interface|Interfaces|Trait|Traits|Method|Methods|Module|Modules|Standard|Standardize|Adopt|Enforce|Use|Layer|Pattern|Required|Allowed|Either|Both|Within|Across|Through|Between|Including|Excluding|However|Therefore|Furthermore|Additional|Multiple|Single|Following|Previous|Reference|References|Documentation|Configuration|Implementation|Repository|Repositories|Database|Backend|Frontend|External|Internal|Public|Private|Protected|Custom|Default|Support|Supports|Allows|Requires|Provides|Returns|Contains|Includes|Maintains|Ensures|Validates|Generates|Implements|Extends|Inherits|Overrides|Throws|Handles|Manages|Performs|Executes|Processes|Uses|API|HTTP|HTTPS|URL|URI|JSON|XML|YAML|SQL|REST|RPC|UI|UX|CLI|CRUD|MVC|ORM|DTO|DAO|TDD|BDD|CI|CD|CICD|VCS|IDE|GUI|OS|FS|OK|Yes|No|And|Or|If|Then|Else|For|While|When|Where|How|What|Why|Who|Read|Write|Read|Available|Generic|Specific|Common|Simple|Complex|Basic|Advanced|Modern|Legacy|Old|New|Latest|Recent|Current|Future|Past|First|Last|Next|Previous|Final|Initial|Primary|Secondary|Main|Other|Same|Different|Similar|Related|Various|Several|Many|Few|Most|Least|Some|All|None|Each|Every|Any|Both|Either|Neither|Multiple|Single|Once|Twice|Always|Never|Sometimes|Often|Rarely|Usually|Generally|Specifically|Especially|Particularly|Mainly|Mostly|Largely|Mainly|Roughly|Approximately|Exactly|Precisely|Quickly|Slowly|Fast|Slow|Easy|Hard|Difficult|Possible|Impossible|Likely|Unlikely|Probable|Improbable|Necessary|Unnecessary|Important|Critical|Essential|Optional|Required|Mandatory|Recommended|Suggested|Preferred|Encouraged|Discouraged|Forbidden|Prohibited|Permitted|Disallowed|Approved|Rejected|Accepted|Refused|Confirmed|Denied|Validated|Invalidated|Verified|Unverified|Tested|Untested|Documented|Undocumented|Implemented|Unimplemented|Deployed|Undeployed|Monitored|Unmonitored|Tracked|Untracked|Logged|Unlogged|Recorded|Unrecorded|Saved|Unsaved|Stored|Unstored|Cached|Uncached|Indexed|Unindexed|Compiled|Uncompiled|Linked|Unlinked|Loaded|Unloaded|Started|Stopped|Started|Finished|Completed|Incomplete|Done|Pending|Active|Inactive|Enabled|Disabled|On|Off|Yes|No|True|False|Good|Bad|Right|Wrong|Correct|Incorrect|Valid|Invalid|Legal|Illegal|Safe|Unsafe|Secure|Insecure|Stable|Unstable|Reliable|Unreliable|Available|Unavailable|Online|Offline|Open|Closed|Public|Private|Free|Paid|Open|Source|Closed|Source)$' \
  | head -20)

# Also extract specific PHP file paths
paths=$(echo "$content" | grep -oE 'app/[A-Za-z0-9_/]+\.php' | sort -u | head -10)

found=""
missing=""
for sym in $symbols; do
  # grep entire repo for this symbol
  if grep -rq --include='*.php' --include='*.json' --include='*.md' "$sym" app/ 2>/dev/null; then
    found="$found $sym"
  else
    missing="$missing $sym"
  fi
done

# Count
n_found=$(echo "$found" | wc -w | tr -d ' ')
n_missing=$(echo "$missing" | wc -w | tr -d ' ')
n_total=$((n_found+n_missing))

# Verdict
if [ "$n_total" -eq 0 ]; then
  verdict="NO_SYMBOLS"
elif [ "$n_missing" -eq 0 ]; then
  verdict="ALL_FOUND_MISUNDERSTANDING"
elif [ "$n_found" -eq 0 ]; then
  verdict="ALL_MISSING_HALLUCINATION"
else
  verdict="MIXED_PARTIAL_HALLUC"
fi

title=$(head -1 "$f" | sed 's/^# //' | tr '|' '/')
echo "$uuid|$title|$n_found|$n_missing|$verdict|FOUND:$found|MISSING:$missing"

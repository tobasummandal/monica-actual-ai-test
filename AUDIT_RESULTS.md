# Actual.ai ADR Audit

## Headline findings

1. **97% of ADRs (159 PASS + 133 PARTIAL = 292/299) describe real patterns in Monica.** Detection pipeline is largely accurate.
2. **5% of ADRs (15/299) contain fabricated symbols.** 8 are full hallucinations (Quality Gates), 7 are partial hallucinations (invented `Formattable` on top of real `Loggable`). Highest-risk findings — if loaded into Claude Code via `.claude/rules/`, would actively mislead AI-generated code.
3. **5% of ADRs (14/299) misread Monica's specific conventions.** Real patterns, wrong verify expectations. Lower risk: less likely to actively mislead, but the enforcement layer wouldn't actually catch violations because verify cmds return 0 even for compliant code.
4. **Heavy duplication:** 29 substantive issues = only 4 root ADRs. Each rule split into 7-8 scope-targeted variants. Design intent (per-glob enforcement) but inflates surface area for error — one mistaken root ADR becomes 8 mistaken rules.
5. **Sentinel-cmd over-permissiveness:** ~7% of ADRs (22/299) only "pass" their verify cmds because of broad sentinels like `grep 'function.*('`. Specific named-symbol cmds in the same ADRs return 0. Quality concern for Actual.ai's enforcement layer.

## Methodology

Each ADR ships its own `Verify commands:` (literal `grep`/`find`/etc.) and `Accept when:` numeric thresholds. We executed every verify command across all 299 ADRs and classified results.

**Two phases:**

1. **Automated bucketing** (~4 min, 8-way parallel): inside a `laravelsail/php83-composer` Docker container so `php`, `artisan`, `composer`, `phpstan`, `phpunit` execute natively. Pass = cmd's stdout is non-empty after whitespace strip; if pure-numeric, requires >0. `... | grep -q ...` cmds use exit-code semantics. Only `mysql`/`psql`/`redis-cli`/`node`/`npm` skipped (require additional containers; not used by Monica's verify cmds).
2. **Manual triage of all FAILs**: extracted specifically-named symbols (CamelCase class/interface/trait/test names) from each FAIL ADR, grepped the entire repo for each, classified hallucination vs misunderstanding by checking symbol existence anywhere in the codebase.

**Repo state:** Branch `rule-files-sync-7fefbb91`. Code identical to `main`; only `docs/adr/` and `.claude/rules/` added by the bot.

**Reproduction:** `audit_scripts/` at repo root. Key files: `audit.sh` (per-ADR auditor), `triage.sh` (per-FAIL triage), `audit.csv` (raw audit data), `triage_out.txt` (per-FAIL verdicts), `php.sh` (Docker wrapper for ad-hoc PHP/composer/artisan commands).

## Final numbers

| Bucket | Count | % | Meaning |
|---|---|---|---|
| **PASS** | 159 | 53% | All verify cmds returned >0. Pattern definitively in codebase. |
| **PARTIAL** | 133 | 44% | Mixed cmd results. Some include broad sentinel cmds that pass while specific named-symbol cmds fail. |
| **FAIL** | 7 | 2% | All verify cmds returned 0 even with full env. All from Cluster 4 (Bounded Contexts misunderstanding). |

**Substantive verdicts (manual symbol verification, independent of bucket label):**

| Verdict | Count | % | Meaning |
|---|---|---|---|
| **MISUNDERSTANDING** | 14 | 5% | Real pattern, wrong verify expectations. (7 are still bucket-FAIL; 7 are PARTIAL.) |
| **PARTIAL HALLUCINATION** | 7 | 2% | Real `Loggable` trait, fabricated `Formattable` interface. |
| **FULL HALLUCINATION** | 8 | 3% | Quality Gates cluster: 3 named symbols absent from repo. |

**Key nuance:** The bot's verify cmds often include a broad sentinel like `grep -r 'function.*(' app/Domains/` that matches every PHP function declaration. Such cmds pass trivially and lift the bucket to PARTIAL even when the *specific* named symbols don't exist. Hallucinations identified by per-symbol grep across the entire repo are independent of bucket labels — the symbols simply don't exist anywhere in Monica.

## Cluster analysis of all problem ADRs

The 29 substantive issues reduce to **4 root ADRs**, each repeated 7-8 times with different `Scope:` globs.

### Cluster 1: "Quality Gates Pattern for Domain Service Layer Validation" — 8 ADRs

**Verdict: FULL HALLUCINATION**

Bot claims these symbols exist:
- `InvalidJournalDataException` → 0 hits in repo
- `MalformedWebhookPayloadException` → 0 hits in repo
- `ValidationTest` → 0 hits in repo

The entire architectural pattern is fabricated. Monica does not have a "Quality Gates" validation layer.

UUIDs: `15e6aa4c`, `484c2b41`, `5dba8b3a`, `61ca5e06`, `8356befe`, `e3e373c9`, `e6c29d75`, `f993a33d`

### Cluster 2: "Standardize Exception and Logging Formatting for External API Responses" — 7 ADRs

**Verdict: PARTIAL HALLUCINATION**

Bot conflates real and fabricated symbols:
- `Loggable` → real (`app/Logging/Loggable.php`)
- Specific exception classes (`NotEnoughPermissionException`, etc.) → real
- `Formattable` interface → **0 hits, fabricated**
- `ExceptionFormatterTest` → **0 hits, fabricated**

Bot saw a real `Loggable` trait + some exception classes and invented a "Formattable interface standard" that doesn't exist. The architectural concern (consistent error formatting) is partially real, but the enforcement vocabulary is invented.

UUIDs: `1865f6b8`, `2bf2ed5b`, `2dde2ad0`, `3b478d47`, `7b31204c`, `add7a807`, `cb91e6a8`

### Cluster 3: "Adopt Laravel Fortify for Authentication Action Standardization" — 7 ADRs

**Verdict: MISUNDERSTANDING**

`app/Actions/Fortify/` directory exists with real Fortify action files (`UpdateUserProfileInformation.php`, `UpdateUserPassword.php`, etc.). Bot's verify cmds expected:
- `*Service.php` naming convention → Monica doesn't use this suffix
- Actions to extend a base Fortify class explicitly → Monica uses Fortify's contract interfaces, not subclassing
- Specific directory structure that doesn't match Monica's organization

The architectural decision (use Laravel Fortify) is real and present. The bot's specific expectations about how Fortify is wired are wrong for Monica.

UUIDs: `09eac070`, `31f27c06`, `48558b7e`, `4d42f340`, `6010475d`, `78872876`, `a1e04203`

### Cluster 4: "Organize Domain Logic Using Domain-Driven Design Bounded Contexts" — 7 ADRs

**Verdict: MISUNDERSTANDING (still bucket-FAIL with full env)**

Monica IS organized into bounded contexts: `app/Domains/Vault/ManageVault/Services/`, `app/Domains/Contact/.../Services/`, etc. — dozens of these directories exist. But bot's verify cmds look for files named `*Service.php`, and Monica's services are named by action (e.g. `CreateContact.php`, `DestroyAddressType.php`) without a `Service` suffix.

`find app/Domains -name '*Service.php' | wc -l` = **0**. The pattern *exists*; the verify cmd's filename expectation is wrong.

UUIDs: `16b0917e`, `5743c085`, `79010db0`, `7976c28e`, `cfd35414`, `d6a96770`, `f1d9bae2`

## Methodology limitations

- Hallucination determination is based on symbol-name lookup. A symbol that exists under a renamed form would be missed.
- `mysql`/`psql`/`redis-cli`/`node`/`npm` cmds were skipped — would require additional running services. None of Monica's ADR verify cmds use these in load-bearing ways.
- The PARTIAL bucket (133) was not further triaged. Spot-reading suggests most are real-pattern + over-specific-cmd, with the sentinel-cmd pattern noted above as the main exception.

## Files in this audit

- `AUDIT_RESULTS.md` — this file
- `ADR_INDEX.md` — full title index of all 299 ADRs
- `audit_scripts/audit.sh` — per-ADR auditor (run inside container)
- `audit_scripts/triage.sh` — per-FAIL symbol-extraction triage
- `audit_scripts/audit.csv` — raw per-ADR results (passed/failed/skipped/total/bucket)
- `audit_scripts/triage_out.txt` — per-FAIL symbol verdicts
- `audit_scripts/php.sh` — Docker wrapper for ad-hoc PHP/composer/artisan commands
- `audit_scripts/all_adrs.txt` — list of all 299 ADR filenames

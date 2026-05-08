# Actual.ai ADR Audit — All 299 Findings (Final)

## Methodology

Each ADR ships its own `Verify commands:` (literal `grep`/`find` commands) and `Accept when:` numeric thresholds. We executed every verify command across all 299 ADRs and classified results.

**Two-phase audit:**

1. **Automated bucketing** (script v2): runs each verify cmd, marks PASS/PARTIAL/FAIL.
   - Skips cmds whose binary isn't installed locally (`php`, `phpstan`, `phpunit`, `composer`, `npm`, `node`, `mysql`, etc.) — counted as skipped, not failed.
   - Pass = cmd's stdout is non-empty after whitespace strip; if pure-numeric, requires >0.
   - Handles `... | grep -q ...` via exit code (silent-exit semantics).
   - Wall time: 18 seconds, 8-way parallel.
2. **Manual triage of all FAILs** — for each FAIL, extract specifically-named symbols (CamelCase compounds with class/interface/trait/etc. suffixes), grep entire repo, classify hallucination vs misunderstanding.

**Repo state:** Branch `rule-files-sync-7fefbb91`. Code identical to `main`; only `docs/adr/` and `.claude/rules/` added.

**Reproduction:** Scripts and raw data at `audit_scripts/` in repo root. Key files: `audit_v2.sh` (per-ADR auditor), `triage_v3.sh` (per-FAIL triage), `audit_v2.csv` (raw audit data), `triage_v3_out.txt` (per-FAIL verdicts).

## Final numbers

| Bucket | Count | % | Meaning |
|---|---|---|---|
| **PASS** | 159 | 53% | All verify cmds returned >0. Pattern definitively in codebase. |
| **PARTIAL** | 111 | 37% | Some cmds passed, some failed. Pattern partially in codebase or bot's verify cmd over-specific. |
| **MISUNDERSTANDING** | 14 | 5% | Pattern is real but bot's verify cmds expect wrong location/naming. |
| **PARTIAL HALLUCINATION** | 7 | 2% | Some claimed symbols real, some fabricated. |
| **FULL HALLUCINATION** | 8 | 3% | Claimed symbols don't exist anywhere in repo. |

## The 29 FAILs — cluster analysis

The 29 FAILs reduce to **4 root ADRs**, each repeated 7-8 times with different `Scope:` globs.

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

Bot saw a real `Loggable` trait + some exception classes and invented a "Formattable interface standard" that doesn't exist. The architectural pattern (consistent error formatting) is partially real, but the enforcement vocabulary is invented.

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

**Verdict: MISUNDERSTANDING**

Monica IS organized into bounded contexts: `app/Domains/Vault/ManageVault/Services/`, `app/Domains/Contact/.../Services/`, etc. — dozens of these directories exist. But bot's verify cmds look for files named `*Service.php`, and Monica's services are named by action (e.g. `CreateContact.php`, `DestroyAddressType.php`) without a `Service` suffix.

`find app/Domains -name '*Service.php' | wc -l` = **0**. So the pattern *exists*; the verify cmd's filename expectation is wrong.

UUIDs: `16b0917e`, `5743c085`, `79010db0`, `7976c28e`, `cfd35414`, `d6a96770`, `f1d9bae2`

## Headline findings for Vik

1. **84% of ADRs (159 PASS + 111 PARTIAL = 270/299) describe real patterns in Monica.** The bot detection pipeline is largely accurate.
2. **5% of ADRs (15/299) contain fabricated symbols.** 8 are full hallucinations (Quality Gates), 7 are partial hallucinations (invented Formattable on top of real Loggable). These are the highest-risk findings — if loaded into Claude Code via `.claude/rules/`, they would actively mislead AI-generated code.
3. **5% of ADRs (14/299) misread Monica's specific conventions.** Real patterns, wrong verify expectations. Lower risk: less likely to actively mislead, but the enforcement layer wouldn't actually catch violations of these "rules" because the verify cmds always return 0 even for compliant code.
4. **Heavy duplication:** 29 FAILs = only 4 root ADRs. Each rule split into 7-8 scope-targeted variants. This is design intent (per-glob enforcement) but inflates the surface area for hallucination — one mistaken root ADR becomes 8 mistaken rules.

## Methodology limitations (disclose)

- "Hallucination" determination is based on symbol-name lookup in the Monica repo. A symbol that exists under a renamed form would be missed by my grep.
- I did not run the env-dependent verify cmds (artisan, phpstan, etc.). Those cmds were skipped, not failed.
- The PARTIAL bucket (111) was not further triaged. Spot-reading suggests most are real-pattern + over-specific-cmd. A deeper audit of PARTIALs could shift them between PASS-equivalent and MISUNDERSTANDING categories.

## Files in this audit

- `AUDIT_RESULTS.md` — this file
- `AUDIT_RESULTS_FAILS.md` — list of all 70 v1 FAILs (superseded by this report)
- `audit_full.csv` — v1 raw audit data
- `ADR_INDEX.md` — full title index of all 299 ADRs
- `audit_scripts/audit_v2.csv` — v2 raw audit data (159/111/29 split)
- `audit_scripts/triage_v3_out.txt` — per-FAIL triage output
- `audit_scripts/audit_v2.sh`, `triage_v3.sh` — the actual audit scripts (reproducible, parallelized)

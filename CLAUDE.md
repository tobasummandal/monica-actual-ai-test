<!-- actual-ai:adr-governance:start -->
# Project ADRs

This project's conventions are encoded as ADRs under `.actual/rules/`. **The ADRs ARE the pattern.** Follow them verbatim instead of reading existing implementations to figure out how to do something.

> **Note:** this directive is calibrated for one-shot tasks (a single discrete feature). For multi-task interactive sessions, consult the ADRs for each task transition rather than holding to the per-session caps below.

## Workflow (follow in order)

1. **Identify topic.** Match the files you'll edit against the path-glob table below. Pick the 1-3 topics that match. Do not pre-emptively pick "related" topics; pick only what the file paths actually match.

2. **Select ADRs by filename — the filename is the index.** Run `ls .actual/rules/`. Each filename is `<topic>-<aspect-slug>-<hash>.md`; the `<aspect-slug>` (middle segment) names the ADR's specific concern — e.g., `database-schema-defined`, `zod-input-validation`, `cache-key-format`.

   **Scan ALL filenames first, then pick only the ones whose aspect-slug directly names a noun or verb in your task.** Select by filename; never read a body to decide relevance. **Hard cap: read at most 5 ADR files total.** If more than 5 look relevant, you are over-matching — keep the 5 most specific.

   **If the path-glob table below is a single `**/*` → `cross-cutting-` row** (one big bucket, no per-area topics), this filename scan is your ONLY filter. Do **not** read the bucket exhaustively — treat the filenames as a menu, match aspect-slugs to your task, read ≤5, and ignore the rest. Reading every ADR in the bucket is the exact failure this directive exists to prevent.

3. **Locate insertion points (one read per file, max 3 files).** You may read source files ONLY to (a) find where to add code (which directory, which barrel export to update) or (b) look up an exact identifier you must import. **Do not read source files as pattern examples — the ADRs already encode the pattern.** If you find yourself reading a file because "I want to see how X is done elsewhere," stop. The ADR you already read tells you how.

4. **Implement.** Write the code following the rule statements verbatim. If two ADRs seem to conflict, follow the more specific one (longer topic prefix wins).

5. **Verify after implementing.** Only after the code is written, re-read the `verify_commands` or `accept_criteria` sections of the ADRs you applied and check your work against them. Run the verify commands if any.

## Anti-patterns to avoid

- Reading the first N rules alphabetically because they're cheap. Filter by aspect-slug first, then read only the relevant ones.
- Reading >5 ADR files for a single feature. If you're tempted, you're over-scoping the topic match.
- Reading the entire `cross-cutting-` bucket because "every rule is always active." Selection is by filename (step 2); you apply the ≤5 you selected, not all of them.
- Reading existing similar features to "see the pattern" — the ADRs encode the pattern. Trust them.
- Re-reading the same ADR multiple times. Cache it mentally.
- Continuing to browse the codebase after step 3. By step 4 you should be writing, not reading.

Each rule file at `.actual/rules/<topic>-<aspect>-<hash>.md` contains the full ADR with rule statements, verify commands, and accept criteria.

## Verification Protocol

These rules are ALWAYS ACTIVE. Apply every rule **from the ADRs you selected in step 2** that governs the files you touch — to all code generation, modification, and review. "Always active" does **not** mean read every ADR: you apply the handful you selected by filename, within the read cap above.

Every rule follows a **Verify → Fix → Repeat** loop. After generating or modifying code for any rule you MUST:

1. **RUN** the rule's `### Verify` command(s).
2. **CAPTURE** the full output (stdout + stderr).
3. **EVALUATE** the output against the rule's **Accept when** criteria.
4. **IF FAILING:** diagnose the root cause, apply a fix, and re-run from step 1.
5. **IF PASSING:** keep the passing output as evidence before moving on.
6. **MAX ITERATIONS:** 5 attempts per rule. If still failing after 5 attempts, STOP and report the failure with all captured output.

Compliance is not optional. Do not skip verification, assume correctness, or defer it to a later task. Every change to a governed area must be accompanied by a passing verification run.

## Path glob → topic

| You're editing | Topic prefix |
|---|---|
| `**/*` | `cross-cutting-` _(70 ADRs)_ |
<!-- actual-ai:adr-governance:end -->

---

## Architecture Decision Records

<adr_governance source="docs/adr/">
ADRs govern validated architectural standards for this project.
Full ADR documents: @docs/adr/
</adr_governance>

<activation>
These directives are ALWAYS ACTIVE. Claude Code MUST apply all rules in this
document to every code generation, modification, and review action within this
project. No exceptions unless explicitly noted per-rule.
</activation>

---

### Verification Protocol

<verification_protocol>
All rules in this document follow the **Verify → Fix → Repeat** loop.
</verification_protocol>

After generating or modifying code for any rule, Claude Code MUST:

1. **RUN** the targeted verification command(s) in the rule's **Verify** block.
2. **CAPTURE** the full command output (stdout + stderr).
3. **EVALUATE** whether the **Accept when** criteria are satisfied.
4. **IF FAILING:** diagnose the root cause, apply a fix, and re-run from step 1.
5. **IF PASSING:** include the passing output as inline evidence before proposing further changes.
6. **MAX ITERATIONS:** 5 attempts per rule. If still failing after 5 attempts, STOP and report the failure with all captured outputs.

<enforcement>
Compliance is not optional. Claude Code must not skip verification steps, assume
correctness, or defer verification to a later task. Evidence of a passing
verification run must accompany every code change that touches a governed area.
</enforcement>

<rule_activation id="fedd36ec-71d8-4caf-a5ba-8494d965142d" title="Adopt Eloquent ORM Models as Standard Data Access Layer: Business Logic Not" applies_to="**/*.php">
These rules are ALWAYS ACTIVE for all PHP files. Models must use Eloquent ORM as the standard data access layer, with business logic separated from data persistence concerns.
</rule_activation>

### Rules

- **R-ELQ-001** MUST_NOT: Business logic MUST NOT be tightly coupled to model classes; models should focus on data representation and persistence.
- **R-ELQ-002** MUST: All model files in app/Models MUST extend Illuminate\Database\Eloquent\Model.
- **R-ELQ-003** MUST: Models MUST define either $fillable or $guarded properties for mass assignment protection.
- **R-ELQ-004** MUST: Direct database queries outside models (using DB::table or DB::select) MUST be documented with exception justifications referencing EXC-001 or EXC-002.
- **R-ELQ-005** MUST: All database-backed domain entities requiring CRUD operations MUST use Eloquent models (in scope: entities with relationships, validation/casting requirements, query builder functionality).
- **R-ELQ-006** MUST_NOT: Value objects without database persistence, DTOs for API communication, and temporary in-memory data structures MUST NOT be implemented as Eloquent models.
- **R-ELQ-007** SHOULD: Define relationships using type-hinted return types (e.g., public function posts(): HasMany) for better IDE support and static analysis.
- **R-ELQ-008** SHOULD: Use php artisan make:model command to generate new models with consistent structure and optional migration/factory scaffolding.
- **R-ELQ-009** SHOULD: Refactor models exceeding 300 lines by establishing service layer patterns for complex business logic.
- **R-ELQ-010** SHOULD: Use model observers for cross-cutting concerns (logging, caching, event dispatching) rather than cluttering model methods.
- **R-ELQ-011** SHOULD: Leverage model factories for testing to ensure consistent test data generation.
- **R-ELQ-012** SHOULD: Document complex query scopes and custom accessors with PHPDoc blocks explaining purpose and usage.

### Verify

```bash
# Verify all models extend Eloquent Model
grep -r "extends Model" app/Models/ | wc -l

# Find models without proper namespace
find app/Models -name '*.php' -exec grep -L 'namespace App\\Models' {} \;

# Count total model classes
php artisan model:show --all 2>&1 | grep -c 'class'

# Find direct database queries that should be documented exceptions
grep -r "DB::table\|DB::select" app/Http app/Services | grep -v "// Exception" | wc -l
```

**Accept when:**
- All model files in app/Models extend Illuminate\Database\Eloquent\Model
- At least 7 model classes exist matching the detected pattern (File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, QuickFact)
- Models define either $fillable or $guarded properties for mass assignment protection
- Direct database queries outside models are documented with exception justifications (EXC-001 or EXC-002)

**Exceptions:**
- **EXC-001**: Legacy database schemas requiring raw SQL queries that cannot be efficiently expressed through Eloquent
- **EXC-002**: Read-only reporting queries spanning multiple complex joins that benefit from query builder or raw SQL

**Exception Process:**
1. Developer documents exception rationale in code comments with EXC-ID reference
2. Technical lead reviews and approves exception via pull request comment
3. Exception is logged in architecture decision log with justification
4. Exceptions are reviewed quarterly to determine if they should become permanent patterns or be refactored

<enforcement>
Claude Code MUST verify model structure, mass assignment protection, and proper use of Eloquent ORM. Claude Code MUST NOT skip or defer verification of these standards. Claude Code MUST flag direct database queries lacking exception documentation.
</enforcement>

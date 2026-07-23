# Use Laravel Schema Builder for Database Schema Management: Migrations Combine Schema

These rules are ALWAYS ACTIVE for all database migration files in the `database/migrations/` directory.

### Rules

- **R-MIGRATIONS-001** MAY: Migrations MAY combine schema changes with data migrations when structural changes require corresponding data transformations.
- **R-MIGRATIONS-002** MUST: All migration files extend `Illuminate\Database\Migrations\Migration` class.
- **R-MIGRATIONS-003** MUST: Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL statements.
- **R-MIGRATIONS-004** MUST: All migrations implement both `up()` and `down()` methods with complete, tested rollback logic.
- **R-MIGRATIONS-005** SHOULD: Use `foreignIdFor()` with `constrained()` over manual `foreign()` definitions for consistency with Eloquent models.
- **R-MIGRATIONS-006** SHOULD: Wrap schema and data operations in `DB::transaction()` when atomicity is required.
- **R-MIGRATIONS-007** SHOULD: Use Blueprint column modifiers (`nullable()`, `after()`, `default()`) to specify column attributes declaratively.
- **R-MIGRATIONS-008** MUST: Document any raw SQL usage with comments explaining why Blueprint API was insufficient.
- **R-MIGRATIONS-009** MUST: Raw SQL usage requires database architect review and approval with portability impact assessment.
- **R-MIGRATIONS-010** SHOULD: Separate large data migrations into dedicated background jobs or multi-phase deployments with feature flags.

### Verify

```bash
# Count Schema facade usage in migrations
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Verify all migrations extend Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Check migration execution status
php artisan migrate:status | grep -c "Ran"

# Verify no raw SQL DDL outside approved patterns
grep -r "CREATE TABLE\|ALTER TABLE\|DROP TABLE" database/migrations/ --include="*.php" | grep -v "Schema::" | wc -l

# Check for missing down() methods
grep -L "function down" database/migrations/*.php | wc -l
```

**Accept when:**
- All migration files extend `Illuminate\Database\Migrations\Migration` class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- All migrations implement complete `down()` methods with tested rollback logic
- Raw SQL usage (if any) is documented with comments and approved by database architect
- No raw SQL DDL statements appear outside of approved exception patterns

<enforcement>
Claude Code MUST NOT skip or defer verification. All migration files MUST be inspected for compliance with R-MIGRATIONS-001 through R-MIGRATIONS-010 before approving changes to the database schema.
</enforcement>
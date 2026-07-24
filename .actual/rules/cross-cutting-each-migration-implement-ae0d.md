# Use Laravel Schema Builder for Database Schema Management: Each Migration Implement

These rules are ALWAYS ACTIVE for all database migration files in the `database/migrations/` directory.

### Rules

- **R-MIGRATION-001** MUST: Each migration MUST implement both up() and down() methods to support forward and backward schema evolution.
- **R-MIGRATION-002** MUST: All migration files MUST extend `Illuminate\Database\Migrations\Migration` class.
- **R-MIGRATION-003** MUST: Schema modifications MUST use Schema facade with Blueprint closures rather than raw SQL DDL statements.
- **R-MIGRATION-004** SHOULD: Use `foreignIdFor()` with `constrained()` over manual `foreign()` definitions for consistency with Eloquent models.
- **R-MIGRATION-005** SHOULD: When combining schema and data operations, wrap operations in `DB::transaction()` if atomicity is required.
- **R-MIGRATION-006** SHOULD: Document any raw SQL usage with comments explaining why Blueprint API was insufficient.
- **R-MIGRATION-007** MAY: Use raw SQL for complex database-specific features that cannot be expressed through Blueprint API, with documented justification and database compatibility notes.

### Verify

```bash
# Count Schema facade usage in migrations
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Count migration files extending Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Verify migration status
php artisan migrate:status | grep -c "Ran"

# Check for raw SQL DDL outside approved patterns
grep -r "CREATE TABLE\|ALTER TABLE\|DROP TABLE" database/migrations/ --include="*.php" | grep -v "Schema::" | wc -l

# Verify all migrations have down() methods
grep -L "function down" database/migrations/*.php | wc -l
```

**Accept when:**
- All migration files extend `Illuminate\Database\Migrations\Migration` class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- All migration files implement both up() and down() methods
- Raw SQL DDL statements (if any) are documented with justification comments
- Foreign key definitions prefer `foreignIdFor()` with `constrained()` pattern

<enforcement>
Claude Code MUST NOT skip or defer verification of migration file structure, Blueprint API usage, and presence of both up() and down() methods before approving database migration changes.
</enforcement>
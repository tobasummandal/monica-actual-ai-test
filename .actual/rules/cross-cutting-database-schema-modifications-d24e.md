# Use Laravel Schema Builder for Database Schema Management: Database Schema Modifications

These rules are ALWAYS ACTIVE for all database migration files and schema modification code within the Laravel application.

### Rules

- **R-SCHEMA-001** MUST: All database schema modifications MUST be implemented using Laravel's Schema facade and Blueprint API within migration classes extending Illuminate\Database\Migrations\Migration.
- **R-SCHEMA-002** MUST: All migration files MUST extend the Illuminate\Database\Migrations\Migration class.
- **R-SCHEMA-003** MUST: Schema modifications MUST use Schema facade with Blueprint closures rather than raw SQL DDL statements, except where documented exceptions apply.
- **R-SCHEMA-004** MUST: All migrations MUST implement both up() and down() methods with complete, tested rollback logic.
- **R-SCHEMA-005** SHOULD: Use Blueprint column modifiers (nullable(), after(), default()) to specify column attributes declaratively.
- **R-SCHEMA-006** SHOULD: For foreign keys, prefer foreignIdFor() with constrained() over manual foreign() definitions for consistency with Eloquent models.
- **R-SCHEMA-007** SHOULD: When combining schema and data operations, wrap operations in DB::transaction() if atomicity is required.
- **R-SCHEMA-008** SHOULD: Document any raw SQL usage with comments explaining why Blueprint API was insufficient.
- **R-SCHEMA-009** MAY: Complex database-specific features that cannot be expressed through Blueprint API may use raw SQL with documented justification and database architect approval (EXC-001).

### Verify

```bash
# Count Schema facade usage in migrations
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Verify all migration files extend Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Check migration execution status
php artisan migrate:status | grep -c "Ran"

# Scan for raw SQL DDL outside approved patterns
grep -r "CREATE TABLE\|ALTER TABLE\|DROP TABLE" database/migrations/ --include="*.php" | grep -v "Schema::" | wc -l
```

**Accept when:**
- All migration files extend Illuminate\Database\Migrations\Migration class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- Both up() and down() methods are present and tested in all migration files
- Any raw SQL usage is documented with rationale and database compatibility notes

<enforcement>
Claude Code MUST NOT skip or defer verification. All schema modification code MUST be reviewed against these rules before acceptance. Pull requests containing raw SQL DDL without documented justification MUST be rejected.
</enforcement>
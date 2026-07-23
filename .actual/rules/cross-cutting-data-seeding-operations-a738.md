# Use Laravel Schema Builder for Database Schema Management: Data Seeding Operations

These rules are ALWAYS ACTIVE for all database migration files and schema management operations within the Laravel application.

### Rules

- **R-SEED-001** SHOULD: Data seeding operations within migrations SHOULD use DB facade for bulk inserts when populating reference tables.
- **R-SEED-002** MUST: All migration files MUST extend `Illuminate\Database\Migrations\Migration` class.
- **R-SEED-003** MUST: Schema modifications MUST use Schema facade with Blueprint closures rather than raw SQL DDL statements.
- **R-SEED-004** MUST: All migrations MUST implement both `up()` and `down()` methods with complete rollback logic.
- **R-SEED-005** SHOULD: When combining schema and data operations, SHOULD wrap operations in `DB::transaction()` if atomicity is required.
- **R-SEED-006** SHOULD: For foreign keys, SHOULD prefer `foreignIdFor()` with `constrained()` over manual `foreign()` definitions.
- **R-SEED-007** SHOULD: Migration files SHOULD use descriptive names following Laravel naming conventions via `php artisan make:migration` command.
- **R-SEED-008** SHOULD: Blueprint column modifiers (nullable(), after(), default()) SHOULD be used to specify column attributes declaratively.
- **R-SEED-009** MAY: Raw SQL usage MAY be employed only when Blueprint API is insufficient, and MUST be documented with comments explaining the necessity.

### Verify

```bash
# Count Schema facade usage in migrations
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Verify all migrations extend Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Check migration execution status
php artisan migrate:status | grep -c "Ran"

# Scan for raw SQL DDL statements outside approved patterns
grep -r "CREATE TABLE\|ALTER TABLE\|DROP TABLE" database/migrations/ --include="*.php" | grep -v "Schema::" | wc -l

# Verify down() methods exist in all migrations
grep -L "function down" database/migrations/*.php | wc -l
```

**Accept when:**
- All migration files extend `Illuminate\Database\Migrations\Migration` class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- All migration files contain both `up()` and `down()` methods with complete implementations
- Raw SQL DDL statements (if any) are documented with rationale comments and database compatibility notes
- Data seeding operations use DB facade for bulk inserts into reference tables
- Foreign key definitions use `foreignIdFor()` with `constrained()` pattern where applicable

<enforcement>
Claude Code MUST NOT skip or defer verification of migration file structure, Blueprint API usage, and rollback completeness. All rules MUST be checked during code review and CI pipeline execution.
</enforcement>
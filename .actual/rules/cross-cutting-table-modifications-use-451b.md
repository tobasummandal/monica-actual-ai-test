# Use Laravel Schema Builder for Database Schema Management: Table Modifications Use

These rules are ALWAYS ACTIVE for all database migration files in the `database/migrations/` directory.

### Rules

- **R-SCHEMA-001** MUST: Table modifications MUST use `Schema::table()` with Blueprint closure specifying alterations.
- **R-SCHEMA-002** MUST: All migration files MUST extend `Illuminate\Database\Migrations\Migration` class.
- **R-SCHEMA-003** MUST: Schema modifications MUST use Schema facade with Blueprint closures rather than raw SQL DDL statements.
- **R-SCHEMA-004** MUST: Every migration MUST implement both `up()` and `down()` methods with complete reversibility.
- **R-SCHEMA-005** SHOULD: Use `foreignIdFor()` with `constrained()` for foreign key definitions over manual `foreign()` definitions.
- **R-SCHEMA-006** SHOULD: Wrap combined schema and data operations in `DB::transaction()` when atomicity is required.
- **R-SCHEMA-007** SHOULD: Use Blueprint column modifiers (`nullable()`, `after()`, `default()`) to specify column attributes declaratively.
- **R-SCHEMA-008** MAY: Raw SQL usage is permitted only for complex database-specific features that cannot be expressed through Blueprint API, and MUST be documented with comments explaining the limitation.

### Verify

```bash
# Count Schema::create and Schema::table usage
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Verify all migrations extend Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Check migration execution status
php artisan migrate:status | grep -c "Ran"

# Detect raw SQL DDL outside approved patterns
grep -r "CREATE TABLE\|ALTER TABLE\|DROP TABLE" database/migrations/ --include="*.php" | grep -v "Schema::" | wc -l

# Verify down() methods exist
grep -r "public function down" database/migrations/ | wc -l
```

**Accept when:**
- All migration files extend `Illuminate\Database\Migrations\Migration` class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- All migration files contain both `up()` and `down()` methods
- Raw SQL DDL statements (if any) are documented with comments explaining database-specific requirements
- Foreign key definitions prefer `foreignIdFor()` with `constrained()` pattern

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules in this file are mandatory for database migration files. Violations require explicit exception documentation and database architect approval.
</enforcement>
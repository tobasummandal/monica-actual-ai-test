# Use Laravel Schema Builder for Database Schema Management: Foreign Key Relationships

These rules are ALWAYS ACTIVE for all database migration files in the `database/migrations/` directory.

### Rules

- **R-SCHEMA-001** SHOULD: Foreign key relationships SHOULD use `foreignIdFor()` method with `constrained()` and `cascadeOnDelete()` for referential integrity.

### Verify

```bash
# Count Schema facade usage in migrations
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Verify all migrations extend Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Check migration execution status
php artisan migrate:status | grep -c "Ran"

# Scan for raw SQL DDL statements outside approved patterns
grep -r "CREATE TABLE\|ALTER TABLE\|DROP TABLE" database/migrations/ --include="*.php" | grep -v "Schema::" || echo "No raw DDL found"
```

**Accept when:**
- All migration files extend `Illuminate\Database\Migrations\Migration` class
- Schema modifications use `Schema` facade with `Blueprint` closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- Foreign key definitions use `foreignIdFor()` with `constrained()` pattern
- All migrations include both `up()` and `down()` methods
- No raw SQL DDL statements appear outside documented exceptions

<enforcement>
Claude Code MUST NOT skip or defer verification. All migration files MUST be inspected for compliance with the Schema Builder pattern and foreign key relationship rules before accepting changes.
</enforcement>
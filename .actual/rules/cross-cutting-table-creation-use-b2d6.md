# Use Laravel Schema Builder for Database Schema Management: Table Creation Use

These rules are ALWAYS ACTIVE for all database migration files and schema modification code within the Laravel application.

### Rules

- **R-SCHEMA-001** MUST: Table creation MUST use Schema::create() with Blueprint closure defining column structure, constraints, and indexes

### Verify

```bash
# Count Schema::create and Schema::table usage in migrations
grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l

# Verify all migration files extend Migration class
grep -r "extends.*Migration" database/migrations/ | wc -l

# Check migration execution status
php artisan migrate:status | grep -c "Ran"
```

**Accept when:**
- All migration files extend Illuminate\Database\Migrations\Migration class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment
- No raw SQL DDL statements appear outside of documented exceptions with architect approval
- All migrations include both up() and down() methods with matching reversibility

<enforcement>
Claude Code MUST NOT skip or defer verification of migration file structure and Blueprint API compliance. All schema modifications must be reviewed against R-SCHEMA-001 before acceptance.
</enforcement>
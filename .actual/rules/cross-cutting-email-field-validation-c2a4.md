# Validate User Input with Laravel Validator Before Data Access Operations: Email Field Validation

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts, Service classes extending BaseService, and any methods receiving array input parameters that precede Eloquent data access operations (save, forceFill, update, create).

### Rules

- **R-EMAIL-001** MUST: Email field validation MUST include Rule::unique() with ignore() for the current user ID to prevent duplicate email addresses while allowing profile updates.

### Verify

```bash
# Count Validator::make() calls in Action and Service classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify Validator::make() precedes all data access operations
grep -r "->save()\|->forceFill(\|->update(\|->create(" app/Actions app/Domains --include="*.php" -B 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All files containing Eloquent data access operations (save, forceFill, update, create) also contain Validator::make() calls preceding those operations
- Validation test suite passes with 100% coverage of validation rules for all Action and Service classes
- Static analysis confirms no direct path from user input array parameters to Eloquent persistence methods without intervening validation
- Email field validation in update operations uses Rule::unique()->ignore() to allow users to retain their existing email address

<enforcement>
Claude Code MUST NOT skip or defer verification. All data access operations must be preceded by validation. Email uniqueness validation must include ignore() for the current user ID in update contexts.
</enforcement>
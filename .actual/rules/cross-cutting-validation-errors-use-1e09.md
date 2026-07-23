# Validate User Input with Laravel Validator Before Data Access Operations: Validation Errors Use

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts, Service classes extending BaseService, and any methods receiving array input parameters that precede Eloquent data access operations (save, forceFill, update, create).

### Rules

- **R-VAL-001** SHOULD: Validation errors SHOULD use validateWithBag() to namespace error messages (updateProfileInformation, updatePassword) for distinct error handling contexts.

### Verify

```bash
# Count Validator::make() usage in Action and Service classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify Validator::make() precedes data access operations
grep -r "->save()\|->forceFill(\|->update(\|->create(" app/Actions app/Domains --include="*.php" -B 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All files containing Eloquent data access operations (save, forceFill, update, create) also contain Validator::make() calls preceding those operations
- Validation test suite passes with 100% coverage of validation rules for all Action and Service classes
- Static analysis confirms no direct path from user input array parameters to Eloquent persistence methods without intervening validation

<enforcement>
Claude Code MUST NOT skip or defer verification. All three verification conditions must pass before accepting changes to validation-related code paths.
</enforcement>
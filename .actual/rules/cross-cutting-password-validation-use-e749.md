# Validate User Input with Laravel Validator Before Data Access Operations: Password Validation Use

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts, Service classes extending BaseService, and any methods receiving array input parameters that precede Eloquent data access operations (save, forceFill, update, create).

### Rules

- **R-PASS-001** MUST: Password validation MUST use passwordRules() method and Hash::check() for current password verification before allowing password changes.

### Verify

```bash
# Verify Validator::make() usage in Action and Service classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify validation precedes data access operations
grep -r "->save()\|->forceFill(\|->update(\|->create(" app/Actions app/Domains --include="*.php" -B 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All files containing Eloquent data access operations (save, forceFill, update, create) also contain Validator::make() calls preceding those operations
- Validation test suite passes with 100% coverage of validation rules for all Action and Service classes
- Static analysis confirms no direct path from user input array parameters to Eloquent persistence methods without intervening validation
- Password validation specifically uses passwordRules() method and Hash::check() for current password verification

<enforcement>
Claude Code MUST NOT skip or defer verification. All data access operations must be preceded by validation. Password changes must use passwordRules() and Hash::check(). Violations must be caught during code review and static analysis before merge.
</enforcement>
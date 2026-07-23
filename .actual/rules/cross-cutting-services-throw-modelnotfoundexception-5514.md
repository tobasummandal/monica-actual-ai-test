# Validate User Input with Laravel Validator Before Data Access Operations: Services Throw Modelnotfoundexception

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts, all Service classes extending BaseService that accept user input arrays, and all methods receiving array `$input` or `$data` parameters that precede Eloquent data access operations (save, forceFill, update, create) in user-facing endpoints handling profile updates, password changes, and account management operations.

### Rules

- **R-VALIDATE-001** MUST: Call `Validator::make()` immediately upon receiving array input in Action or Service `execute()` methods, before any business logic execution.
- **R-VALIDATE-002** MUST: Ensure all files containing Eloquent data access operations (save, forceFill, update, create) also contain `Validator::make()` calls preceding those operations.
- **R-VALIDATE-003** MUST: For Service classes, call parent `validateRules()` first for structural validation, then implement custom `validate()` method for authorization and business rule validation.
- **R-VALIDATE-004** SHOULD: Apply `validateWithBag()` with descriptive names (updateProfileInformation, updatePassword) to namespace validation errors for distinct UI contexts.
- **R-VALIDATE-005** SHOULD: Use `Rule::unique()->ignore()` for email validation in update operations to allow users to keep their existing email address.
- **R-VALIDATE-006** SHOULD: Implement password validation using PasswordValidationRules trait and `Hash::check()` for current password verification in password change operations.
- **R-VALIDATE-007** MAY: Services MAY throw `ModelNotFoundException` when cross-account validation fails to distinguish authorization failures from missing resources.

### Verify

```bash
# Count Validator::make() usage in Actions and Domains
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify Validator::make() precedes data access operations
grep -r "->save()\|->forceFill(\|->update(\|->create(" app/Actions app/Domains --include="*.php" -B 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All files containing Eloquent data access operations (save, forceFill, update, create) also contain `Validator::make()` calls preceding those operations
- Validation test suite passes with 100% coverage of validation rules for all Action and Service classes
- Static analysis confirms no direct path from user input array parameters to Eloquent persistence methods without intervening validation

<enforcement>
Claude Code MUST NOT skip or defer verification. All data access operations must be preceded by validation. Violations detected in code review or static analysis must block merge until remediated or formally excepted.
</enforcement>
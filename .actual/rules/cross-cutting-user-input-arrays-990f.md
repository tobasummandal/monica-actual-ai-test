# Validate User Input with Laravel Validator Before Data Access Operations: User Input Arrays

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts, Service classes extending BaseService, and any methods receiving array `$input` or `$data` parameters that precede Eloquent data access operations.

### Rules

- **R-INPUT-001** MUST: All user input arrays MUST be validated using `Illuminate\Support\Facades\Validator::make()` before any Eloquent data access operation (save, forceFill, update, create).
- **R-INPUT-002** MUST: Validator::make() calls MUST occur immediately upon receiving array input in Action or Service execute() methods, before any business logic execution.
- **R-INPUT-003** MUST: Service classes extending BaseService MUST call parent validateRules() first for structural validation, then implement custom validate() method for authorization and business rule validation.
- **R-INPUT-004** MUST: validateWithBag() MUST be applied with descriptive names (e.g., updateProfileInformation, updatePassword) to namespace validation errors for distinct UI contexts.
- **R-INPUT-005** MUST: Email validation in update operations MUST use Rule::unique()->ignore() to allow users to keep their existing email address.
- **R-INPUT-006** MUST: Password validation MUST use PasswordValidationRules trait and Hash::check() for current password verification in password change operations.
- **R-INPUT-007** MUST: ModelNotFoundException MUST be thrown in custom validate() methods when cross-account authorization fails to distinguish from missing resources.

### Verify

```bash
# Count Validator::make() usage in Action and Service classes
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
- Code review checklist confirms validation verification before approving PRs with data access changes

<enforcement>
Claude Code MUST NOT skip or defer verification. All user input arrays must be validated before data access operations. Violations detected by static analysis or code review MUST block merge until validation is added or a documented exception is approved by the security team.
</enforcement>
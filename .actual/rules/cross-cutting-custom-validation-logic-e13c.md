# Validate User Input with Laravel Validator Before Data Access Operations: Custom Validation Logic

These rules are ALWAYS ACTIVE for all Laravel Action classes, Service classes extending BaseService, and any methods receiving array input parameters that precede Eloquent data access operations (save, forceFill, update, create) in the App namespace.

### Rules

- **R-VAL-001** MUST: Use Validator::make() immediately upon receiving array input in Action or Service execute() methods, before any business logic execution.
- **R-VAL-002** MUST: Validate all user input arrays before calling Eloquent persistence methods (save(), forceFill(), update(), create()).
- **R-VAL-003** SHOULD: Use after() callbacks for complex validation scenarios requiring access to existing model state.
- **R-VAL-004** MUST: Apply validateWithBag() with descriptive names to namespace validation errors for distinct UI contexts.
- **R-VAL-005** MUST: Use Rule::unique()->ignore() for email validation in update operations to allow users to keep their existing email address.
- **R-VAL-006** MUST: Implement password validation using PasswordValidationRules trait and Hash::check() for current password verification in password change operations.
- **R-VAL-007** MUST: Throw ModelNotFoundException in custom validate() methods when cross-account authorization fails to distinguish from missing resources.
- **R-VAL-008** MUST: For Service classes, call parent validateRules() first for structural validation, then implement custom validate() method for authorization and business rule validation.

### Verify

```bash
# Count Validator::make() usage in Actions and Domains
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
- All Laravel Fortify Action classes implementing UpdatesUserProfileInformation, UpdatesUserPasswords, ResetsUserPasswords contracts include validation before model updates
- All Service classes extending BaseService that accept user input arrays include validation before database operations

<enforcement>
Claude Code MUST NOT skip or defer verification. All data access operations must be preceded by validation. Violations detected in code review or static analysis must block merge until remediated or documented as approved exceptions.
</enforcement>
# Validate User Input with Laravel Validator Before Data Access Operations: Service Classes Extending

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts and all Service classes extending BaseService that accept user input arrays and perform database operations.

### Rules

- **R-VALIDATE-001** MUST: Service classes extending BaseService MUST call validateRules() and implement custom validate() methods to verify account ownership and authorization before data access operations (save, forceFill, update, create).
- **R-VALIDATE-002** MUST: All Laravel Fortify Action classes implementing UpdatesUserProfileInformation, UpdatesUserPasswords, or ResetsUserPasswords contracts MUST call Validator::make() before any Eloquent persistence operations.
- **R-VALIDATE-003** MUST: Validator::make() MUST be called immediately upon receiving array input in Action or Service execute() methods, before any business logic execution.
- **R-VALIDATE-004** MUST: For Service classes, parent validateRules() MUST be called first for structural validation, then custom validate() method MUST be implemented for authorization and business rule validation.
- **R-VALIDATE-005** MUST: validateWithBag() MUST be used with descriptive names (e.g., updateProfileInformation, updatePassword) to namespace validation errors for distinct UI contexts.
- **R-VALIDATE-006** MUST: Email validation in update operations MUST use Rule::unique()->ignore() to allow users to keep their existing email address.
- **R-VALIDATE-007** MUST: Password validation MUST use PasswordValidationRules trait and Hash::check() for current password verification in password change operations.
- **R-VALIDATE-008** MUST: ModelNotFoundException MUST be thrown in custom validate() methods when cross-account authorization fails to distinguish from missing resources.
- **R-VALIDATE-009** SHOULD: Complex validation logic in after() callbacks SHOULD be extracted into dedicated validator classes to improve testability and maintainability.
- **R-VALIDATE-010** MAY: Database constraints (NOT NULL, UNIQUE, CHECK) MAY be used as a defense-in-depth measure in addition to application-layer validation, but MUST NOT replace application validation.

### Verify

```bash
# Count Validator::make() usage in Action and Service classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify Validator::make() precedes all data access operations
grep -r "->save()\|->forceFill(\|->update(\|->create(" app/Actions app/Domains --include="*.php" -B 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation

# Check for unvalidated input paths using static analysis
php artisan tinker --execute="echo 'Static analysis verification required'"
```

**Accept when:**
- All files containing Eloquent data access operations (save, forceFill, update, create) also contain Validator::make() calls preceding those operations
- Validation test suite passes with 100% coverage of validation rules for all Action and Service classes
- Static analysis confirms no direct path from user input array parameters to Eloquent persistence methods without intervening validation
- All Service classes extending BaseService implement both validateRules() and custom validate() methods for user input handling
- Email uniqueness validation uses Rule::unique()->ignore() in update operations
- Password validation uses PasswordValidationRules trait and Hash::check() for current password verification

<enforcement>
Claude Code MUST NOT skip or defer verification. All data access operations MUST be preceded by validation. Violations detected in code review or static analysis MUST block merge until remediated or approved exception is documented.
</enforcement>
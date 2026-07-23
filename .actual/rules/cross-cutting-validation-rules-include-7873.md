# Validate User Input with Laravel Validator Before Data Access Operations: Validation Rules Include

These rules are ALWAYS ACTIVE for all Laravel Action classes implementing Fortify contracts, all Service classes extending BaseService, and all methods receiving array input parameters that precede Eloquent data access operations (save, forceFill, update, create).

### Rules

- **R-VAL-001** MUST: Validation rules MUST include type constraints (string, email, boolean), length constraints (max:255), and existence constraints (required) appropriate to the data model.
- **R-VAL-002** MUST: Validator::make() MUST be called immediately upon receiving array input in Action or Service execute() methods, before any business logic execution.
- **R-VAL-003** MUST: All files containing Eloquent data access operations (save, forceFill, update, create) MUST contain Validator::make() calls preceding those operations.
- **R-VAL-004** SHOULD: For Service classes, call parent validateRules() first for structural validation, then implement custom validate() method for authorization and business rule validation.
- **R-VAL-005** SHOULD: Apply validateWithBag() with descriptive names to namespace validation errors for distinct UI contexts.
- **R-VAL-006** SHOULD: Use Rule::unique()->ignore() for email validation in update operations to allow users to keep their existing email address.
- **R-VAL-007** SHOULD: Implement password validation using PasswordValidationRules trait and Hash::check() for current password verification in password change operations.
- **R-VAL-008** MAY: Throw ModelNotFoundException in custom validate() methods when cross-account authorization fails to distinguish from missing resources.

### Verify

```bash
# Count Validator::make() usage in Action and Service classes
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

<enforcement>
Claude Code MUST NOT skip or defer verification. All three acceptance criteria must be confirmed before approving code changes that modify data access operations or user input handling.
</enforcement>
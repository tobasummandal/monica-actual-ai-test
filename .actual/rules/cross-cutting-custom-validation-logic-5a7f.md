# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Custom Validation Logic

These rules are ALWAYS ACTIVE for all classes in the `App\Actions\Fortify` namespace implementing Laravel Fortify contracts, including user registration, password update, password reset, and profile update actions.

### Rules

- **R-FORTIFY-001** MUST: Import `Illuminate\Support\Facades\Validator` at the top of all Fortify action classes.
- **R-FORTIFY-002** MUST: Place `Validator::make()` call as the first operation in public action methods before any business logic execution.
- **R-FORTIFY-003** MUST: Use array syntax for validation rules to maintain consistency (e.g., `['required', 'string', 'max:255']`).
- **R-FORTIFY-004** MUST: Never call `forceFill()` or `save()` before validation in Fortify action methods.
- **R-FORTIFY-005** SHOULD: Use the `after()` callback method for complex validation scenarios like current password verification.
- **R-FORTIFY-006** SHOULD: Use `validateWithBag()` with descriptive bag names matching the operation context (e.g., 'updatePassword', 'updateProfileInformation').
- **R-FORTIFY-007** SHOULD: For password fields, use `$this->passwordRules()` from `PasswordValidationRules` trait rather than inline rules.
- **R-FORTIFY-008** SHOULD: For email uniqueness checks in update operations, use `Rule::unique('users')->ignore($user->id)` to allow users to keep their existing email.

### Verify

```bash
# Check for Fortify action classes missing Validator facade import
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Check for Fortify action classes without Validator::make() calls
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Run test suite with coverage requirements
php artisan test --filter=Fortify --coverage --min=80

# Check for direct forceFill() or save() calls before validation
grep -r "forceFill\|->save()" app/Actions/Fortify/*.php | grep -v "Validator::make"
```

**Accept when:**
- All Fortify action classes contain `use Illuminate\Support\Facades\Validator` import statement
- Every public method in Fortify action classes that accepts user input invokes `Validator::make()` before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct `forceFill()` or `save()` calls occur before validation in Fortify action methods
- Custom validation logic using `after()` callbacks is documented with code comments explaining the validation intent

<enforcement>
Claude Code MUST NOT skip or defer verification. All Fortify action class modifications require validation of R-FORTIFY-001 through R-FORTIFY-008 compliance before approval.
</enforcement>
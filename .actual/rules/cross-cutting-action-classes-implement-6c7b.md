# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Action Classes Implement

These rules are ALWAYS ACTIVE for all classes in the `App\Actions\Fortify` namespace implementing Laravel Fortify contracts, including user registration, password update, password reset, and profile update actions.

### Rules

- **R-FORTIFY-001** MUST: Import `Illuminate\Support\Facades\Validator` at the top of all Fortify action classes.
- **R-FORTIFY-002** MUST: Place `Validator::make()` call as the first operation in public action methods before any business logic execution.
- **R-FORTIFY-003** MUST: Use array syntax for validation rules to maintain consistency (e.g., `['required', 'string', 'max:255']`).
- **R-FORTIFY-004** MUST: For password fields, use `$this->passwordRules()` from `PasswordValidationRules` trait rather than inline rules.
- **R-FORTIFY-005** MUST: Use `validateWithBag()` with descriptive bag names matching the operation context (e.g., 'updatePassword', 'updateProfileInformation').
- **R-FORTIFY-006** MUST: For email uniqueness checks in update operations, use `Rule::unique('users')->ignore($user->id)` to allow users to keep their existing email.
- **R-FORTIFY-007** MAY: Action classes MAY implement additional business logic after validation passes but before persistence.

### Verify

```bash
# Verify all Fortify action classes import Validator facade
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Verify all Fortify action classes contain Validator::make() calls
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Verify test coverage for Fortify action validation scenarios
php artisan test --filter=Fortify --coverage --min=80
```

**Accept when:**
- All Fortify action classes contain `use Illuminate\Support\Facades\Validator` import statement
- Every public method in Fortify action classes that accepts user input invokes `Validator::make()` before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct `forceFill()` or `save()` calls occur before validation in Fortify action methods
- Password validation uses `$this->passwordRules()` from the `PasswordValidationRules` trait
- Email uniqueness rules use `Rule::unique('users')->ignore($user->id)` pattern in update operations

<enforcement>
Claude Code MUST NOT skip or defer verification of these rules. All Fortify action classes MUST comply with R-FORTIFY-001 through R-FORTIFY-006 before code is considered complete.
</enforcement>
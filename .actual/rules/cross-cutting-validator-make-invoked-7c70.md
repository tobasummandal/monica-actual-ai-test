# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Validator Make Invoked

These rules are ALWAYS ACTIVE for all classes in the `App\Actions\Fortify` namespace implementing Laravel Fortify contracts, including user registration, password update, password reset, and profile update actions.

### Rules

- **R-FORTIFY-001** MUST: Validator::make() MUST be invoked before any data persistence or credential operations in Fortify action methods.
- **R-FORTIFY-002** MUST: All Fortify action classes MUST import `Illuminate\Support\Facades\Validator` at the top of the file.
- **R-FORTIFY-003** MUST: Validator::make() call MUST be the first operation in public action methods before any business logic execution.
- **R-FORTIFY-004** SHOULD: Use array syntax for validation rules to maintain consistency: `['required', 'string', 'max:255']`.
- **R-FORTIFY-005** SHOULD: For password fields, use `$this->passwordRules()` from PasswordValidationRules trait rather than inline rules.
- **R-FORTIFY-006** SHOULD: Use validateWithBag() with descriptive bag names matching the operation context (e.g., 'updatePassword', 'updateProfileInformation').
- **R-FORTIFY-007** SHOULD: For email uniqueness checks in update operations, use `Rule::unique('users')->ignore($user->id)` to allow users to keep their existing email.

### Verify

```bash
# Find Fortify action classes without Validator facade usage
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Find Fortify action classes missing Validator import
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Run Fortify-related tests with coverage threshold
php artisan test --filter=Fortify --coverage --min=80
```

**Accept when:**
- All Fortify action classes contain `use Illuminate\Support\Facades\Validator` import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis scanning for Validator facade usage in Fortify action classes is mandatory. Code review checklist requiring validation verification for authentication-related changes is mandatory. Automated test suite with validation scenario coverage requirements is mandatory. Security audit review of authentication action implementations is mandatory.
</enforcement>
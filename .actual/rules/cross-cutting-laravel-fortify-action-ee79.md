# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Laravel Fortify Action

These rules are ALWAYS ACTIVE for all Laravel Fortify action classes in the App\Actions\Fortify namespace that implement authentication contracts (CreatesNewUsers, UpdatesUserPasswords, ResetsUserPasswords, UpdatesUserProfileInformation, or custom Fortify action classes handling user input).

### Rules

- **R-FORTIFY-001** MUST: All Laravel Fortify action classes implementing authentication contracts MUST use Illuminate\Support\Facades\Validator for input validation.
- **R-FORTIFY-002** MUST: Place Validator::make() call as the first operation in public action methods before any business logic execution.
- **R-FORTIFY-003** MUST: Import Illuminate\Support\Facades\Validator at the top of all Fortify action classes.
- **R-FORTIFY-004** MUST: For password fields, always use $this->passwordRules() from PasswordValidationRules trait rather than inline rules.
- **R-FORTIFY-005** MUST: Use validateWithBag() with descriptive bag names matching the operation context (e.g., 'updatePassword', 'updateProfileInformation').
- **R-FORTIFY-006** MUST: For email uniqueness checks in update operations, use Rule::unique('users')->ignore($user->id) to allow users to keep their existing email.
- **R-FORTIFY-007** SHOULD: Use array syntax for validation rules to maintain consistency: ['required', 'string', 'max:255'].

### Verify

```bash
# Check for Fortify action classes without Validator facade import
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Check for Fortify action classes without Validator::make() calls
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Run test suite with coverage requirements
php artisan test --filter=Fortify --coverage --min=80
```

**Accept when:**
- All Fortify action classes contain 'use Illuminate\Support\Facades\Validator' import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods
- Validation rules use array syntax consistently
- Password validation uses PasswordValidationRules trait methods
- Email uniqueness checks use Rule::unique() with proper ignore() for updates

<enforcement>
Claude Code MUST NOT skip or defer verification. All Fortify action classes must be scanned for Validator facade usage and validation patterns before code is approved.
</enforcement>
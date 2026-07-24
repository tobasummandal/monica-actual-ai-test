# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Email Uniqueness Validation

These rules are ALWAYS ACTIVE for all classes in the App\Actions\Fortify namespace implementing Laravel Fortify contracts, including user registration actions, password update actions, password reset actions, profile update actions, and any custom Fortify action classes handling user input.

### Rules

- **R-FORTIFY-001** MUST: Email uniqueness validation MUST use Rule::unique() with appropriate ignore clauses for update operations.

### Verify

```bash
# Check for Fortify action classes missing Validator facade import
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Check for Fortify action classes without Validator::make() calls
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Run Fortify-specific tests with coverage requirement
php artisan test --filter=Fortify --coverage --min=80

# Verify Rule::unique() usage in email validation contexts
grep -r "email" app/Actions/Fortify/*.php | grep -c "Rule::unique"
```

**Accept when:**
- All Fortify action classes contain 'use Illuminate\Support\Facades\Validator' import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods
- Email uniqueness validation uses Rule::unique('users')->ignore($user->id) pattern for update operations

<enforcement>
Claude Code MUST NOT skip or defer verification. All Fortify action classes must be scanned for Validator facade usage and Rule::unique() patterns before accepting changes to authentication workflows.
</enforcement>
# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Password Validation Use

These rules are ALWAYS ACTIVE for all classes in the App\Actions\Fortify namespace implementing Laravel Fortify contracts, including user registration, password update, password reset, and profile update actions.

### Rules

- **R-FORTIFY-001** MUST: Password validation MUST use the PasswordValidationRules trait and Hash facade for secure password hashing.

### Verify

```bash
# Check for Fortify action classes without Validator facade import
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Check for Fortify action classes without Validator::make() calls
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Run test suite with coverage threshold
php artisan test --filter=Fortify --coverage --min=80
```

**Accept when:**
- All Fortify action classes contain 'use Illuminate\Support\Facades\Validator' import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods
- Password fields use $this->passwordRules() from PasswordValidationRules trait
- validateWithBag() is used with descriptive bag names matching operation context

<enforcement>
Claude Code MUST NOT skip or defer verification of these rules. All Fortify action classes must be scanned for Validator facade usage and validation patterns before code is approved.
</enforcement>
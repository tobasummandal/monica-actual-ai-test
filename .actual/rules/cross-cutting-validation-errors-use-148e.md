# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Validation Errors Use

These rules are ALWAYS ACTIVE for all classes in the App\Actions\Fortify namespace implementing Laravel Fortify contracts, including user registration, password update, password reset, and profile update actions.

### Rules

- **R-FORTIFY-VAL-001** SHOULD: Validation errors SHOULD use validateWithBag() to namespace error messages by operation context.

### Verify

```bash
# Check for Validator facade usage in Fortify action classes
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Check for Validator facade import statements
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Run test suite with coverage requirements
php artisan test --filter=Fortify --coverage --min=80
```

**Accept when:**
- All Fortify action classes contain 'use Illuminate\Support\Facades\Validator' import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods
- validateWithBag() is used with descriptive bag names matching operation context (e.g., 'updatePassword', 'updateProfileInformation')

<enforcement>
Clause Code MUST NOT skip or defer verification of Validator facade usage and validateWithBag() implementation in Fortify action classes. Static analysis and test coverage checks are mandatory before acceptance.
</enforcement>
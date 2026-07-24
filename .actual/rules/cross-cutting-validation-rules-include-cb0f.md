# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Validation Rules Include

These rules are ALWAYS ACTIVE for all classes in the App\Actions\Fortify namespace implementing Laravel Fortify contracts, including user registration, password update, password reset, and profile update actions.

### Rules

- **R-FORTIFY-VAL-001** MUST: Validation rules MUST include type constraints (string, email), length limits (max:255), and required field declarations for all user inputs.

### Verify

```bash
# Check for Fortify action classes without Validator facade import
grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'

# Check for missing Validator facade use statement
grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\Support\\Facades\\Validator"

# Run test suite with coverage requirements
php artisan test --filter=Fortify --coverage --min=80
```

**Accept when:**
- All Fortify action classes contain 'use Illuminate\Support\Facades\Validator' import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods

<enforcement>
Claude Code MUST NOT skip or defer verification. All Fortify action classes must be scanned for proper Validator facade usage and validation rule inclusion before code is considered compliant.
</enforcement>
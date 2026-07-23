# Adopt Illuminate Validator for Input Validation in Laravel Actions: Validation Include Custom

These rules are ALWAYS ACTIVE for all action classes in `App\Actions\Fortify`, service classes extending `BaseService` in `App\Domains`, and any class method accepting array `$input` or array `$data` parameters from user requests involved in user profile operations, authentication, and authorization flows.

### Rules

- **R-VAL-001** MUST: Call `Validator::make($input, $rules)` before any business logic or data persistence in methods accepting user input.
- **R-VAL-002** MUST: Define validation rules using array syntax with field names as keys and rule arrays as values: `['field' => ['required', 'string', 'max:255']]`.
- **R-VAL-003** MUST: Chain `->validateWithBag('bagName')` for Fortify actions or `->validate()` for service classes to enforce validation.
- **R-VAL-004** SHOULD: Use `Illuminate\Validation\Rule` class for complex rules such as `Rule::unique('table')->ignore($id)`.
- **R-VAL-005** MAY: Validation MAY include custom `after()` callbacks for complex cross-field validation logic that cannot be expressed declaratively.
- **R-VAL-006** SHOULD: Limit `after()` callback usage to cross-field validation only; extract complex logic to dedicated validator classes.
- **R-VAL-007** SHOULD: Document `after()` callback behavior in method docblocks.
- **R-VAL-008** MUST: Import `Illuminate\Support\Facades\Validator` at the top of action and service classes that accept user input.
- **R-VAL-009** SHOULD: Implement a `rules()` method in service classes extending `BaseService` to centralize validation logic and enable reuse across service boundaries.

### Verify

```bash
# Count Validator::make usage across action and domain classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify action classes with array $input parameters call Validator::make
grep -r "public function.*array \$input" app/Actions --include="*.php" -A 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All action classes in `App\Actions\Fortify` contain `Validator::make()` calls before persistence operations
- Service classes extending `BaseService` implement `rules()` method and call validation methods
- Validation tests pass for all user input scenarios including edge cases and invalid input
- No action class persists user input without prior validation

<enforcement>
Claude Code MUST NOT skip or defer verification. All three verify commands MUST execute successfully before accepting changes to validation-related code.
</enforcement>
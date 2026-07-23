# Adopt Illuminate Validator for Input Validation in Laravel Actions: Service Classes Extending

These rules are ALWAYS ACTIVE for all action classes in `App\Actions\Fortify` namespace, service classes in `App\Domains` namespace extending `BaseService`, and any class method accepting array `$input` or array `$data` parameters from user requests.

### Rules

- **R-VAL-001** SHOULD: Service classes extending BaseService SHOULD implement `rules()` method returning validation rule arrays and call `validateRules()` or `validate()` methods.
- **R-VAL-002** MUST: All action classes accepting user input MUST call `Validator::make($input, $rules)` before any business logic or persistence operations.
- **R-VAL-003** SHOULD: Validation rules SHOULD be defined using array syntax: `['field' => ['required', 'string', 'max:255']]`.
- **R-VAL-004** SHOULD: Complex rules SHOULD use `Illuminate\Validation\Rule` class (e.g., `Rule::unique('table')->ignore($id)`).
- **R-VAL-005** SHOULD: Cross-field validation SHOULD use `->after(function($validator) { ... })` callbacks after `Validator::make()`.
- **R-VAL-006** MUST: Fortify action implementations MUST chain `->validateWithBag('bagName')` to namespace validation errors.
- **R-VAL-007** MUST: Service layer validation MUST chain `->validate()` or use `validateRules()` method.
- **R-VAL-008** MUST: Validation MUST occur in the same method that performs persistence to maintain clear control flow.

### Verify

```bash
# Count Validator::make usage across action and domain classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify action classes with array $input have Validator::make calls
grep -r "public function.*array \$input" app/Actions --include="*.php" -A 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All action classes in `App\Actions\Fortify` contain `Validator::make()` calls before persistence operations
- Service classes extending `BaseService` implement `rules()` method and call validation methods
- Validation tests pass for all user input scenarios including edge cases and invalid input
- No action class accepting `array $input` parameter lacks a subsequent `Validator::make()` call

<enforcement>
Claude Code MUST NOT skip or defer verification. All user-facing action classes and service methods accepting user input MUST be validated before persistence. Code review and CI pipeline enforcement are mandatory.
</enforcement>
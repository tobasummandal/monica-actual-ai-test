# Adopt Illuminate Validator for Input Validation in Laravel Actions: Validation Rules Expressed

These rules are ALWAYS ACTIVE for all action classes in `App\Actions\Fortify`, service classes in `App\Domains` extending `BaseService`, and any class method accepting array `$input` or array `$data` parameters from user requests involved in user profile operations, authentication, and authorization flows.

### Rules

- **R-VAL-001** MUST: Validation rules MUST be expressed as array structures passed to `Validator::make()` with field names as keys and rule arrays as values.
- **R-VAL-002** MUST: Call `Validator::make($input, $rules)` before any business logic or data persistence, passing the input array and rules array.
- **R-VAL-003** MUST: For Fortify actions, chain `->validateWithBag('bagName')` to namespace errors; for services, chain `->validate()` or use `validateRules()`.
- **R-VAL-004** MUST: Define validation rules using array syntax: `['field' => ['required', 'string', 'max:255']]`.
- **R-VAL-005** SHOULD: Use `Illuminate\Validation\Rule` class for complex rules like `Rule::unique('table')->ignore($id)`.
- **R-VAL-006** SHOULD: For cross-field validation, add `->after(function($validator) { ... })` callback after `Validator::make()`.
- **R-VAL-007** MUST: Ensure validation occurs in the same method that performs persistence to maintain clear control flow.
- **R-VAL-008** MUST: Import `Illuminate\Support\Facades\Validator` at the top of action and service classes that accept user input.

### Verify

```bash
# Count Validator::make() usage across action and domain classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify action classes with array $input parameters call Validator::make()
grep -r "public function.*array \$input" app/Actions --include="*.php" -A 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All action classes in `App\Actions\Fortify` contain `Validator::make()` calls before persistence operations.
- Service classes extending `BaseService` implement `rules()` method and call validation methods.
- Validation tests pass for all user input scenarios including edge cases and invalid input.
- No action class accepting user input persists data without prior validation.

<enforcement>
Claude Code MUST NOT skip or defer verification. All user-facing actions must validate input before persistence. Pull requests without validation in user-facing actions are blocked until validation is added. Security review is triggered for any action class that persists user input without validation.
</enforcement>
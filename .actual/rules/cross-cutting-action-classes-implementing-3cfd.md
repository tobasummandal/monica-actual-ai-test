# Adopt Illuminate Validator for Input Validation in Laravel Actions: Action Classes Implementing

These rules are ALWAYS ACTIVE for all action classes in `App\Actions\Fortify` implementing Laravel Fortify contracts, service classes in `App\Domains` extending `BaseService`, and any class method accepting array `$input` or array `$data` parameters from user requests.

### Rules

- **R-VALIDATOR-001** SHOULD: Action classes implementing Fortify contracts SHOULD use `validateWithBag()` to namespace validation errors for specific forms.
- **R-VALIDATOR-002** MUST: Call `Validator::make($input, $rules)` before any business logic or data persistence, passing input array and rules array.
- **R-VALIDATOR-003** MUST: Define validation rules using array syntax: `['field' => ['required', 'string', 'max:255']]`.
- **R-VALIDATOR-004** SHOULD: For Fortify actions, chain `->validateWithBag('bagName')` to namespace errors; for services, chain `->validate()` or use `validateRules()`.
- **R-VALIDATOR-005** SHOULD: Use `Illuminate\Validation\Rule` class for complex rules like `Rule::unique('table')->ignore($id)`.
- **R-VALIDATOR-006** MAY: For cross-field validation, add `->after(function($validator) { ... })` callback after `Validator::make()`, but limit usage to cross-field validation only.
- **R-VALIDATOR-007** MUST: Ensure validation occurs in the same method that performs persistence to maintain clear control flow.
- **R-VALIDATOR-008** MUST: Import `Illuminate\Support\Facades\Validator` at the top of action and service classes that accept user input.

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
- No action class persists user input without prior validation

<enforcement>
Claude Code MUST NOT skip or defer verification. All pull requests without validation in user-facing actions MUST be blocked until validation is added. Security review MUST be triggered for any action class that persists user input without validation.
</enforcement>
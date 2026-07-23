# Adopt Illuminate Validator for Input Validation in Laravel Actions: Action Classes That

These rules are ALWAYS ACTIVE for all action classes in `App\Actions\Fortify` namespace, service classes in `App\Domains` namespace extending `BaseService`, and any class method accepting array `$input` or array `$data` parameters from user requests.

### Rules

- **R-VAL-001** MUST: All action classes that accept user input MUST validate input using `Illuminate\Support\Facades\Validator` before executing business logic or persistence operations.
- **R-VAL-002** MUST: Call `Validator::make($input, $rules)` before any business logic, passing input array and rules array.
- **R-VAL-003** MUST: For Fortify actions, chain `->validateWithBag('bagName')` to namespace errors; for services, chain `->validate()` or use `validateRules()`.
- **R-VAL-004** SHOULD: Define validation rules using array syntax: `['field' => ['required', 'string', 'max:255']]`.
- **R-VAL-005** SHOULD: Use `Illuminate\Validation\Rule` class for complex rules like `Rule::unique('table')->ignore($id)`.
- **R-VAL-006** SHOULD: For cross-field validation, add `->after(function($validator) { ... })` callback after `Validator::make()`.
- **R-VAL-007** SHOULD: Ensure validation occurs in the same method that performs persistence to maintain clear control flow.
- **R-VAL-008** MAY: Submit exception requests for input originating from trusted internal services with guaranteed data contracts (EXC-001) or performance-critical paths where validation overhead is measured as unacceptable (EXC-002).

### Verify

```bash
# Count Validator::make usage in action and domain classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify action classes with array $input have Validator::make
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
Claude Code MUST NOT skip or defer verification. All user-facing action classes MUST validate input using Illuminate Validator before any persistence or business logic execution. Code review and CI pipeline enforcement are mandatory.
</enforcement>
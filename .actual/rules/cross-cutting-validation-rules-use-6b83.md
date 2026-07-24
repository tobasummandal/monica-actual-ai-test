# Adopt Illuminate Validator for Input Validation in Laravel Actions: Validation Rules Use

These rules are ALWAYS ACTIVE for all action classes in `App\Actions\Fortify` namespace, service classes in `App\Domains` namespace extending `BaseService`, and any class method accepting array `$input` or array `$data` parameters from user requests involved in user profile operations, authentication, and authorization flows.

### Rules

- **R-VAL-001** SHOULD: Validation rules SHOULD use Laravel's built-in rule types (required, string, max, email, unique) and Rule class for complex constraints.

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
- All action classes in `App\Actions\Fortify` contain `Validator::make()` calls before persistence operations
- Service classes extending `BaseService` implement `rules()` method and call validation methods
- Validation tests pass for all user input scenarios including edge cases and invalid input
- No action class persists user input without prior validation

<enforcement>
Claude Code MUST NOT skip or defer verification. All pull requests must pass the verification commands before acceptance. Security review is triggered for any action class that persists user input without validation.
</enforcement>
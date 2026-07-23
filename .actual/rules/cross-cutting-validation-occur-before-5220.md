# Adopt Illuminate Validator for Input Validation in Laravel Actions: Validation Occur Before

These rules are ALWAYS ACTIVE for all action classes in App\Actions\Fortify namespace, service classes in App\Domains namespace extending BaseService, and any class method accepting array $input or array $data parameters from user requests involved in user profile operations, authentication, and authorization flows.

### Rules

- **R-VAL-001** MUST: Validation MUST occur before any database operations, external API calls, or state-changing business logic.

### Verify

```bash
# Count Validator::make() usage across action and domain classes
grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l

# Verify Validator::make() is called before persistence in action classes
grep -r "public function.*array \$input" app/Actions --include="*.php" -A 10 | grep -c "Validator::make"

# Run validation test suite
php artisan test --filter=Validation
```

**Accept when:**
- All action classes in App\Actions\Fortify contain Validator::make() calls before persistence operations
- Service classes extending BaseService implement rules() method and call validation methods
- Validation tests pass for all user input scenarios including edge cases and invalid input
- No action class persists user input without prior validation

<enforcement>
Claude Code MUST NOT skip or defer verification. All pull requests must pass the verification commands before merge. Security review is triggered for any action class that persists user input without validation.
</enforcement>
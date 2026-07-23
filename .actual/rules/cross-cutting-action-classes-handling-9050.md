# Use Rate Limiter Increment for Authentication Failure Metrics: Action Classes Handling

These rules are ALWAYS ACTIVE for authentication action classes in `app/Actions` and `app/Actions/Fortify` namespaces that handle credential validation, authentication failures, two-factor authentication challenges, and Socialite driver flows.

### Rules

- **R-AUTH-001** SHOULD: Action classes handling authentication SHOULD inject `LoginRateLimiter` as a protected dependency in constructor.
- **R-AUTH-002** SHOULD: Call `$this->limiter->increment($request)` immediately before throwing `ValidationException` in authentication failure paths.
- **R-AUTH-003** SHOULD: Fire the `Failed` event before incrementing the limiter to ensure event listeners execute even if increment fails.
- **R-AUTH-004** SHOULD: Use `$request->session()->put(['login.id' => $user->getKey(), 'login.remember' => ...])` for two-factor challenge state management.
- **R-AUTH-005** SHOULD: Use consistent `'login.id'` and `'login.remember'` keys for session state in two-factor authentication flows.

### Verify

```bash
# Check for limiter->increment calls in authentication action classes
grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"

# Verify session state management pattern for two-factor flows
grep -r "session()->put.*login\.id" app/Actions/ | wc -l

# Run authentication tests with coverage
php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

# Verify all authentication action classes have limiter injection
grep -r "protected LoginRateLimiter" app/Actions/ | wc -l

# Check for rate limiter assertions in authentication tests
grep -r "RateLimiter::" tests/ | grep -i "authentication\|login" | wc -l
```

**Accept when:**
- All authentication action classes that throw authentication exceptions call `limiter->increment()` before throwing.
- Session state for two-factor flows uses consistent `'login.id'` and `'login.remember'` keys.
- Authentication tests successfully assert rate limiter state changes after failed attempts.
- `LoginRateLimiter` is injected as a protected dependency in all in-scope action class constructors.
- The `Failed` event is fired before limiter increment in all authentication failure paths.

<enforcement>
Clause Code MUST NOT skip or defer verification of these rules during authentication action class review. Static analysis via PHPStan and integration test suite validation are mandatory before merge.
</enforcement>
# Use Rate Limiter Increment for Authentication Failure Metrics: Authentication Action Classes

These rules are ALWAYS ACTIVE for all authentication action classes in `app/Actions` and `app/Actions/Fortify` namespaces that validate credentials and handle authentication failures, including middleware-style actions, two-factor authentication challenge response methods, and Socialite driver authentication flows.

### Rules

- **R-AUTH-001** MUST: Authentication action classes MUST call `$this->limiter->increment($request)` immediately before throwing authentication failure exceptions.

### Verify

```bash
# Verify limiter->increment() calls in authentication failure paths
grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"

# Verify session state management for two-factor flows
grep -r "session()->put.*login\.id" app/Actions/ | wc -l

# Run authentication tests and check coverage
php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

# Verify rate limiter state assertions in tests
grep -r "RateLimiter::" tests/ | grep -c "remaining\|availableIn"
```

**Accept when:**
- All authentication action classes that throw authentication exceptions call `limiter->increment()` before throwing
- Session state for two-factor flows uses consistent `'login.id'` and `'login.remember'` keys
- Authentication tests successfully assert rate limiter state changes after failed attempts
- Rate limiter state can be inspected via `RateLimiter::remaining($key)` or `RateLimiter::availableIn($key)` in test assertions

<enforcement>
Claude Code MUST NOT skip or defer verification. All authentication action classes must be inspected for proper rate limiter increment calls before throwing exceptions. Static analysis and integration tests must pass before accepting changes to authentication flows.
</enforcement>
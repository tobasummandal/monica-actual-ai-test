# Use Rate Limiter Increment for Authentication Failure Metrics: Session State Operations

These rules are ALWAYS ACTIVE for authentication action classes in `app/Actions` and `app/Actions/Fortify` namespaces that handle credential validation, authentication failures, two-factor authentication flows, and Socialite driver authentication.

### Rules

- **R-AUTH-001** MUST: Session state operations for two-factor flows MUST use `$request->session()->put()` with `'login.id'` and `'login.remember'` keys.
- **R-AUTH-002** MUST: Authentication action classes that throw authentication exceptions MUST call `$this->limiter->increment($request)` before throwing the exception.
- **R-AUTH-003** MUST: Inject `LoginRateLimiter` in action class constructors as a protected property: `protected LoginRateLimiter $limiter`.
- **R-AUTH-004** SHOULD: Fire the `Failed` event before incrementing the limiter to ensure event listeners execute even if increment fails.

### Verify

```bash
# Verify limiter->increment() is called in authentication failure paths
grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"

# Verify session state uses consistent login.id and login.remember keys
grep -r "session()->put.*login\.id" app/Actions/ | wc -l

# Verify authentication tests assert rate limiter state changes
php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

# Verify all authentication action classes have LoginRateLimiter injected
grep -r "protected LoginRateLimiter" app/Actions/ | wc -l
```

**Accept when:**
- All authentication action classes that throw authentication exceptions call `limiter->increment()` before throwing
- Session state for two-factor flows uses consistent `'login.id'` and `'login.remember'` keys
- Authentication tests successfully assert rate limiter state changes after failed attempts
- All authentication action classes have `LoginRateLimiter` injected as a protected property

<enforcement>
Claude Code MUST NOT skip or defer verification. All four verify commands MUST pass before accepting authentication action class changes. Pull requests lacking `limiter->increment()` calls in exception paths MUST be blocked. Authentication tests MUST assert rate limiter behavior changes.
</enforcement>
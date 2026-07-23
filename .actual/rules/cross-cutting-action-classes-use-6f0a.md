# Use Rate Limiter Increment for Authentication Failure Metrics: Action Classes Use

These rules are ALWAYS ACTIVE for all authentication action classes in `app/Actions/` and `app/Actions/Fortify/` namespaces that handle credential validation, authentication failures, and two-factor authentication flows.

### Rules

- **R-AUTH-001** MAY: Action classes MAY use tap() helper to chain user validation with failure event firing.
- **R-AUTH-002** MUST: Call `$this->limiter->increment($request)` immediately before throwing `ValidationException` in authentication failure paths.
- **R-AUTH-003** MUST: Fire `Failed` event before incrementing limiter to ensure event listeners execute even if increment fails.
- **R-AUTH-004** SHOULD: Inject `LoginRateLimiter` in action class constructors as protected property: `protected LoginRateLimiter $limiter`.
- **R-AUTH-005** SHOULD: Use `$request->session()->put(['login.id' => $user->getKey(), 'login.remember' => ...])` for two-factor challenge state management.

### Verify

```bash
# Verify limiter->increment() calls in authentication failure paths
grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"

# Verify session state management for two-factor flows
grep -r "session()->put.*login\.id" app/Actions/ | wc -l

# Run authentication tests with coverage
php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

# Verify rate limiter state assertions in tests
grep -r "RateLimiter::" tests/ | grep -E "(remaining|availableIn)" | wc -l
```

**Accept when:**
- All authentication action classes that throw authentication exceptions call `limiter->increment()` before throwing.
- Session state for two-factor flows uses consistent `'login.id'` and `'login.remember'` keys.
- Authentication tests successfully assert rate limiter state changes after failed attempts.
- `Failed` event is fired before `limiter->increment()` in all authentication failure paths.
- `LoginRateLimiter` is injected as a protected property in all relevant action classes.

<enforcement>
Claude Code MUST NOT skip or defer verification. All authentication action classes must be audited for compliance with R-AUTH-002 and R-AUTH-003. Rate limiter state assertions must be present in authentication test suites. Pull requests modifying authentication flows require verification of all rules before approval.
</enforcement>
# Use Rate Limiter Increment for Authentication Failure Metrics: Authentication Middleware Actions

These rules are ALWAYS ACTIVE for authentication action classes in `app/Actions` and `app/Actions/Fortify` namespaces that validate credentials, handle authentication failures, or manage two-factor authentication challenge responses.

### Rules

- **R-AUTH-001** SHOULD: Authentication middleware actions SHOULD implement `handle(Request $request, callable|Closure $next)` signature for pipeline compatibility.
- **R-AUTH-002** MUST: Call `$this->limiter->increment($request)` immediately before throwing `ValidationException` in authentication failure paths.
- **R-AUTH-003** MUST: Inject `LoginRateLimiter` in action class constructors as a protected property: `protected LoginRateLimiter $limiter`.
- **R-AUTH-004** SHOULD: Fire `Failed` event before incrementing limiter to ensure event listeners execute even if increment fails.
- **R-AUTH-005** SHOULD: Use `$request->session()->put(['login.id' => $user->getKey(), 'login.remember' => ...])` for two-factor challenge state management.

### Verify

```bash
# Verify limiter->increment() calls in authentication failure paths
grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"

# Verify session state management for two-factor flows
grep -r "session()->put.*login\.id" app/Actions/ | wc -l

# Run authentication tests with coverage
php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

# Verify LoginRateLimiter injection in action constructors
grep -r "protected LoginRateLimiter" app/Actions/ | wc -l

# Verify rate limiter assertions in tests
grep -r "RateLimiter::" tests/ | grep -E "(remaining|availableIn)" | wc -l
```

**Accept when:**
- All authentication action classes that throw authentication exceptions call `limiter->increment()` before throwing
- Session state for two-factor flows uses consistent `'login.id'` and `'login.remember'` keys
- Authentication tests successfully assert rate limiter state changes after failed attempts
- `LoginRateLimiter` is injected as a protected property in all authentication action classes
- `Failed` events are fired before limiter increment operations in exception paths

<enforcement>
Claude Code MUST NOT skip or defer verification. All authentication action classes MUST be audited for compliance with R-AUTH-002 and R-AUTH-003. Integration tests MUST validate rate limiter state changes. Pull requests modifying authentication flows MUST include rate limiter assertions.
</enforcement>
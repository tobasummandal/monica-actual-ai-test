# Use Rate Limiter Increment for Authentication Failure Metrics: Rate Limiter Increment

These rules are ALWAYS ACTIVE for authentication action classes in `app/Actions` and `app/Actions/Fortify` namespaces that handle credential validation, authentication failures, two-factor authentication challenges, and Socialite driver authentication flows.

### Rules

- **R-RLIM-001** MUST: Rate limiter increment operations MUST occur after firing failed authentication events via `event(new Failed(...))`.

### Verify

```bash
# Verify rate limiter increment calls exist in authentication action classes
grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"

# Verify session state management for two-factor flows uses consistent keys
grep -r "session()->put.*login\.id" app/Actions/ | wc -l

# Run authentication test suite and check coverage
php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

# Verify Failed event is fired before limiter increment
grep -B 5 "limiter->increment" app/Actions/**/*.php | grep -c "event(new Failed"
```

**Accept when:**
- All authentication action classes that throw authentication exceptions call `limiter->increment($request)` before throwing
- Session state for two-factor flows uses consistent `'login.id'` and `'login.remember'` keys
- Authentication tests successfully assert rate limiter state changes after failed attempts
- Failed authentication events are fired before rate limiter increment operations

<enforcement>
Clause Code MUST NOT skip or defer verification. All authentication action classes MUST be inspected for proper rate limiter increment placement after Failed events. Pull requests modifying authentication flows MUST pass all verify commands before merge.
</enforcement>
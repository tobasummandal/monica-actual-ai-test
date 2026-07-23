# Standardize Rate Limiter Increment Calls in Authentication Failure Paths: Middleware Classes Implementing

These rules are ALWAYS ACTIVE for authentication middleware classes that implement handle(Request, Closure) methods, validate user credentials, and throw authentication exceptions across all authentication strategies (password, OAuth, WebAuthn, two-factor).

### Rules

- **R-AUTH-001** SHOULD: Middleware classes implementing authentication logic SHOULD follow the pattern: validateCredentials → fireFailedEvent → limiter→increment → throwException
- **R-AUTH-002** MUST: Authentication middleware classes that throw ValidationException on credential failures MUST inject LoginRateLimiter through constructor dependency injection.
- **R-AUTH-003** MUST: Rate limiter increment operations MUST be called synchronously in the request lifecycle after firing Failed events but before throwing ValidationException.
- **R-AUTH-004** SHOULD: Non-authentication metric tracking SHOULD use DB::table('table_name')->where($conditions)->increment('counter_field') for atomic updates rather than manual read-modify-write patterns.
- **R-AUTH-005** MUST: Rate limiter configuration (max attempts, decay minutes) MUST be consistent across all authentication strategies by referencing shared configuration values.

### Verify

```bash
# Detect authentication middleware classes missing LoginRateLimiter injection
grep -r 'class.*Authenticate' app/ | xargs grep -L 'LoginRateLimiter' | grep -v Test

# Verify rate limiter increment calls in failure paths
grep -r 'throwFailed.*Exception' app/Actions/ | xargs grep -B5 'throw.*ValidationException' | grep -c 'limiter->increment'

# Audit all increment operations for atomic patterns
grep -r '->increment(' app/ --include='*.php' | grep -E '(limiter->increment|DB::table.*->increment)'
```

**Accept when:**
- All authentication middleware classes that throw ValidationException on credential failures inject LoginRateLimiter and call increment before throwing
- Grep verification shows no authentication classes missing LoginRateLimiter dependency injection
- All increment operations for counters use atomic increment() methods rather than manual read-modify-write patterns
- Rate limiting configuration is centralized and referenced consistently across all authentication strategies
- Integration tests verify rate limiting behavior across all authentication pathways (OAuth, password, WebAuthn, two-factor)

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis rules checking for authentication middleware classes without LoginRateLimiter injection MUST be enforced in CI pipeline. Security review is required for any authentication code that does not follow the established pattern.
</enforcement>
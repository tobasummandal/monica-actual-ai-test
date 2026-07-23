# Standardize Rate Limiter Increment Calls in Authentication Failure Paths: Rate Limiter Increment

These rules are ALWAYS ACTIVE for authentication middleware classes that implement handle(Request, Closure) methods, classes that validate user credentials and throw authentication exceptions, and rate limiting logic for login attempts across all authentication strategies (password, OAuth, WebAuthn, two-factor).

### Rules

- **R-RATELIMIT-001** MUST: Rate limiter increment calls MUST occur after firing authentication failure events and before exception propagation.

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
- Rate limiter increment calls are positioned after Failed authentication events but before exception propagation in all authentication pathways

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis rules checking for authentication middleware classes without LoginRateLimiter injection MUST be run. Code review checklist items for new authentication strategy implementations MUST be verified. Integration tests verifying rate limiting behavior across all authentication pathways MUST pass. CI pipeline MUST fail if static analysis detects authentication middleware without rate limiting.
</enforcement>
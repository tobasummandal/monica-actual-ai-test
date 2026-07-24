# Standardize Rate Limiter Increment Calls in Authentication Failure Paths: Authentication Middleware Classes

These rules are ALWAYS ACTIVE for all authentication middleware classes that implement handle(Request, Closure) methods, validate user credentials, and throw authentication exceptions across all authentication strategies (password, OAuth, WebAuthn, two-factor).

### Rules

- **R-AUTH-001** MUST: All authentication middleware classes MUST inject a LoginRateLimiter or equivalent rate limiting service through constructor dependency injection.
- **R-AUTH-002** MUST: Rate limiter increment operations MUST be called in authentication failure paths before throwing ValidationException or equivalent authentication exceptions.
- **R-AUTH-003** MUST: Atomic increment() methods MUST be used for counter metrics rather than manual read-modify-write patterns.
- **R-AUTH-004** SHOULD: Rate limiter configuration (max attempts, decay minutes) SHOULD be consistent across all authentication strategies by referencing shared configuration values.

### Verify

```bash
# Detect authentication middleware classes without LoginRateLimiter injection
grep -r 'class.*Authenticate' app/ | xargs grep -L 'LoginRateLimiter' | grep -v Test

# Verify rate limiter increment calls in failure paths
grep -r 'throwFailed.*Exception' app/Actions/ | xargs grep -B5 'throw.*ValidationException' | grep -c 'limiter->increment'

# Verify atomic increment operations are used
grep -r '->increment(' app/ --include='*.php' | grep -E '(limiter->increment|DB::table.*->increment)'
```

**Accept when:**
- All authentication middleware classes that throw ValidationException on credential failures inject LoginRateLimiter and call increment before throwing
- Grep verification shows no authentication classes missing LoginRateLimiter dependency injection
- All increment operations for counters use atomic increment() methods rather than manual read-modify-write patterns
- Rate limiting configuration is centralized and referenced consistently across all authentication strategies

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis rules checking for authentication middleware classes without LoginRateLimiter injection MUST be enforced in CI pipeline. Code review checklist items for new authentication strategy implementations MUST include rate limiting requirements. Integration tests verifying rate limiting behavior across all authentication pathways MUST pass before deployment.
</enforcement>
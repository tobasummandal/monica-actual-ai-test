# Standardize Rate Limiter Increment Calls in Authentication Failure Paths: Non Authentication Metric

These rules are ALWAYS ACTIVE for authentication middleware classes, credential validation logic, and non-authentication metric tracking operations across the codebase.

### Rules

- **R-AUTH-001** MUST: Authentication middleware classes that throw ValidationException on credential failures SHALL inject LoginRateLimiter and call increment before throwing the exception.
- **R-AUTH-002** MUST: Rate limiter increment operations SHALL occur after firing Failed authentication events but before throwing ValidationException.
- **R-AUTH-003** MUST: LoginRateLimiter dependencies SHALL be injected through constructor parameters using protected properties for access in handle() methods.
- **R-AUTH-004** MAY: Non-authentication metric tracking (such as view counters) MAY use DB::table()->increment() for atomic counter updates when LoginRateLimiter is not applicable.
- **R-AUTH-005** SHOULD: Rate limiter configuration (max attempts, decay minutes) SHOULD be consistent across all authentication strategies by referencing shared configuration values.
- **R-AUTH-006** MUST: All increment operations for counters SHALL use atomic increment() methods rather than manual read-modify-write patterns.

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
- Non-authentication metric tracking uses DB::table()->increment() for atomic updates
- Rate limiter configuration is centralized and referenced consistently across authentication strategies

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis rules checking for authentication middleware classes without LoginRateLimiter injection MUST be enforced in CI pipeline. Code review checklist items for new authentication strategy implementations MUST include rate limiting requirements. Integration tests verifying rate limiting behavior across all authentication pathways MUST pass before deployment.
</enforcement>
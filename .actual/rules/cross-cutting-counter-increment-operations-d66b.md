# Standardize Rate Limiter Increment Calls in Authentication Failure Paths: Counter Increment Operations

These rules are ALWAYS ACTIVE for authentication middleware classes, credential validation logic, and security-sensitive counter operations across all authentication strategies (password, OAuth, WebAuthn, two-factor).

### Rules

- **R-AUTH-001** SHOULD: Counter increment operations for metrics SHOULD use framework-provided increment() methods (LoginRateLimiter->increment() or DB::table()->increment()) rather than manual read-modify-write cycles.

### Verify

```bash
# Detect authentication middleware classes missing LoginRateLimiter injection
grep -r 'class.*Authenticate' app/ | xargs grep -L 'LoginRateLimiter' | grep -v Test

# Verify rate limiter increment calls in authentication failure paths
grep -r 'throwFailed.*Exception' app/Actions/ | xargs grep -B5 'throw.*ValidationException' | grep -c 'limiter->increment'

# Audit all increment operations for atomic patterns
grep -r '->increment(' app/ --include='*.php' | grep -E '(limiter->increment|DB::table.*->increment)'
```

**Accept when:**
- All authentication middleware classes that throw ValidationException on credential failures inject LoginRateLimiter and call increment before throwing
- Grep verification shows no authentication classes missing LoginRateLimiter dependency injection
- All increment operations for counters use atomic increment() methods rather than manual read-modify-write patterns
- Rate limiting is applied consistently across all authentication pathways (OAuth, password, WebAuthn, two-factor)

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis rules checking for authentication middleware classes without LoginRateLimiter injection MUST be enforced in CI pipeline. Code review checklist items for new authentication strategy implementations MUST include rate limiting requirements. Integration tests verifying rate limiting behavior across all authentication pathways MUST pass before deployment.
</enforcement>
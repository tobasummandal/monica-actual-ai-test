# Standardize Rate Limiter Increment Calls in Authentication Failure Paths: Authentication Failure Paths

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- Authentication middleware classes across multiple authentication strategies (Socialite OAuth, Fortify two-factor, Webauthn) consistently inject LoginRateLimiter dependencies and call increment methods on authentication failures
- The codebase implements multiple authentication pathways (social login, password-based, WebAuthn) that require consistent rate limiting behavior to prevent brute force attacks
- Rate limiting metrics are captured at the authentication boundary layer through middleware handle() methods that intercept requests before authentication completion
- A separate domain service (UpdateContactView) demonstrates a parallel pattern of incrementing view counters using DB facade increment() calls, indicating a broader architectural preference for in-place metric updates

## Problem Statement

Authentication systems with multiple authentication strategies require consistent rate limiting instrumentation to prevent brute force attacks and maintain security posture. Without standardized metric collection at authentication failure points, the system risks inconsistent protection across different authentication pathways and loses visibility into attack patterns.

## Decision

1. MUST: Authentication failure paths MUST call limiter->increment($request) before throwing ValidationException or returning error responses

## Policy Block

- MUST Authentication failure paths MUST call limiter->increment($request) before throwing ValidationException or returning error responses

In scope:
- Authentication middleware classes that implement handle(Request, Closure) methods
- Classes that validate user credentials and throw authentication exceptions
- Rate limiting logic for login attempts across all authentication strategies (password, OAuth, WebAuthn, two-factor)
- Metric increment operations for security-sensitive counters

Out of scope:
- Authorization checks performed after successful authentication
- Session management and token generation logic
- Non-security-related metric collection (analytics, usage tracking)
- Rate limiting for non-authentication endpoints (API throttling, general request limiting)

Exceptions:
- EXC-001: Authentication succeeds and no failure event is fired
- EXC-002: Two-factor authentication challenge is issued (user exists but requires second factor)

## Rationale

- The evidence shows consistent implementation of $this->limiter->increment($request) across three authentication middleware classes (AttemptToAuthenticateSocialite, RedirectIfTwoFactorAuthenticatable, AttemptToAuthenticateWebauthn), indicating an established architectural pattern
- Rate limiting at the authentication boundary provides defense-in-depth against brute force attacks while maintaining visibility into attack patterns through metric collection
- The pattern of injecting LoginRateLimiter through constructor dependency injection enables testability and allows for different rate limiting strategies across environments
- The parallel pattern in UpdateContactView using DB::table()->increment() demonstrates that atomic increment operations are the preferred approach for counter metrics across the codebase

## Consequences

Positive:
- Consistent rate limiting protection across all authentication pathways (OAuth, password, WebAuthn) prevents attackers from exploiting less-protected authentication methods
- Centralized metric collection through LoginRateLimiter enables monitoring and alerting on authentication attack patterns
- Atomic increment operations prevent race conditions in counter updates under concurrent authentication attempts
- Dependency injection of rate limiters enables testing authentication logic without actual rate limiting side effects

Negative:
- Additional dependency injection requirement increases constructor complexity in authentication middleware classes
- Rate limiter state must be managed consistently across distributed deployments (requires shared cache or database backend)
- Increment operations add latency to authentication failure paths, though this is typically acceptable for security-critical operations
- Developers implementing new authentication strategies must remember to add rate limiting instrumentation or risk creating security gaps

## Alternatives

- Implement rate limiting through HTTP middleware applied globally to authentication routes rather than within authentication action classes (rejected)
  Rejected because: Global HTTP middleware cannot access authentication-specific context (user identity, credential validation results) needed for sophisticated rate limiting strategies. The current pattern allows rate limiting decisions to be made with full authentication context.
  When valid: Acceptable for simple IP-based rate limiting where authentication context is not required
- Use event listeners on Failed authentication events to increment rate limiters rather than explicit calls in middleware (rejected)
  Rejected because: Event-based rate limiting introduces timing uncertainty and makes it harder to guarantee rate limit enforcement before exception propagation. The current pattern ensures rate limiting occurs synchronously in the request lifecycle.
  When valid: Suitable for asynchronous metric collection where enforcement timing is not critical
- Implement rate limiting through aspect-oriented programming or method annotations rather than explicit limiter calls (rejected)
  Rejected because: PHP ecosystem lacks mature AOP support, and Laravel conventions favor explicit dependency injection. The current pattern is more idiomatic for Laravel applications.
  When valid: Viable in frameworks with strong AOP support (Spring, AspectJ) where cross-cutting concerns are standardized through annotations

## Risks

- New authentication strategies may be implemented without rate limiting instrumentation, creating security vulnerabilities
  Mitigation: Add static analysis rules to detect authentication middleware classes that inject StatefulGuard but not LoginRateLimiter. Include rate limiting requirements in authentication implementation documentation and code review checklists.
  Owner: Security team and authentication framework maintainers
- Rate limiter backend (cache/database) failures could cause authentication system unavailability if increment operations are blocking
  Mitigation: Implement graceful degradation where rate limiter failures log warnings but allow authentication to proceed. Configure appropriate timeouts for rate limiter operations. Monitor rate limiter backend health separately.
  Owner: Platform engineering team
- Inconsistent rate limiting configuration across authentication strategies could create exploitable weak points
  Mitigation: Centralize rate limiting configuration in a single configuration file. Use the same LoginRateLimiter instance across all authentication middleware. Add integration tests that verify rate limiting behavior across all authentication pathways.
  Owner: Engineering team

## Implementation Notes

- Inject LoginRateLimiter (Laravel Fortify) or LaravelWebauthn\Services\LoginRateLimiter through constructor parameters using protected properties for access in handle() methods
- Call $this->limiter->increment($request) in throwFailedAuthenticationException() methods or equivalent failure handling paths, after firing Failed events but before throwing ValidationException
- For non-authentication metric tracking, use DB::table('table_name')->where($conditions)->increment('counter_field') for atomic updates as demonstrated in UpdateContactView
- Ensure rate limiter configuration (max attempts, decay minutes) is consistent across all authentication strategies by referencing shared configuration values

## Continuation Context


Verify commands:
- grep -r 'class.*Authenticate' app/ | xargs grep -L 'LoginRateLimiter' | grep -v Test
- grep -r 'throwFailed.*Exception' app/Actions/ | xargs grep -B5 'throw.*ValidationException' | grep -c 'limiter->increment'
- grep -r '->increment(' app/ --include='*.php' | grep -E '(limiter->increment|DB::table.*->increment)'

Accept when:
- All authentication middleware classes that throw ValidationException on credential failures inject LoginRateLimiter and call increment before throwing
- Grep verification shows no authentication classes missing LoginRateLimiter dependency injection
- All increment operations for counters use atomic increment() methods rather than manual read-modify-write patterns

## Enforcement

- Verified by: Static analysis rules checking for authentication middleware classes without LoginRateLimiter injection
- Verified by: Code review checklist items for new authentication strategy implementations
- Verified by: Integration tests verifying rate limiting behavior across all authentication pathways
- Violation handling: CI pipeline fails if static analysis detects authentication middleware without rate limiting
- Violation handling: Security review required for any authentication code that does not follow the established pattern
- Violation handling: Post-deployment monitoring alerts on authentication endpoints with anomalous failure rates
- Exception process: Document exception rationale in ADR amendment or inline code comments explaining why rate limiting is not applicable
- Exception process: Obtain security team approval for authentication implementations that deviate from standard rate limiting pattern
- Exception process: Add compensating controls (alternative rate limiting mechanism, enhanced monitoring) if standard pattern cannot be applied
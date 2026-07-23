# Use Rate Limiter Increment for Authentication Failure Metrics: Authentication Middleware Actions

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- Authentication failure tracking requires observable metrics to validate rate limiting behavior and security controls
- Laravel Fortify's LoginRateLimiter provides increment operations that serve dual purposes: enforcement and measurement
- Two authentication action classes (AttemptToAuthenticateSocialite and RedirectIfTwoFactorAuthenticatable) both call $this->limiter->increment($request) on authentication failures
- Session state management via $request->session()->put() co-occurs with rate limiter operations in two-factor authentication flows
- The pattern appears in middleware-style action classes that handle authentication pipelines with StatefulGuard and LoginRateLimiter dependencies

## Problem Statement

Authentication systems need verifiable metrics for failed login attempts to validate rate limiting effectiveness, detect security anomalies, and ensure proper enforcement of authentication policies. Without consistent metric collection at failure points, testing authentication flows becomes unreliable and security controls cannot be validated programmatically.

## Decision

1. SHOULD: Authentication middleware actions SHOULD implement handle(Request $request, callable|Closure $next) signature for pipeline compatibility

## Policy Block

- SHOULD Authentication middleware actions SHOULD implement handle(Request $request, callable|Closure $next) signature for pipeline compatibility

In scope:
- Authentication action classes in app/Actions and app/Actions/Fortify namespaces
- Middleware-style actions that validate credentials and handle authentication failures
- Two-factor authentication challenge response methods
- Socialite driver authentication flows

Out of scope:
- Password reset flows that do not involve authentication attempts
- API token authentication that bypasses session-based rate limiting
- Background job authentication or service-to-service authentication
- Guest user flows that do not attempt credential validation

Exceptions:
- EXC-001: Authentication attempts are rate-limited by external infrastructure (e.g., API gateway, WAF) with separate metric collection

## Rationale

- The evidence shows consistent co-occurrence of $this->limiter->increment($request) with authentication failure handling across two independent authentication action classes, indicating an established pattern
- Rate limiter increment serves as both enforcement mechanism and observable metric, enabling test validation of authentication failure counts
- Session state management pattern ($request->session()->put()) provides testable state transitions for two-factor authentication flows
- The pattern leverages Laravel Fortify's LoginRateLimiter and Illuminate authentication events, creating integration points for testing and monitoring

## Consequences

Positive:
- Authentication failure metrics become programmatically verifiable through rate limiter state inspection
- Consistent metric collection enables automated testing of rate limiting behavior and security controls
- Session state operations provide deterministic test assertions for two-factor authentication flows
- Integration with Laravel's event system (Failed event) creates additional observability hooks for testing

Negative:
- Rate limiter state becomes coupled to metric collection, complicating scenarios where rate limiting is disabled but metrics are still needed
- Session-based state management requires integration testing with session drivers, increasing test complexity
- Metric collection occurs only at failure points, missing successful authentication attempts for complete observability
- Dependency on LoginRateLimiter implementation details may create brittleness when upgrading Laravel Fortify

## Alternatives

- Separate metric collection from rate limiting by introducing dedicated MetricsCollector service (rejected)
  Rejected because: Adds complexity and duplication when LoginRateLimiter already provides increment operations that serve both purposes; evidence shows existing pattern works across multiple authentication flows
  When valid: When rate limiting and metrics need independent lifecycle management or different storage backends
- Use Laravel event listeners to collect metrics from Failed authentication events instead of direct limiter calls (rejected)
  Rejected because: Decouples metric collection from rate limiting enforcement, risking inconsistency; evidence shows limiter->increment() is called reliably at failure points
  When valid: When metrics need to be collected across multiple event types beyond authentication failures
- Implement custom middleware for metric collection that wraps authentication actions (deferred)
  Rejected because: Not rejected; could provide cleaner separation of concerns but requires refactoring existing action classes
  When valid: When standardizing observability across all middleware pipelines, not just authentication

## Risks

- Rate limiter state may not persist correctly in testing environments using array or null cache drivers, causing metric assertions to fail
  Mitigation: Configure test environment to use Redis or database cache driver for rate limiting; add test setup validation to verify limiter persistence
  Owner: Engineering team
- Session state operations may behave differently across session drivers (file, database, redis), causing test flakiness
  Mitigation: Standardize session driver for testing; create session state assertion helpers that abstract driver differences
  Owner: Engineering team
- Metric collection only at failure points provides incomplete observability for authentication flow testing
  Mitigation: Supplement with successful authentication event tracking; document metric limitations in testing guidelines
  Owner: Security team

## Implementation Notes

- Inject LoginRateLimiter in action class constructors as protected property: protected LoginRateLimiter $limiter
- Call $this->limiter->increment($request) immediately before throwing ValidationException in throwFailedAuthenticationException methods
- Use $request->session()->put(['login.id' => $user->getKey(), 'login.remember' => ...]) for two-factor challenge state
- Fire Failed event before incrementing limiter to ensure event listeners execute even if increment fails
- In tests, assert rate limiter state using RateLimiter facade: RateLimiter::remaining($key) or RateLimiter::availableIn($key)

## Continuation Context


Verify commands:
- grep -r "limiter->increment" app/Actions/ | grep -c "throwFailedAuthenticationException"
- grep -r "session()->put.*login\.id" app/Actions/ | wc -l
- php artisan test --filter Authentication --coverage-text | grep -A 5 "Actions"

Accept when:
- All authentication action classes that throw authentication exceptions call limiter->increment() before throwing
- Session state for two-factor flows uses consistent 'login.id' and 'login.remember' keys
- Authentication tests successfully assert rate limiter state changes after failed attempts

## Enforcement

- Verified by: Code review checklist for authentication action classes
- Verified by: Static analysis via custom PHPStan rule checking limiter->increment() presence in exception paths
- Verified by: Integration test suite validating rate limiter state changes
- Violation handling: Pull request blocked if authentication actions lack limiter->increment() calls
- Violation handling: CI pipeline fails if authentication tests do not assert rate limiter behavior
- Violation handling: Security review required for any authentication flow changes
- Exception process: Request exception via security team with documented rationale for alternative metric collection
- Exception process: Provide evidence of equivalent observability mechanism (e.g., external rate limiting with metrics)
- Exception process: Update security runbook with exception details and monitoring configuration
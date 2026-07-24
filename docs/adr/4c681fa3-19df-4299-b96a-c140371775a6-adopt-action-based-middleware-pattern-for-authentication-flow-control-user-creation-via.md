# Adopt Action-Based Middleware Pattern for Authentication Flow Control: User Creation Via

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The application implements OAuth-based social authentication alongside traditional credential-based authentication, requiring coordinated handling of multiple authentication providers (OAuth1, OAuth2) and user token persistence.
- Two-factor authentication (2FA) and WebAuthn support necessitate conditional flow control during authentication, where middleware must intercept requests and redirect to challenge flows based on user security settings.
- User creation and token association logic must handle both new user registration via social providers and linking social accounts to existing authenticated users, requiring stateful session management across authentication steps.
- Rate limiting and failed authentication event tracking are integrated into the authentication flow, requiring middleware to coordinate with guards, limiters, and event dispatchers.
- The Laravel framework's StatefulGuard, LoginRateLimiter, and Request abstractions provide the foundation for implementing authentication actions as middleware-style handlers with handle() methods accepting Request and callable next parameters.

## Problem Statement

Authentication flows involving multiple providers, conditional security challenges, and stateful user association require a structured approach to coordinate data access, session management, and flow control without scattering authentication logic across controllers or creating tight coupling between authentication concerns and HTTP routing.

## Decision

1. SHOULD: User creation via social providers SHOULD delegate to dedicated action classes (CreateNewUser) and dispatch Registered events using tap() for side effects.

## Policy Block

- SHOULD User creation via social providers SHOULD delegate to dedicated action classes (CreateNewUser) and dispatch Registered events using tap() for side effects.

In scope:
- Authentication flows requiring OAuth provider integration (Socialite drivers)
- Two-factor authentication and WebAuthn challenge coordination
- User token association and persistence for social login providers
- Rate-limited authentication attempts with failed event tracking
- Session-based authentication state management across multi-step flows

Out of scope:
- Authorization and permission checking after authentication completes
- API token-based authentication (stateless JWT or bearer tokens)
- Password reset and email verification flows
- Single sign-on (SSO) integration with external identity providers beyond OAuth
- Session storage backend configuration (Redis, database, file)

## Rationale

- The middleware-style action pattern separates authentication flow control from HTTP routing, enabling reusable authentication logic across both traditional login and social provider endpoints while maintaining consistent rate limiting and event tracking.
- Constructor injection of StatefulGuard and LoginRateLimiter establishes explicit dependencies for authentication state management, making testing and mocking straightforward while avoiding static facade calls in core authentication logic.
- Eloquent-based UserToken persistence provides a consistent data access layer for OAuth provider associations, supporting both OAuth1 (token/tokenSecret) and OAuth2 (token/refreshToken/expiresIn) formats through a unified model interface.
- Session-based 2FA state management using login.id and login.remember keys enables stateful authentication flows where the initial credential validation and subsequent challenge verification occur in separate requests without requiring database round-trips.

## Consequences

Positive:
- Authentication logic is encapsulated in testable action classes with clear dependencies, improving maintainability and enabling unit testing of authentication flows without HTTP integration tests.
- The handle() method signature enables composition of authentication actions in middleware pipelines, allowing flexible ordering of rate limiting, credential validation, and 2FA detection.
- Eloquent model methods provide a consistent abstraction for user and token persistence, supporting both query operations (where, firstWhere) and mutations (create) with automatic timestamp management.
- Session-based state management enables multi-step authentication flows (credential validation → 2FA challenge → final login) while maintaining user context across requests.

Negative:
- Middleware-style actions introduce indirection between HTTP routes and authentication logic, requiring developers to trace through handle() method chains to understand complete authentication flows.
- Session state dependencies (login.id, login.remember keys) create implicit contracts between authentication actions and 2FA challenge handlers, increasing coupling and making refactoring error-prone.
- Eloquent model usage for UserToken persistence couples authentication logic to the ORM layer, making it difficult to optimize queries or migrate to alternative data access patterns without modifying action classes.
- Constructor-injected dependencies (StatefulGuard, LoginRateLimiter) must be resolved through Laravel's service container, creating framework coupling and complicating standalone usage of authentication actions.

## Alternatives

- Implement authentication logic directly in controller methods with inline guard and session calls (rejected)
  Rejected because: Controller-based authentication scatters logic across multiple endpoints, duplicates rate limiting and event tracking code, and tightly couples HTTP concerns with authentication business logic, reducing testability and reusability.
  When valid: Simple applications with single authentication method and no 2FA requirements where code duplication is acceptable.
- Use Laravel's built-in authentication middleware (auth, guest) without custom action classes (rejected)
  Rejected because: Built-in middleware does not support OAuth provider integration, conditional 2FA flow control, or custom user token association logic required for social authentication with multiple providers.
  When valid: Applications using only traditional username/password authentication without social login or 2FA requirements.
- Implement authentication as domain services with explicit transaction boundaries instead of middleware-style actions (deferred)
  Rejected because: Domain service approach provides better separation of concerns and explicit transaction management, but requires more significant refactoring of existing Laravel authentication infrastructure and may reduce compatibility with Fortify/Socialite packages.
  When valid: Greenfield applications or major refactoring efforts where domain-driven design principles take precedence over framework conventions.

## Risks

- Session state corruption or key collisions if login.id or login.remember keys are used by other application components, causing authentication failures or security vulnerabilities.
  Mitigation: Document reserved session keys in authentication documentation, implement session key namespacing (e.g., auth.login.id), and add integration tests verifying session state isolation across authentication flows.
  Owner: Engineering team
- UserToken model queries (firstWhere) may cause N+1 query problems or performance degradation under high authentication load if relationships are not eagerly loaded.
  Mitigation: Add database indexes on driver_id and driver columns, implement query monitoring for authentication endpoints, and consider caching UserToken lookups for frequently authenticated users.
  Owner: Engineering team
- OAuth provider API changes or token format variations may break UserToken persistence logic if OAuth1User or OAuth2User interfaces change in Socialite package updates.
  Mitigation: Pin Socialite package versions in composer.json, implement integration tests against OAuth provider sandbox environments, and add defensive type checking before accessing token properties.
  Owner: Engineering team

## Implementation Notes

- Authentication action classes should extend a base action class or implement a shared interface to enforce consistent handle() method signatures and dependency injection patterns across all authentication flows.
- Use Laravel's tap() helper when creating users or tokens to chain side effects (event dispatching, token creation) while maintaining readable code and avoiding temporary variable assignments.
- Implement separate private methods for each authentication sub-concern (validateCredentials, authenticateUser, createUserToken) to improve testability and enable mocking of individual steps in unit tests.
- Add explicit type hints for all method parameters and return types, especially for nullable User returns, to leverage static analysis tools and catch authentication flow errors at development time.
- Consider extracting session key constants (LOGIN_ID_KEY, LOGIN_REMEMBER_KEY) to a shared configuration class to prevent key collisions and enable centralized session state management.

## Continuation Context


Verify commands:
- grep -r "public function handle(Request \$request, callable \$next)" app/Actions/ | wc -l
- grep -r "protected StatefulGuard \$guard" app/Actions/ | wc -l
- grep -r "UserToken::create\|UserToken::firstWhere" app/Actions/ | wc -l
- grep -r "\$request->session()->put" app/Actions/ | wc -l

Accept when:
- All authentication action classes in app/Actions/ implement handle(Request $request, callable $next) method signature (verify command returns count >= 2)
- Authentication actions inject StatefulGuard via constructor (verify command returns count >= 2)
- UserToken model is used for OAuth provider persistence with create or firstWhere methods (verify command returns count >= 2)
- Session state management uses $request->session()->put() for storing authentication context (verify command returns count >= 2)

## Enforcement

- Verified by: Code review checklist verifying authentication actions implement required handle() signature and constructor dependencies
- Verified by: Static analysis via PHPStan or Psalm with custom rules checking for StatefulGuard and LoginRateLimiter injection in authentication action constructors
- Verified by: Integration tests validating complete authentication flows including OAuth provider callbacks, 2FA challenges, and session state management
- Violation handling: Pull requests introducing authentication actions without proper handle() signature or dependency injection are blocked until corrected
- Violation handling: Static analysis failures in CI pipeline prevent merging code that violates authentication action patterns
- Violation handling: Quarterly architecture reviews identify authentication logic drift and schedule refactoring to align with established patterns
- Exception process: Exceptions require architecture review approval with documented justification for alternative authentication approach
- Exception process: Temporary exceptions for experimental authentication methods must include sunset date and migration plan to standard pattern
- Exception process: Legacy authentication code predating this ADR is exempt but should be refactored opportunistically during related feature work
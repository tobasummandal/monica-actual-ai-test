# Adopt Laravel Fortify for Authentication with Centralized Input Validation: Authentication Operations Registration

Status: proposed
Date: 2025-01-17
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all authentication and user management implementations. All new user registration, profile updates, and authentication flows MUST follow the patterns defined herein.

## Context

- The application requires robust authentication and user management capabilities with consistent security practices across all entry points
- Laravel Fortify provides a headless authentication backend that separates authentication logic from presentation concerns, enabling flexible frontend implementations
- Input validation for user data (registration, profile updates) must be centralized and consistently applied to prevent security vulnerabilities
- The codebase shows a pattern of using Fortify Actions (CreateNewUser, UpdateUserProfileInformation) integrated through FortifyServiceProvider, indicating a deliberate architectural choice
- The security.input_validation facet indicates this pattern specifically addresses input sanitization and validation concerns in authentication flows

## Problem Statement

Applications need a standardized, secure approach to handling user authentication, registration, and profile management that ensures consistent input validation across all user-facing operations while maintaining separation of concerns between authentication logic and presentation layers. Without a unified library approach, validation rules become scattered, security vulnerabilities increase, and maintenance becomes difficult.

## Decision

1. MUST: All authentication operations (registration, login, password reset, profile updates) MUST be implemented using Laravel Fortify Actions

## Policy Block

- MUST All authentication operations (registration, login, password reset, profile updates) MUST be implemented using Laravel Fortify Actions

In scope:
- User registration and account creation
- User profile information updates
- Password reset and recovery flows
- Email verification processes
- Two-factor authentication setup
- All user input validation in authentication contexts

Out of scope:
- Authorization and permission management (handled by separate authorization layer)
- Session management (handled by Laravel's session infrastructure)
- Frontend presentation and UI components
- API token generation for non-authentication purposes
- Business logic unrelated to user authentication

Exceptions:
- EXC-001: Legacy authentication systems during migration period
- EXC-002: Third-party OAuth/SSO integrations that require custom authentication flows

## Rationale

- Pattern detected across 5 files with 81.32% confidence, indicating consistent adoption of Laravel Fortify for authentication concerns
- Centralized input validation through Fortify Actions reduces code duplication and ensures consistent security practices across all authentication entry points
- Laravel Fortify's headless architecture provides flexibility for different frontend implementations (web, API, SPA) while maintaining consistent backend logic
- Using a well-maintained library reduces security vulnerabilities compared to custom authentication implementations and benefits from community security audits

## Consequences

Positive:
- Consistent input validation across all authentication flows reduces security vulnerabilities
- Centralized authentication logic in Fortify Actions improves maintainability and reduces code duplication
- Separation of authentication logic from presentation enables flexible frontend implementations
- Leveraging a well-tested library reduces the risk of authentication-related bugs and security issues

Negative:
- Introduces dependency on Laravel Fortify package, requiring team familiarity with its conventions
- Customizing authentication flows requires understanding Fortify's action-based architecture
- Migration from existing custom authentication systems requires refactoring effort
- Framework coupling makes it harder to migrate to non-Laravel platforms in the future

## Alternatives

- Custom authentication implementation with manual validation (rejected)
  Rejected because: Increases security risk, requires more maintenance effort, and leads to inconsistent validation patterns across the codebase
  When valid: Only for highly specialized authentication requirements that cannot be met by Fortify
- Laravel Breeze or Jetstream (full-stack authentication scaffolding) (rejected)
  Rejected because: These packages include frontend scaffolding which may not align with custom frontend requirements; Fortify provides backend-only flexibility
  When valid: When rapid prototyping with standard UI is acceptable
- Third-party authentication service (Auth0, Firebase Auth) (deferred)
  Rejected because: Not rejected but deferred; may be considered for specific use cases requiring advanced features
  When valid: When advanced features like adaptive authentication, extensive SSO integrations, or managed infrastructure are required

## Risks

- Team unfamiliarity with Fortify's action-based architecture may lead to incorrect implementations
  Mitigation: Provide team training on Fortify patterns, create internal documentation with examples, and establish code review guidelines for authentication changes
  Owner: Engineering team lead
- Fortify package vulnerabilities could impact application security
  Mitigation: Implement automated dependency scanning, subscribe to Laravel security advisories, and maintain regular package updates
  Owner: Security team
- Over-customization of Fortify Actions may negate benefits of using a standard library
  Mitigation: Establish guidelines for when customization is appropriate, prefer configuration over customization, and review custom implementations during architecture reviews
  Owner: Architecture team

## Implementation Notes

- Register all custom Fortify Actions in app/Providers/FortifyServiceProvider.php using Fortify::createUsersUsing() and similar methods
- Place custom Fortify Action classes in app/Actions/Fortify/ directory following Laravel conventions
- Use Laravel's Validator facade or Form Request validation within Action classes to validate input before processing
- Ensure all validation rules are comprehensive and include sanitization for XSS prevention (e.g., strip_tags, htmlspecialchars where appropriate)
- Test authentication flows thoroughly including edge cases and malicious input scenarios

## Continuation Context


Verify commands:
- grep -r "use Laravel\\\\Fortify" app/Actions/ app/Providers/ | wc -l
- grep -r "Validator::make\|validate(" app/Actions/Fortify/ | wc -l
- test -f app/Providers/FortifyServiceProvider.php && echo 'FortifyServiceProvider exists' || echo 'MISSING'
- php artisan route:list | grep -E '(login|register|password)' | grep -c fortify

Accept when:
- All authentication-related Actions use Laravel Fortify imports and are registered in FortifyServiceProvider
- Each Fortify Action contains explicit validation logic using Laravel's validation mechanisms
- Fortify routes are registered and accessible in the application routing table
- No duplicate authentication logic exists outside of Fortify Actions

## Enforcement

- Verified by: Automated static analysis scanning for authentication patterns outside Fortify Actions
- Verified by: Code review checklist requiring Fortify usage for all authentication changes
- Verified by: CI pipeline checks for presence of validation in all Fortify Action classes
- Verified by: Security audit reviews of authentication implementations
- Violation handling: CI pipeline fails if authentication logic is detected outside approved Fortify Action locations
- Violation handling: Code review blocks merge requests that bypass Fortify for authentication operations
- Violation handling: Security team notified of violations for assessment of security impact
- Violation handling: Violations must be remediated before deployment to production
- Exception process: Submit exception request to architecture team with justification and security assessment
- Exception process: Security team review required for all authentication-related exceptions
- Exception process: Document approved exceptions in project architecture documentation
- Exception process: Set expiration date for temporary exceptions with required migration plan
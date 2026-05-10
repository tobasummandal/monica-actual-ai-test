# Adopt Laravel Fortify for Authentication Action Standardization: Authentication Actions Password

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application requires standardized authentication and user management operations across multiple domains including account creation, password management, and invitation handling
- Laravel Fortify provides a headless authentication backend that separates authentication logic from presentation concerns, enabling consistent behavior across web and API interfaces
- The codebase exhibits a pattern of implementing authentication actions through dedicated service classes and Fortify action classes, indicating a deliberate architectural choice for deployment flexibility
- Authentication operations span multiple bounded contexts (Settings/CreateAccount, Settings/CancelAccount, Settings/ManageUsers) requiring a unified approach to password validation and user state management
- The facet 'api.public.contracts' suggests these authentication patterns are exposed through public API contracts, necessitating stable and well-defined interfaces

## Problem Statement

How should authentication operations be structured and deployed to ensure consistency across multiple application domains while maintaining flexibility for both web and API deployment targets, and how can we standardize password management, user lifecycle operations, and invitation workflows without coupling them to specific presentation layers?

## Decision

1. MUST: All authentication actions (password reset, password update, user creation) MUST be implemented as Laravel Fortify action classes in the app/Actions/Fortify namespace

## Policy Block

- MUST All authentication actions (password reset, password update, user creation) MUST be implemented as Laravel Fortify action classes in the app/Actions/Fortify namespace

In scope:
- All password management operations (reset, update, validation)
- User account lifecycle operations (creation, cancellation, invitation acceptance)
- Authentication action classes in app/Actions/Fortify
- Domain service classes handling user management in app/Domains/Settings
- Feature tests validating authentication behavior

Out of scope:
- Frontend authentication UI components
- Session management and cookie handling
- OAuth and social authentication providers
- Authorization and permission logic
- API token generation and management

## Rationale

- The pattern appears across 6 files with 81.27% confidence, indicating a consistent architectural approach to authentication that has been deliberately adopted across multiple domains
- Laravel Fortify's headless design aligns with the deployment target category by decoupling authentication logic from specific runtime environments, enabling the same codebase to serve web, API, and mobile clients
- Separating domain services (CreateAccount, AcceptInvitation) from Fortify actions (ResetUserPassword, UpdateUserPassword) provides clear boundaries between framework-level authentication concerns and business domain logic
- The presence of feature tests alongside action classes demonstrates a commitment to deployment-agnostic testing that validates behavior independent of the target environment

## Consequences

Positive:
- Authentication logic can be deployed to multiple targets (web, API, mobile) without modification, reducing code duplication and maintenance burden
- Clear separation between authentication mechanics and presentation layer enables independent evolution of frontend and backend components
- Standardized password handling through Laravel's Hash facade ensures consistent security posture across all deployment environments
- Domain service classes provide clear extension points for business-specific authentication workflows while maintaining framework-level consistency

Negative:
- Additional abstraction layer (Fortify actions + domain services) increases initial complexity for developers unfamiliar with the pattern
- Potential for confusion about when to use Fortify actions versus domain services, requiring clear documentation and team alignment
- Testing requires understanding of both Fortify's testing patterns and domain service testing approaches
- Migration of existing authentication code to this pattern requires significant refactoring effort

## Alternatives

- Implement authentication logic directly in controllers without Fortify abstraction (rejected)
  Rejected because: Couples authentication logic to specific deployment targets (web controllers), making it difficult to support API and mobile clients without code duplication. Violates separation of concerns and reduces testability.
  When valid: For simple applications with a single deployment target and no plans for API or mobile support
- Use Laravel Breeze or Jetstream starter kits with built-in authentication scaffolding (rejected)
  Rejected because: Starter kits provide opinionated UI implementations that couple authentication to specific frontend technologies. The detected pattern suggests a need for deployment target flexibility that starter kits don't provide.
  When valid: For rapid prototyping or applications where the provided UI patterns are acceptable and deployment target flexibility is not required
- Build custom authentication system without framework dependencies (rejected)
  Rejected because: Reinventing authentication increases security risk, development time, and maintenance burden. Laravel Fortify provides battle-tested implementations that have been audited by the community.
  When valid: For applications with highly specialized authentication requirements that cannot be met by existing frameworks

## Risks

- Inconsistent application of the pattern across teams leading to mixed authentication approaches in different domains
  Mitigation: Establish clear architectural guidelines, provide code examples and templates, implement automated linting to detect non-compliant authentication implementations
  Owner: Engineering team leads
- Fortify framework updates may introduce breaking changes requiring significant refactoring across multiple action classes
  Mitigation: Pin Fortify version in composer.json, establish comprehensive test coverage for all authentication flows, review Fortify changelogs before upgrading
  Owner: Platform engineering team
- Performance overhead from additional abstraction layers in high-traffic authentication endpoints
  Mitigation: Implement caching strategies for user lookups, monitor authentication endpoint performance, optimize database queries in domain services
  Owner: Performance engineering team

## Implementation Notes

- Create Fortify action classes by extending the appropriate Fortify contracts (ResetUserPassword, UpdateUserPassword) and registering them in FortifyServiceProvider
- Domain services should be placed in app/Domains/{DomainName}/Services and follow single-responsibility principle, handling one user lifecycle operation per service
- Use Laravel's validation rules for password requirements (min:8, confirmed, etc.) consistently across all authentication actions
- Feature tests should use Laravel's authentication testing helpers (actingAs, assertAuthenticated) and test both success and failure scenarios
- Document the decision boundary between Fortify actions (framework-level authentication) and domain services (business-specific user management) in team guidelines

## Continuation Context


Verify commands:
- grep -r "extends.*Fortify" app/Actions/Fortify/ | wc -l
- find app/Domains -name "*Service.php" -path "*/Services/*" | wc -l
- grep -r "use Illuminate\\Support\\Facades\\Hash" app/Actions/Fortify app/Domains/Settings | wc -l
- php artisan test --filter=Auth --filter=Password --filter=Account

Accept when:
- All authentication actions in app/Actions/Fortify extend appropriate Fortify contracts and are registered in FortifyServiceProvider
- Domain-specific user management services exist in app/Domains/*/Services and delegate to Fortify actions for password operations
- Feature tests for authentication operations pass and cover both web and API scenarios without presentation layer dependencies
- Password validation uses Laravel Hash facade consistently across all authentication touchpoints

## Enforcement

- Verified by: Automated CI pipeline checks for presence of Fortify action classes and domain services
- Verified by: Code review checklist requiring verification of authentication pattern compliance
- Verified by: Static analysis tools (PHPStan, Psalm) configured to detect direct password hashing without Hash facade
- Verified by: Architecture decision record review during sprint planning for new authentication features
- Violation handling: CI pipeline fails if authentication logic is detected in controllers without corresponding Fortify action or domain service
- Violation handling: Pull requests containing authentication changes require architecture team approval
- Violation handling: Quarterly architecture audits identify and flag non-compliant authentication implementations for refactoring
- Violation handling: New authentication features must include ADR compliance documentation
- Exception process: Submit exception request to architecture review board with justification for deviation from standard pattern
- Exception process: Document exception rationale in code comments with reference to approval ticket
- Exception process: Exceptions are time-limited (6-12 months) and require re-approval or migration to standard pattern
- Exception process: All exceptions are tracked in architecture decision log and reviewed quarterly
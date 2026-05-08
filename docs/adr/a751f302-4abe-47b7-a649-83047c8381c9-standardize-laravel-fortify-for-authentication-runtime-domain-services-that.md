# Standardize Laravel Fortify for Authentication Runtime: Domain Services That

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application uses Laravel Fortify as the core authentication library across multiple domains including account management, user invitations, and password operations
- Authentication operations are distributed across domain-driven design boundaries (Settings/CreateAccount, Settings/CancelAccount, Settings/ManageUsers) and centralized Fortify actions
- The pattern signature cd72d27011f404d969eb8ec53b7d9b45 was detected in 6 files with 81.27% confidence, indicating consistent authentication runtime behavior
- Core library detection (libs.core.detected facet) reveals a standardized approach to authentication that spans both application services and test infrastructure
- The deployment target requires a consistent authentication runtime that can handle password resets, updates, account creation, cancellation, and invitation acceptance

## Problem Statement

The application requires a consistent, secure, and maintainable authentication runtime that can support complex multi-tenant account operations, password management, and user lifecycle events across domain boundaries without creating tight coupling or duplicating authentication logic.

## Decision

1. MUST: Domain services that require authentication operations MUST delegate to Fortify actions rather than implementing authentication logic directly

## Policy Block

- MUST Domain services that require authentication operations MUST delegate to Fortify actions rather than implementing authentication logic directly

In scope:
- All password management operations (reset, update, change)
- User authentication actions and contracts
- Account creation flows that involve credential setup
- Invitation acceptance flows that establish user authentication
- Feature tests validating authentication behavior

Out of scope:
- Authorization and permission logic (handled by separate authorization layer)
- Session management beyond Fortify's scope
- OAuth and social authentication providers (unless integrated through Fortify)
- API token management (unless using Fortify Sanctum integration)
- Business logic unrelated to authentication credentials

Exceptions:
- EXC-001: Legacy authentication systems during migration period
- EXC-002: Testing scenarios requiring mock authentication without full Fortify stack

## Rationale

- Laravel Fortify provides a battle-tested, framework-integrated authentication runtime that reduces security vulnerabilities and maintenance burden
- The detection of this pattern across 6 files with 81.27% confidence indicates successful adoption and consistency in authentication approach
- Centralizing authentication through Fortify actions creates a clear separation between domain business logic and authentication concerns, supporting domain-driven design principles
- Using a standardized authentication runtime ensures consistent security practices across password operations, account management, and user lifecycle events

## Consequences

Positive:
- Consistent authentication behavior across all application domains and boundaries
- Reduced security risk through use of framework-maintained authentication library
- Simplified testing with Fortify's built-in test helpers and contracts
- Clear separation of concerns between domain logic and authentication runtime
- Easier onboarding for developers familiar with Laravel ecosystem

Negative:
- Tight coupling to Laravel Fortify makes migration to alternative authentication systems more difficult
- Framework dependency increases complexity if custom authentication flows are needed
- Fortify's opinionated structure may not fit all authentication use cases
- Additional abstraction layer needed if authentication logic must be shared with non-Laravel components

## Alternatives

- Implement custom authentication service layer without framework dependency (rejected)
  Rejected because: Would require significant security expertise, increase maintenance burden, and duplicate well-tested authentication logic already provided by Fortify
  When valid: Only valid for applications with highly specialized authentication requirements that cannot be met by any existing framework
- Use Laravel Breeze or Jetstream instead of Fortify directly (rejected)
  Rejected because: Breeze and Jetstream are starter kits that include UI scaffolding; Fortify provides the headless authentication backend needed for domain-driven architecture
  When valid: Valid for rapid prototyping or applications that align with opinionated UI patterns
- Mix Fortify with custom authentication handlers for specific domains (rejected)
  Rejected because: Creates inconsistent authentication behavior, increases security risk, and complicates testing and maintenance
  When valid: Only during migration periods with explicit architectural approval and documented timeline

## Risks

- Fortify version updates may introduce breaking changes to authentication behavior
  Mitigation: Maintain comprehensive feature test coverage for all authentication flows; review Fortify changelog before upgrades; use semantic versioning constraints
  Owner: Engineering team
- Domain services may bypass Fortify and implement custom authentication logic
  Mitigation: Enforce through code review, static analysis to detect direct password hashing, and architectural documentation
  Owner: Architecture team
- Fortify may not support future authentication requirements (e.g., passwordless, biometric)
  Mitigation: Monitor Fortify roadmap; evaluate Fortify extensibility for new requirements; maintain abstraction layer in domain services
  Owner: Engineering team

## Implementation Notes

- Register all Fortify actions in the FortifyServiceProvider, mapping them to application-specific implementations in app/Actions/Fortify
- Domain services should inject Fortify action contracts rather than calling Fortify facades directly to maintain testability
- Use Fortify's validation rules and password validation configuration in config/fortify.php for consistent password policies
- Feature tests should use Fortify's test helpers and verify authentication state changes rather than testing Fortify internals

## Continuation Context


Verify commands:
- grep -r 'Hash::make\|Hash::check' app/Domains --exclude-dir=vendor | grep -v 'Fortify' || echo 'No direct password hashing found'
- grep -r 'use Laravel\\Fortify' app/Actions/Fortify | wc -l
- php artisan test --filter=Auth --filter=Password --filter=Account

Accept when:
- No direct password hashing or authentication logic found in domain services outside Fortify actions
- All authentication actions are registered in FortifyServiceProvider and located in app/Actions/Fortify namespace
- Feature tests for authentication flows pass and verify Fortify integration

## Enforcement

- Verified by: Automated static analysis scanning for direct password hashing in domain code
- Verified by: Code review checklist requiring Fortify action usage for authentication operations
- Verified by: CI pipeline running authentication feature tests on every commit
- Violation handling: CI build fails if direct password hashing detected outside Fortify actions
- Violation handling: Code review blocks merge if authentication logic bypasses Fortify
- Violation handling: Architecture review required for any new authentication patterns
- Exception process: Submit exception request to architecture team with justification and migration timeline
- Exception process: Document exception in ADR amendments with approval signatures
- Exception process: Schedule review of exception after 6 months to evaluate if still necessary
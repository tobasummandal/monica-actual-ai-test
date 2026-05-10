# Standardize Password Hashing for Authentication Operations: Password Update Operations

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application handles sensitive user authentication data including password creation, updates, and resets across multiple domains (Settings, Fortify actions)
- Password security operations are distributed across account creation, invitation acceptance, password updates, and password reset workflows
- The codebase uses Laravel Fortify for authentication scaffolding, requiring consistent password handling patterns across custom and framework-provided actions
- Multiple service classes and action handlers need to implement password hashing in a uniform manner to ensure security consistency
- The pattern appears in both domain services (CreateAccount, AcceptInvitation) and Fortify action classes (ResetUserPassword, UpdateUserPassword), indicating a cross-cutting security concern

## Problem Statement

Without a standardized approach to password hashing across authentication operations, the application risks inconsistent security implementations, potential vulnerabilities from manual hashing implementations, and difficulty maintaining uniform security standards as the authentication surface area grows across multiple domains and action handlers.

## Decision

1. MUST: Password update operations (reset, change, initial creation) MUST apply the same hashing strategy consistently

## Policy Block

- MUST Password update operations (reset, change, initial creation) MUST apply the same hashing strategy consistently

In scope:
- Account creation workflows (new user registration)
- Password reset operations (forgotten password flows)
- Password update operations (authenticated user password changes)
- Invitation acceptance flows that set initial passwords
- All Fortify action handlers dealing with password operations
- Domain service classes that create or modify user credentials

Out of scope:
- API token generation and management
- OAuth or third-party authentication flows that don't store passwords
- Session management and cookie handling
- Two-factor authentication token handling
- Password reset token generation (tokens themselves, not the new password)

## Rationale

- The pattern signature (94967224950efe6ab90490e925ef2951) appears consistently across 5 authentication-related files with 81.88% confidence, indicating a deliberate architectural pattern
- Password hashing is a critical security requirement that must be applied uniformly across all authentication entry points to prevent credential compromise
- Laravel provides robust, battle-tested hashing mechanisms through the Hash facade that automatically handle salting, cost factors, and algorithm selection
- Centralizing password hashing patterns reduces the risk of developer error when implementing new authentication features or modifying existing ones

## Consequences

Positive:
- Consistent security posture across all authentication workflows reduces vulnerability surface area
- Leveraging Laravel's Hash facade ensures automatic algorithm updates and security patches through framework upgrades
- Clear patterns make code reviews more effective by establishing expected security implementations
- Reduced cognitive load for developers implementing new authentication features

Negative:
- Bcrypt hashing adds computational overhead to authentication operations, though this is intentional for security
- Tight coupling to Laravel's hashing implementation may complicate future migrations to alternative frameworks
- Developers must remember to apply hashing in all new authentication code paths, creating potential for human error
- Testing password-related functionality requires understanding of hash verification patterns

## Alternatives

- Use database-level encryption for password columns instead of application-level hashing (rejected)
  Rejected because: Database encryption protects data at rest but doesn't provide the one-way hashing required for secure password verification; passwords must be hashed, not encrypted
  When valid: Never valid for password storage; encryption is reversible while hashing must be one-way
- Implement custom password hashing with manual salt generation and algorithm selection (rejected)
  Rejected because: Custom cryptographic implementations are error-prone and difficult to maintain; Laravel's Hash facade provides industry-standard implementations with automatic security updates
  When valid: Only when specific compliance requirements mandate custom cryptographic implementations with certified libraries
- Delegate all password handling to external identity providers (Auth0, Okta, etc.) (deferred)
  When valid: Valid for applications that can fully externalize authentication; requires significant architectural changes and may not meet all business requirements for self-hosted authentication

## Risks

- Developers may forget to hash passwords in new authentication code paths, leading to plain-text password storage
  Mitigation: Implement automated tests that verify password hashing in all authentication workflows; add code review checklist items for authentication changes; consider database constraints or model observers to detect unhashed passwords
  Owner: Engineering team (security review)
- Legacy code or database migrations may contain unhashed passwords that need remediation
  Mitigation: Audit existing user records for unhashed passwords; implement one-time migration to force password resets for affected accounts; add monitoring to detect password patterns that suggest unhashed storage
  Owner: Engineering team (data security)
- Insufficient bcrypt cost factor may become inadequate as computing power increases
  Mitigation: Periodically review and update bcrypt cost factor in configuration; implement gradual rehashing on user login to upgrade existing hashes; monitor authentication performance to balance security and user experience
  Owner: Engineering team (security architecture)

## Implementation Notes

- Use Hash::make($password) for all password hashing operations; configure cost factor in config/hashing.php
- In Fortify action classes (ResetUserPassword, UpdateUserPassword), ensure password hashing occurs before calling $user->forceFill(['password' => ...])->save()
- In domain service classes (CreateAccount, AcceptInvitation), apply hashing before user model creation or password updates
- Feature tests should use Hash::check($plainPassword, $user->password) to verify hashing occurred correctly
- Consider using Laravel's validation rule 'Password::min(8)->mixedCase()->numbers()' to enforce password complexity before hashing

## Continuation Context


Verify commands:
- grep -r "'password'\s*=>\s*\$" app/ --include='*.php' | grep -v 'Hash::make' | grep -v 'bcrypt(' | grep -v '// ' || echo 'No unhashed password assignments found'
- grep -r "Hash::make\|bcrypt(" app/Actions/Fortify/ app/Domains/Settings/ --include='*.php' | wc -l
- php artisan test --filter=Password --coverage-text | grep -E '(UpdatePasswordTest|ResetPasswordTest)'

Accept when:
- All password assignment operations in authentication code paths use Hash::make() or bcrypt() helper
- Feature tests verify that stored passwords are hashed (Hash::check returns true for original password)
- Code review checklist includes verification of password hashing for any authentication-related changes

## Enforcement

- Verified by: Automated feature tests that verify password hashing in UpdatePasswordTest and similar test classes
- Verified by: Code review process with security-focused checklist for authentication changes
- Verified by: Static analysis using grep patterns in CI pipeline to detect potential unhashed password assignments
- Violation handling: CI pipeline fails if grep patterns detect potential unhashed password assignments
- Violation handling: Code review blocks merge if password hashing is not verified in authentication code
- Violation handling: Security audit flags any user records with passwords that don't match bcrypt hash format
- Exception process: No exceptions permitted for production authentication code; password hashing is a non-negotiable security requirement
- Exception process: Test fixtures and seeding may use simplified hashing with documented security warnings
- Exception process: Any deviation requires security team approval and must be documented in ADR amendment
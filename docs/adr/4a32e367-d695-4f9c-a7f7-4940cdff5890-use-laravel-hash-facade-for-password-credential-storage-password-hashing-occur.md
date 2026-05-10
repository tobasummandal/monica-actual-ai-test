# Use Laravel Hash Facade for Password Credential Storage: Password Hashing Occur

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application handles user authentication and password management across multiple domains including account creation, user invitations, and password updates
- Password security is a critical concern requiring consistent cryptographic hashing across all authentication flows
- Laravel provides the Hash facade as a framework-standard abstraction over bcrypt/argon2 password hashing algorithms
- Multiple services and actions (CreateAccount, AcceptInvitation, ResetUserPassword, UpdateUserPassword) require password hashing functionality
- The deployment target environment must support PHP's password hashing extensions and Laravel's Hash facade configuration

## Problem Statement

The application needs a consistent, secure, and maintainable approach to storing user password credentials across multiple authentication workflows. Without a standardized credential storage mechanism, the system risks inconsistent security implementations, algorithm drift, and increased maintenance burden when security requirements evolve.

## Decision

1. MUST: Password hashing MUST occur in service layer classes or Fortify action classes, never in controllers or views

## Policy Block

- MUST Password hashing MUST occur in service layer classes or Fortify action classes, never in controllers or views

In scope:
- All user account creation workflows
- Password reset and recovery flows
- Password update and change operations
- User invitation acceptance with password setting
- Any authentication action that stores or verifies passwords

Out of scope:
- API token generation and storage (uses different hashing strategy)
- OAuth provider tokens (managed by external providers)
- Session identifiers (use different security mechanisms)
- Remember me tokens (may use different hashing approach)
- Password reset tokens (temporary, different security model)

Exceptions:
- EXC-001: Testing environments require deterministic password hashes for fixture data
- EXC-002: Migration from legacy system requires temporary dual-hash verification

## Rationale

- Pattern detected across 5 files with 81.88% confidence, indicating consistent implementation of Hash facade usage in authentication workflows
- Laravel's Hash facade provides a stable API abstraction that allows algorithm upgrades without code changes throughout the application
- Centralizing password hashing through a framework-provided facade ensures security best practices are maintained by framework maintainers
- The facet 'authn.credential_storage' directly maps to this pattern, confirming this is the standard approach for credential management in the codebase

## Consequences

Positive:
- Consistent password security implementation across all authentication workflows reduces risk of security vulnerabilities
- Framework-managed hashing algorithms receive automatic security updates through Laravel upgrades
- Simplified code maintenance as hashing logic is centralized through a single facade interface
- Easy to test password functionality using Hash::fake() in test environments

Negative:
- Tight coupling to Laravel framework makes migration to other frameworks more complex
- Hash facade configuration changes require careful coordination across all environments
- Performance characteristics are abstracted away, making optimization more difficult without framework knowledge
- Developers must understand Laravel's hashing conventions rather than using standard PHP password functions directly

## Alternatives

- Use PHP's native password_hash() and password_verify() functions directly (rejected)
  Rejected because: Lacks framework integration, requires manual algorithm management, and doesn't provide testing utilities like Hash::fake()
  When valid: Valid for non-Laravel PHP applications or when framework independence is a hard requirement
- Implement custom password hashing service with dependency injection (rejected)
  Rejected because: Reinvents functionality already provided by framework, increases maintenance burden, and introduces potential security risks from custom implementation
  When valid: Valid when requiring specialized hashing algorithms not supported by Laravel or when implementing custom security requirements
- Use database-level encryption for password storage (rejected)
  Rejected because: Database encryption is reversible and doesn't provide the one-way hashing required for password security best practices
  When valid: Never valid for password storage; only appropriate for data that must be decrypted

## Risks

- Hash facade configuration mismatch between environments could cause authentication failures
  Mitigation: Standardize config/hashing.php across all environments and include in deployment verification checks
  Owner: DevOps team
- Developers might accidentally log or expose hashed passwords, creating unnecessary security surface
  Mitigation: Implement code review checklist items for password handling and use static analysis to detect password field logging
  Owner: Security team
- Legacy code or new developers might bypass Hash facade and use insecure storage methods
  Mitigation: Implement automated code scanning for direct password_hash usage or plain-text password storage patterns
  Owner: Engineering team

## Implementation Notes

- Always use Hash::make($password) when storing passwords, typically in service classes like CreateAccount or AcceptInvitation
- Use Hash::check($plaintext, $hashedValue) for password verification during authentication
- In tests, use Hash::fake() to avoid expensive hashing operations and speed up test execution
- Review config/hashing.php to ensure appropriate algorithm (bcrypt or argon2id) and work factor for your security requirements
- Consider implementing password rehashing on successful login to automatically upgrade legacy hashes when algorithm configuration changes

## Continuation Context


Verify commands:
- grep -r "Hash::make" app/ --include="*.php" | wc -l
- grep -r "password_hash" app/ --include="*.php" || echo "No direct password_hash usage found (good)"
- grep -r "'password'.*=>.*\$" app/ --include="*.php" | grep -v "Hash::make" | grep -v "bcrypt" || echo "No plain-text password assignments found (good)"
- php artisan tinker --execute="echo config('hashing.driver');"

Accept when:
- All password storage operations use Hash::make() as verified by grep showing consistent usage across authentication files
- No direct password_hash() calls found in application code (framework usage only)
- Hash facade configuration is properly set in config/hashing.php with bcrypt or argon2id driver
- Test suite includes verification that passwords are hashed before database storage

## Enforcement

- Verified by: Automated code review checks scanning for Hash::make usage in password-related code
- Verified by: Static analysis tools detecting plain-text password storage patterns
- Verified by: CI pipeline verification commands checking for proper Hash facade usage
- Verified by: Manual code review checklist items for authentication-related pull requests
- Violation handling: CI pipeline fails if plain-text password storage patterns are detected
- Violation handling: Pull requests blocked until Hash facade usage is corrected
- Violation handling: Security team notification for violations in production code
- Violation handling: Mandatory security review for any code bypassing Hash facade
- Exception process: Developer submits exception request with technical justification to security team
- Exception process: Security team reviews and approves/rejects within 2 business days
- Exception process: Approved exceptions documented in ADR exceptions section with sunset date
- Exception process: Exceptions reviewed quarterly and removed when no longer needed
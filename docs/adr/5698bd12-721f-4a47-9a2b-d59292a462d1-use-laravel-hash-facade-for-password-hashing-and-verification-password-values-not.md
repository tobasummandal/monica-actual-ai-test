# Use Laravel Hash Facade for Password Hashing and Verification: Password Values Not

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- Laravel Fortify authentication actions require secure password storage and verification mechanisms for user credential management
- Password update and reset operations must validate current credentials before allowing changes to prevent unauthorized access
- The application uses Laravel's Hash facade which provides bcrypt-based hashing with automatic salt generation and secure comparison
- Two authentication action classes (UpdateUserPassword and ResetUserPassword) implement password management contracts from Laravel Fortify

## Problem Statement

Authentication systems must store user passwords securely to prevent credential theft in the event of database compromise, while also providing constant-time comparison operations to prevent timing attacks during credential verification. Direct password storage or weak hashing algorithms expose user credentials to attackers.

## Decision

1. MUST_NOT: Password values MUST_NOT be stored in plaintext or using reversible encryption in the database

## Policy Block

- MUST_NOT Password values MUST_NOT be stored in plaintext or using reversible encryption in the database

In scope:
- All Laravel Fortify authentication action classes (UpdateUserPassword, ResetUserPassword)
- User model password attribute updates
- Password reset and password change workflows
- Any custom authentication logic that handles user credentials

Out of scope:
- API token generation and storage
- OAuth provider integration
- Session management
- Two-factor authentication codes

## Rationale

- The IR evidence shows consistent use of Hash::make() for password storage and Hash::check() for verification across both UpdateUserPassword and ResetUserPassword classes
- Laravel's Hash facade provides bcrypt hashing with automatic work factor configuration and constant-time comparison to prevent timing attacks
- The pattern appears in authentication-critical code paths (password update and reset) where security requirements are highest
- Using a framework-provided facade ensures consistent hashing configuration and simplifies future algorithm upgrades

## Consequences

Positive:
- Passwords are protected by bcrypt hashing with automatic salt generation, making rainbow table attacks infeasible
- Constant-time comparison via Hash::check() prevents timing attacks during authentication
- Centralized hashing configuration through Laravel's Hash facade simplifies algorithm upgrades and work factor tuning
- Integration with Laravel Fortify contracts ensures compatibility with the framework's authentication ecosystem

Negative:
- Bcrypt hashing adds computational overhead to authentication operations, though this is intentional for security
- Tight coupling to Laravel's Hash facade makes migration to other frameworks more complex
- Work factor configuration is global rather than per-operation, limiting fine-grained performance tuning
- Password verification requires database retrieval of the hash before comparison can occur

## Alternatives

- Use PHP's native password_hash() and password_verify() functions directly (rejected)
  Rejected because: Laravel's Hash facade provides consistent configuration, testing support, and framework integration that native PHP functions lack. The facade also simplifies future algorithm changes.
  When valid: In non-Laravel PHP applications where framework integration is not required
- Implement custom password hashing using Argon2id algorithm (rejected)
  Rejected because: While Argon2id offers memory-hardness advantages, bcrypt remains the Laravel default and is sufficient for most applications. Custom implementation increases maintenance burden.
  When valid: For high-security applications requiring memory-hard hashing or when explicitly configured in Laravel's hashing configuration
- Store passwords using reversible encryption for account recovery (rejected)
  Rejected because: Reversible encryption exposes passwords to theft if encryption keys are compromised. Password reset flows eliminate the need for password recovery.
  When valid: Never valid for user authentication credentials

## Risks

- Bcrypt work factor may become insufficient as computing power increases, weakening password protection over time
  Mitigation: Periodically review and increase bcrypt work factor in config/hashing.php. Implement password rehashing on successful login to upgrade existing hashes.
  Owner: Security team
- Developers may bypass Hash facade and store plaintext passwords in custom authentication code
  Mitigation: Implement static analysis rules to detect password field assignments without Hash::make(). Enforce code review requirements for authentication-related changes.
  Owner: Engineering team
- Hash::check() timing may still leak information about password length or hash validity in edge cases
  Mitigation: Ensure Laravel framework is kept up-to-date to receive timing attack mitigations. Monitor security advisories for Hash facade vulnerabilities.
  Owner: Security team

## Implementation Notes

- Always use Hash::make($password) when assigning to the user password field, never assign plaintext values
- Use Hash::check($plaintext, $hash) for password verification in authentication flows, never use direct string comparison
- Leverage forceFill() when updating password fields to bypass mass assignment protection: $user->forceFill(['password' => Hash::make($input['password'])])->save()
- Configure bcrypt work factor in config/hashing.php based on acceptable authentication latency (default is 10 rounds)

## Continuation Context


Verify commands:
- grep -r "Hash::make" app/Actions/Fortify/ | grep -c password
- grep -r "Hash::check" app/Actions/Fortify/ | grep -c password
- grep -r "'password'\s*=>\s*\$" app/ | grep -v Hash::make || echo 'No plaintext password assignments found'

Accept when:
- All password storage operations in Fortify action classes use Hash::make()
- All password verification operations use Hash::check() with constant-time comparison
- No plaintext password assignments exist in authentication code paths

## Enforcement

- Verified by: Static analysis scanning for password field assignments without Hash::make()
- Verified by: Code review checklist for authentication-related pull requests
- Verified by: Automated grep-based verification in CI pipeline
- Violation handling: CI pipeline fails if plaintext password assignments are detected
- Violation handling: Security team review required for any authentication code changes
- Violation handling: Immediate remediation required for violations discovered in production code
- Exception process: No exceptions permitted for user authentication password storage
- Exception process: Alternative hashing algorithms (Argon2id) may be approved via security team review
- Exception process: Test fixtures may use Hash::make() with reduced work factor for performance
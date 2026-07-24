# Validate User Input with Laravel Validator Before Data Access Operations: Services Throw Modelnotfoundexception

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase uses Laravel Fortify for authentication and user profile management, requiring secure handling of user credentials and profile data
- User input arrives as array parameters in Action classes (UpdateUserProfileInformation, UpdateUserPassword, ResetUserPassword) and Service classes (SynchronizeAddressBook) before database operations
- Data access operations use Eloquent ORM methods (save, forceFill, findOrFail) that persist data directly to the database without built-in input validation
- The application implements a service-oriented architecture with BaseService providing validateRules() method and custom validation logic in domain services
- Security requirements mandate validation of email uniqueness, password strength, string length constraints, and account ownership before data persistence

## Problem Statement

Without systematic input validation before data access operations, the application risks persisting malformed, malicious, or unauthorized data that could compromise data integrity, violate business rules, or create security vulnerabilities including SQL injection, mass assignment exploits, and unauthorized data modification.

## Decision

1. MAY: Services MAY throw ModelNotFoundException when cross-account validation fails to distinguish authorization failures from missing resources

## Policy Block

- MAY Services MAY throw ModelNotFoundException when cross-account validation fails to distinguish authorization failures from missing resources

In scope:
- All Laravel Fortify Action classes implementing UpdatesUserProfileInformation, UpdatesUserPasswords, ResetsUserPasswords contracts
- All Service classes extending BaseService that accept user input arrays and perform database operations
- All methods receiving array $input or array $data parameters that precede Eloquent save(), forceFill(), update(), or create() calls
- All user-facing endpoints handling profile updates, password changes, and account management operations

Out of scope:
- Internal system operations where input originates from trusted sources (migrations, seeders, system jobs)
- Read-only data access operations that do not modify database state
- Validation of request objects already validated by FormRequest classes before reaching Action or Service layers
- Third-party package code outside the App namespace

Exceptions:
- EXC-001: Batch import operations from verified administrative sources where pre-validation occurs in a separate validation service
- EXC-002: System-generated data updates triggered by internal events where input is programmatically constructed and type-safe

## Rationale

- Evidence shows consistent pattern across 4 files where Validator::make() precedes all data persistence operations, establishing validation as a security boundary before database access
- The pattern prevents common vulnerabilities by enforcing type safety, length limits, and business rules (email uniqueness, password strength) at the application layer before ORM operations
- Laravel Fortify contract implementations demonstrate framework-level expectation that validation occurs within Action classes before user model updates
- BaseService validateRules() pattern in domain services extends validation beyond framework contracts to custom business logic, ensuring consistent security posture across architectural layers

## Consequences

Positive:
- Prevents malformed data persistence by catching validation errors before database operations, maintaining data integrity
- Mitigates mass assignment vulnerabilities by explicitly validating allowed fields before forceFill() operations
- Provides consistent error messages through validateWithBag() namespacing, improving user experience and debugging
- Establishes clear security boundary between untrusted user input and trusted database operations, reducing attack surface

Negative:
- Increases code verbosity with validation boilerplate in every Action and Service class that handles user input
- Creates potential for validation logic duplication across similar operations if not properly abstracted
- Adds runtime overhead for validation execution on every request, though typically negligible compared to database operations
- Requires developers to maintain validation rules in sync with database schema constraints and business rules

## Alternatives

- Use Laravel FormRequest validation at the controller layer instead of Action/Service layer validation (rejected)
  Rejected because: Fortify Action classes bypass controllers and receive input directly; FormRequest validation would not protect these code paths. Service layer validation is necessary for domain logic enforcement beyond HTTP request validation.
  When valid: For traditional controller-based architectures where all user input flows through controllers and FormRequest classes
- Rely on database constraints (NOT NULL, UNIQUE, CHECK) for validation instead of application-layer validation (rejected)
  Rejected because: Database constraint violations produce generic error messages unsuitable for user-facing applications and occur after application logic has executed, potentially causing side effects. Application-layer validation provides better error messages and fails fast.
  When valid: As a defense-in-depth measure in addition to application validation, not as a replacement
- Implement validation as Eloquent model events (creating, updating) using observers (rejected)
  Rejected because: Model events occur too late in the execution flow, after business logic has run. Evidence shows validation must occur before any model manipulation to prevent unauthorized operations and maintain clear separation between validation and persistence concerns.
  When valid: For cross-cutting validation concerns that apply regardless of how models are created or updated, as a supplementary validation layer

## Risks

- Validation rules may drift out of sync with database schema changes, allowing invalid data to pass validation but fail at database level
  Mitigation: Implement integration tests that verify validation rules against actual database constraints; use schema inspection in CI to detect mismatches
  Owner: Engineering team
- Complex validation logic in after() callbacks may become difficult to test and maintain as business rules evolve
  Mitigation: Extract complex validation logic into dedicated validator classes; limit after() callbacks to simple cross-field validation; document validation business rules
  Owner: Engineering team
- Inconsistent validation implementation across Action and Service classes may create security gaps where some code paths lack proper validation
  Mitigation: Establish code review checklist requiring validation before data access; implement static analysis rules to detect unvalidated input before save operations; use BaseService pattern consistently
  Owner: Security team and engineering leads

## Implementation Notes

- Use Validator::make() immediately upon receiving array input in Action or Service execute() methods, before any business logic execution
- For Service classes, call parent validateRules() first for structural validation, then implement custom validate() method for authorization and business rule validation
- Apply validateWithBag() with descriptive names (updateProfileInformation, updatePassword) to namespace validation errors for distinct UI contexts
- Use Rule::unique()->ignore() for email validation in update operations to allow users to keep their existing email address
- Implement password validation using PasswordValidationRules trait and Hash::check() for current password verification in password change operations
- Throw ModelNotFoundException in custom validate() methods when cross-account authorization fails to distinguish from missing resources

## Continuation Context


Verify commands:
- grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l
- grep -r "->save()\|->forceFill(\|->update(\|->create(" app/Actions app/Domains --include="*.php" -B 10 | grep -c "Validator::make"
- php artisan test --filter=Validation

Accept when:
- All files containing Eloquent data access operations (save, forceFill, update, create) also contain Validator::make() calls preceding those operations
- Validation test suite passes with 100% coverage of validation rules for all Action and Service classes
- Static analysis confirms no direct path from user input array parameters to Eloquent persistence methods without intervening validation

## Enforcement

- Verified by: Code review checklist requiring validation verification before approving PRs with data access changes
- Verified by: PHPStan or Psalm static analysis rules detecting unvalidated input before Eloquent operations
- Verified by: Integration test suite verifying validation rules match database constraints
- Verified by: Security audit scanning for Validator::make() presence before save operations
- Violation handling: CI pipeline fails if static analysis detects data access operations without preceding validation
- Violation handling: Code review blocks merge until validation is added or exception is documented and approved
- Violation handling: Security team notified of violations detected in production code for immediate remediation
- Violation handling: Post-incident review required for any data integrity issues traced to missing validation
- Exception process: Developer documents the exception request with justification, alternative validation mechanism, and risk assessment
- Exception process: Security team reviews exception request and approves or rejects with written rationale
- Exception process: Approved exceptions are recorded in ADR amendments with expiration date for re-review
- Exception process: Exception code paths must include compensating controls and enhanced monitoring
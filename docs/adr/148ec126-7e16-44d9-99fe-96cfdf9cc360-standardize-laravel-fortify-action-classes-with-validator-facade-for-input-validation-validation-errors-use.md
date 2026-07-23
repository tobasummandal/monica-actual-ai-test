# Standardize Laravel Fortify Action Classes with Validator Facade for Input Validation: Validation Errors Use

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- Laravel Fortify authentication actions require consistent input validation to prevent injection attacks and data integrity violations
- The codebase implements user authentication workflows including registration, password updates, password resets, and profile updates that handle sensitive user credentials
- All Fortify action classes in the App\Actions\Fortify namespace follow a consistent pattern of using Illuminate\Support\Facades\Validator for input validation
- The pattern emerged across 4 files handling critical authentication operations where input validation failures could lead to security vulnerabilities
- Hash facade usage for password operations and Rule facade for unique constraints demonstrate integration with Laravel's security infrastructure

## Problem Statement

Authentication action classes must validate user input before processing sensitive operations like password changes, user registration, and profile updates. Without standardized validation patterns, developers may inconsistently apply validation rules, leading to security gaps, injection vulnerabilities, or data integrity issues across authentication workflows.

## Decision

1. SHOULD: Validation errors SHOULD use validateWithBag() to namespace error messages by operation context

## Policy Block

- SHOULD Validation errors SHOULD use validateWithBag() to namespace error messages by operation context

In scope:
- All classes in App\Actions\Fortify namespace implementing Laravel Fortify contracts
- User registration actions implementing CreatesNewUsers
- Password update actions implementing UpdatesUserPasswords
- Password reset actions implementing ResetsUserPasswords
- Profile update actions implementing UpdatesUserProfileInformation
- Any custom Fortify action classes handling user input

Out of scope:
- Non-Fortify authentication implementations
- API request validation in controllers
- Form request validation classes
- Model-level validation rules
- Frontend JavaScript validation
- Third-party authentication providers

Exceptions:
- EXC-001: Action class delegates to a service layer that performs its own validation
- EXC-002: Custom authentication flow requires alternative validation framework for compliance reasons

## Rationale

- The Validator facade provides a consistent, framework-integrated approach to input validation that is well-documented and widely understood by Laravel developers
- All 4 detected files demonstrate identical validation patterns with Validator::make() preceding data operations, indicating an established architectural convention
- Using Validator facade with validateWithBag() enables proper error namespacing for complex forms with multiple submission contexts
- Integration with Rule facade and Hash facade creates a cohesive security layer that leverages Laravel's built-in protections against common vulnerabilities

## Consequences

Positive:
- Consistent validation patterns across all authentication actions reduce cognitive load and improve code maintainability
- Framework-integrated validation automatically protects against common injection attacks and type coercion vulnerabilities
- Validation error messages are properly namespaced and localized through Laravel's translation system
- Hash facade integration ensures passwords are never stored in plaintext and follow bcrypt/argon2 best practices

Negative:
- Validator facade creates tight coupling to Laravel framework, making migration to other frameworks more difficult
- Validation logic is procedural rather than declarative, requiring more boilerplate code compared to Form Request classes
- Complex validation scenarios with after() callbacks can become difficult to test in isolation
- Performance overhead of facade resolution and validation instantiation on every request

## Alternatives

- Use Laravel Form Request classes for validation instead of Validator facade in action classes (rejected)
  Rejected because: Form Requests are designed for HTTP layer validation, while Fortify actions operate at the service layer and may be invoked outside HTTP context
  When valid: When authentication actions are only ever invoked through HTTP controllers and never programmatically
- Implement custom validation classes with dependency injection for each action type (rejected)
  Rejected because: Adds unnecessary abstraction layers and complexity when Validator facade provides sufficient functionality and is already integrated with Laravel ecosystem
  When valid: When validation logic becomes complex enough to warrant dedicated validator classes with extensive reuse
- Use model-level validation rules and rely on database constraints (rejected)
  Rejected because: Provides poor user experience with generic database errors and fails to validate before business logic execution
  When valid: As a secondary defense layer in addition to explicit input validation

## Risks

- Developers may bypass validation by directly calling model methods or using forceFill() without prior validation
  Mitigation: Enforce code review requirements for all Fortify action modifications and add static analysis rules to detect validation bypasses
  Owner: Security team and engineering leads
- Validation rules may become outdated as business requirements evolve, leaving gaps in input validation coverage
  Mitigation: Include validation rule review in security audit checklist and maintain test coverage for all validation scenarios
  Owner: Engineering team
- Custom validation logic in after() callbacks may not be properly tested or may contain logic errors
  Mitigation: Require unit tests for all custom validation callbacks and document the validation logic in code comments
  Owner: Engineering team

## Implementation Notes

- Import Illuminate\Support\Facades\Validator at the top of all Fortify action classes
- Place Validator::make() call as the first operation in public action methods before any business logic
- Use array syntax for validation rules to maintain consistency: ['required', 'string', 'max:255']
- For password fields, always use $this->passwordRules() from PasswordValidationRules trait rather than inline rules
- Use validateWithBag() with descriptive bag names matching the operation context (e.g., 'updatePassword', 'updateProfileInformation')
- For email uniqueness checks in update operations, use Rule::unique('users')->ignore($user->id) to allow users to keep their existing email

## Continuation Context


Verify commands:
- grep -r "class.*implements.*Fortify" app/Actions/Fortify/ | xargs -I {} sh -c 'grep -L "Validator::make" {}'
- grep -r "implements.*Fortify" app/Actions/Fortify/*.php | cut -d: -f1 | xargs grep -L "use Illuminate\\\\Support\\\\Facades\\\\Validator"
- php artisan test --filter=Fortify --coverage --min=80

Accept when:
- All Fortify action classes contain 'use Illuminate\Support\Facades\Validator' import statement
- Every public method in Fortify action classes that accepts user input invokes Validator::make() before data operations
- Test coverage for Fortify action validation scenarios exceeds 80%
- No direct forceFill() or save() calls occur before validation in Fortify action methods

## Enforcement

- Verified by: Static analysis scanning for Validator facade usage in Fortify action classes
- Verified by: Code review checklist requiring validation verification for authentication-related changes
- Verified by: Automated test suite with validation scenario coverage requirements
- Verified by: Security audit review of authentication action implementations
- Violation handling: Pull requests failing validation pattern checks are blocked from merge
- Violation handling: Security team notification triggered for authentication code changes without proper validation
- Violation handling: Quarterly security audits identify and remediate validation gaps
- Violation handling: Violations discovered in production require immediate hotfix and post-mortem
- Exception process: Submit exception request to security team with detailed justification
- Exception process: Provide alternative validation implementation with equivalent security guarantees
- Exception process: Security team conducts risk assessment and approves or rejects within 2 business days
- Exception process: Approved exceptions are documented in code comments with ticket reference and expiration review date
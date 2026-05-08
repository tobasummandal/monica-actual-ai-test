# Adopt Quality Gates Pattern for Domain Service Layer Validation: Domain Service Methods

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all domain service implementations, view helpers, and controller methods that process user input or external data. Quality gates MUST be implemented at service boundaries.

## Context

- The codebase exhibits a consistent pattern of implementing quality gates across domain services, view helpers, and controllers to validate data integrity before processing
- Pattern detected across 5 files with 77.84% confidence, spanning multiple domains including Vault management, Contact management, DAV client services, and notification channels
- The application follows a domain-driven design architecture where each domain encapsulates business logic and requires validation at service boundaries
- Quality gates serve as defensive programming checkpoints that prevent invalid data from propagating through the system and causing runtime errors or data corruption
- The pattern appears in both web-facing components (ViewHelpers, Controllers) and internal service utilities (AddressBookSynchronizer), indicating a system-wide architectural principle

## Problem Statement

Without standardized quality gates at service boundaries, domain services risk processing invalid or malformed data, leading to runtime exceptions, data corruption, and unpredictable system behavior. The lack of consistent validation patterns across domains creates maintenance burden and increases the likelihood of security vulnerabilities and business logic errors.

## Decision

1. MUST: All domain service methods that accept external input or cross-domain data MUST implement quality gate validation before processing business logic

## Policy Block

- MUST All domain service methods that accept external input or cross-domain data MUST implement quality gate validation before processing business logic

In scope:
- All domain service classes in app/Domains/*/Services/
- All view helper classes in app/Domains/*/Web/ViewHelpers/
- All controller methods in app/Domains/*/Web/Controllers/ that handle external requests
- Synchronization and integration services that process external data sources
- Command and query handlers that accept user input or cross-domain data

Out of scope:
- Private helper methods within a service that operate on already-validated data
- Pure data transfer objects (DTOs) and value objects that enforce validation in constructors
- Database query builders and repository methods that operate on typed parameters
- Unit test fixtures and test helper methods

Exceptions:
- EXC-001: Performance-critical hot paths where validation overhead is measured and documented as unacceptable
- EXC-002: Legacy code undergoing gradual refactoring where immediate compliance would block critical business features

## Rationale

- The pattern detection across 5 diverse files (ViewHelpers, Controllers, Synchronizers) with 77.84% confidence indicates this is an established architectural principle rather than coincidental code similarity
- Quality gates at service boundaries align with defensive programming principles and domain-driven design, ensuring each domain maintains its own data integrity guarantees
- Early validation prevents cascading failures and makes debugging significantly easier by failing fast at the point of invalid input rather than deep in business logic
- Consistent validation patterns across domains reduce cognitive load for developers and make code reviews more effective by establishing predictable validation locations

## Consequences

Positive:
- Improved system reliability through early detection of invalid data before it propagates through business logic
- Enhanced debuggability with clear failure points and typed exceptions indicating exactly what validation failed
- Reduced security vulnerabilities by validating external input at service boundaries before processing
- Better maintainability through consistent validation patterns that developers can recognize and follow across domains
- Clearer separation of concerns with validation logic explicitly separated from business logic

Negative:
- Increased code verbosity with validation logic adding lines of code to each service method
- Potential performance overhead from validation checks, particularly in high-throughput scenarios
- Risk of validation logic duplication if not properly abstracted into reusable components
- Additional maintenance burden when business rules change, requiring updates to validation logic across multiple services

## Alternatives

- Rely on framework-level validation (Laravel Form Requests) exclusively without service-layer quality gates (rejected)
  Rejected because: Framework validation only covers HTTP request input and does not protect internal service boundaries, cross-domain calls, or background job processing
  When valid: Acceptable only for simple CRUD operations with no complex business logic or cross-domain interactions
- Implement validation only in database layer using constraints and triggers (rejected)
  Rejected because: Database-level validation provides last-resort protection but fails too late in the execution flow, making debugging difficult and preventing meaningful error messages to users
  When valid: Should be used as a complementary defense-in-depth measure, not as the primary validation strategy
- Use type hints and strict typing exclusively without explicit validation logic (rejected)
  Rejected because: PHP type hints only validate data types, not business rules, required field presence, or complex constraints like format validation or cross-field dependencies
  When valid: Type hints should be used in conjunction with quality gates as a first line of defense, but are insufficient alone

## Risks

- Validation logic duplication across services leads to inconsistent validation behavior and maintenance burden
  Mitigation: Extract common validation patterns into reusable validator classes, traits, or value objects. Establish validation library conventions in architecture documentation.
  Owner: Engineering team
- Performance degradation in high-throughput services due to validation overhead
  Mitigation: Profile critical paths and implement caching for expensive validations. Use exception process for documented performance-critical sections with compensating controls.
  Owner: Engineering team
- Incomplete adoption leads to inconsistent quality gate coverage, creating false sense of security
  Mitigation: Implement automated detection via static analysis to identify service methods lacking quality gates. Include quality gate review in code review checklist.
  Owner: Engineering team

## Implementation Notes

- Start by identifying all service methods that accept parameters from external sources (HTTP requests, webhooks, file imports, API calls)
- Implement quality gates immediately after parameter acceptance and before any business logic execution
- Use descriptive exception types (e.g., InvalidJournalDataException, MalformedWebhookPayloadException) to clearly communicate validation failures
- Consider creating a base validator trait or abstract class that provides common validation utilities (e.g., requireField, validateFormat, assertType)
- Document validation rules in method docblocks to make expectations explicit for API consumers and maintainers

## Continuation Context


Verify commands:
- grep -r 'function.*(' app/Domains/*/Services/ app/Domains/*/Web/ViewHelpers/ app/Domains/*/Web/Controllers/ | wc -l
- grep -r 'throw new.*Exception\|if.*empty\|if.*null\|assert\|validate' app/Domains/*/Services/ app/Domains/*/Web/ViewHelpers/ | wc -l
- php artisan test --filter=ValidationTest --testsuite=Unit

Accept when:
- Ratio of validation statements to service methods is at least 1:1, indicating each method has at least one quality gate check
- All new service methods in code review demonstrate explicit validation of input parameters before business logic execution
- Unit tests exist for validation failure scenarios in addition to happy path tests

## Enforcement

- Verified by: Code review checklist includes verification of quality gate implementation for all service methods accepting external input
- Verified by: Static analysis tools scan for service methods lacking validation logic and flag them in CI pipeline
- Verified by: Unit test coverage requirements mandate tests for validation failure scenarios
- Violation handling: CI pipeline warnings for service methods without detectable validation logic
- Violation handling: Code review rejection for new services lacking quality gates
- Violation handling: Architecture review required for exception requests with documented justification
- Exception process: Submit exception request to architecture team with performance benchmarks or technical justification
- Exception process: Document exception in code comments with reference to approval and compensating controls
- Exception process: Create technical debt ticket for future remediation if exception is temporary
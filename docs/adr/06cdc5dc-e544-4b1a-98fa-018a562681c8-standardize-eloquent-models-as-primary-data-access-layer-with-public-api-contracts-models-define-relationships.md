# Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Models Define Relationships

Status: proposed
Date: 2025-01-20
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ALWAYS ACTIVE for all data modeling and database access patterns within the application codebase.

## Context

- The application uses Laravel framework with Eloquent ORM as the primary data access abstraction layer
- Multiple domain entities (File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, QuickFact) follow a consistent model pattern
- Models serve as public API contracts between the database layer and application business logic
- The pattern signature (48fee1a6dba0360d5c8f724f95316ef3) appears consistently across 7 model files with 82.66% confidence
- The facet 'api.public.contracts' indicates these models expose stable interfaces for data access operations

## Problem Statement

Without a standardized approach to data modeling and database access, the application risks inconsistent data access patterns, tight coupling between business logic and database implementation details, and difficulty maintaining API contracts as the schema evolves. A unified data modeling strategy is needed to ensure predictable behavior, maintainability, and clear separation of concerns.

## Decision

1. SHOULD: Models SHOULD define relationships using Eloquent relationship methods (hasMany, belongsTo, etc.) rather than manual joins

## Policy Block

- SHOULD Models SHOULD define relationships using Eloquent relationship methods (hasMany, belongsTo, etc.) rather than manual joins

In scope:
- All persistent domain entities requiring database storage
- Data access operations for CRUD functionality
- Relationship definitions between domain entities
- Data validation and transformation at the model layer
- Query building and data retrieval patterns

Out of scope:
- Temporary data structures not persisted to database
- View models or DTOs used solely for presentation
- External API response objects
- Performance-critical bulk operations requiring raw SQL
- Database migrations and schema definitions

Exceptions:
- EXC-001: Performance profiling demonstrates that Eloquent overhead causes unacceptable latency (>100ms) for high-frequency queries
- EXC-002: Complex analytical queries requiring database-specific features not supported by Eloquent query builder

## Rationale

- Pattern detected across 7 model files with 82.66% confidence indicates established architectural convention
- Eloquent ORM provides consistent abstraction layer reducing boilerplate and SQL injection risks
- Public API contracts through models enable easier testing via mocking and stubbing
- Centralized data access logic in models improves maintainability and reduces code duplication
- Laravel ecosystem tooling and documentation strongly supports Eloquent-based data modeling

## Consequences

Positive:
- Consistent data access patterns across the entire application codebase
- Reduced SQL injection vulnerabilities through parameterized query building
- Improved testability through model mocking and factory patterns
- Easier onboarding for developers familiar with Laravel conventions
- Built-in support for relationships, eager loading, and query optimization

Negative:
- Potential performance overhead for complex queries compared to hand-optimized SQL
- Learning curve for developers unfamiliar with Eloquent ORM patterns
- Risk of N+1 query problems if relationships are not properly eager-loaded
- Abstraction may obscure actual SQL being executed, complicating debugging
- Tight coupling to Laravel framework makes migration to other frameworks difficult

## Alternatives

- Use raw SQL queries with PDO for all database access (rejected)
  Rejected because: Increases SQL injection risk, requires more boilerplate code, loses type safety and IDE support, and contradicts detected pattern across 7 files
  When valid: Only for performance-critical operations with documented justification (see EXC-001)
- Implement custom repository pattern with query builder only (no ORM) (rejected)
  Rejected because: Requires significant refactoring of existing codebase, loses Eloquent relationship features, and pattern evidence shows Eloquent is already established
  When valid: For new microservices where ORM overhead is proven problematic
- Hybrid approach with models for simple entities and repositories for complex queries (deferred)
  When valid: Could be adopted incrementally if performance issues emerge in specific high-traffic areas

## Risks

- N+1 query problems causing performance degradation as data volume grows
  Mitigation: Implement query monitoring, use Laravel Debugbar in development, enforce eager loading in code reviews, add automated tests for query counts
  Owner: Engineering team
- Model classes becoming bloated with business logic violating single responsibility principle
  Mitigation: Establish clear boundaries: models handle data access and simple transformations, complex business logic belongs in service classes or domain objects
  Owner: Architecture team
- Breaking changes to model public API contracts affecting dependent code
  Mitigation: Treat model public methods as API contracts, use deprecation notices before removal, maintain comprehensive test coverage for model interfaces
  Owner: Engineering team

## Implementation Notes

- Use Laravel model factories for test data generation to ensure consistency between tests and production models
- Document all public methods, relationships, and custom attributes in PHPDoc blocks to establish clear API contracts
- Leverage Laravel's $casts property to ensure consistent type handling for attributes (dates, booleans, JSON)
- Consider using model events (creating, updating, etc.) for cross-cutting concerns like auditing rather than scattering logic across controllers
- Use query scopes to encapsulate common filtering patterns and improve query readability

## Continuation Context


Verify commands:
- grep -r "class.*extends.*Model" app/Models/ | wc -l
- find app/Models -name '*.php' -exec php -l {} \; | grep -v 'No syntax errors'
- grep -r "DB::raw\|DB::select\|DB::statement" app/ --exclude-dir=Models | wc -l

Accept when:
- All model classes in app/Models extend Illuminate\Database\Eloquent\Model
- No syntax errors in model files and all models are loadable by PHP parser
- Raw database queries outside models are documented with justification or count is below threshold (e.g., <5 instances)

## Enforcement

- Verified by: Automated static analysis in CI pipeline checking model inheritance
- Verified by: Code review checklist requiring justification for raw SQL queries
- Verified by: PHPStan or Psalm rules enforcing model conventions
- Verified by: Query monitoring in staging environment to detect N+1 problems
- Violation handling: CI pipeline fails if models do not extend base Eloquent Model class
- Violation handling: Code review blocks merge if raw SQL lacks documented justification
- Violation handling: Performance regression tests fail if query counts exceed thresholds
- Violation handling: Architecture review required for new data access patterns deviating from standard
- Exception process: Developer documents performance issue or technical constraint in ticket
- Exception process: Technical lead reviews justification and approves exception
- Exception process: Exception is documented in code comments with ticket reference
- Exception process: Exception is logged in architecture decision log for future review
# Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Helper Classes Provide

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application follows a domain-driven design architecture with distinct domain boundaries (Vault, Contact, Settings) that require consistent data access patterns
- Multiple domain services, view helpers, and background jobs need to interact with primary datastores (likely Eloquent ORM models) in a standardized way
- The pattern appears across 7 files spanning different domains (Vault, Contact, Settings) and different layer types (Services, ViewHelpers, Jobs, Helpers), indicating a cross-cutting architectural concern
- The facet 'data.primary_datastores' suggests this pattern governs how the application's core business logic interacts with persistent storage
- A consistent approach to datastore access is needed to maintain code quality, testability, and prevent data access anti-patterns across the growing codebase

## Problem Statement

Without standardized patterns for accessing primary datastores across domain services, view helpers, and background jobs, the codebase risks inconsistent data access approaches, duplicated query logic, difficulty in testing, and challenges in maintaining data integrity constraints. This becomes particularly problematic in a multi-domain architecture where different teams or developers may implement data access differently.

## Decision

1. MAY: Helper classes MAY provide utility functions for common datastore query patterns, but MUST remain stateless and reusable

## Policy Block

- MAY Helper classes MAY provide utility functions for common datastore query patterns, but MUST remain stateless and reusable

In scope:
- All domain service classes in app/Domains/*/Services/
- All view helper classes in app/Domains/*/Web/ViewHelpers/
- All background jobs in app/Domains/*/Jobs/
- Global helper files in app/Helpers/
- Any code that reads from or writes to the primary application database

Out of scope:
- Third-party library code in vendor/
- Database migrations and seeders
- Cache layer implementations
- External API integrations that don't touch the primary datastore
- Read-only reporting queries in dedicated analytics modules

Exceptions:
- EXC-001: Performance-critical queries require raw SQL optimization
- EXC-002: Legacy code refactoring is planned but not yet completed

## Rationale

- The pattern was detected across 7 files with 79.41% confidence, indicating a well-established architectural convention that should be formalized
- Consistent datastore access patterns improve code maintainability by making data flow predictable and reducing cognitive load when navigating the codebase
- Standardizing on ORM abstractions enables easier testing through model mocking and factory patterns, improving overall test coverage
- The domain-driven architecture benefits from clear boundaries around data access, preventing domain logic from leaking into infrastructure concerns

## Consequences

Positive:
- Improved code consistency across all domains makes onboarding new developers faster and reduces context-switching overhead
- Enhanced testability through dependency injection and mockable data access layers
- Better separation of concerns between business logic and data persistence
- Easier to implement cross-cutting concerns like query logging, caching, and performance monitoring
- Reduced risk of SQL injection vulnerabilities by standardizing on parameterized ORM queries

Negative:
- May introduce slight performance overhead compared to hand-optimized raw SQL queries in some edge cases
- Requires additional abstraction layers which can increase initial development time for simple CRUD operations
- Developers must learn and follow the established patterns rather than implementing ad-hoc solutions
- Legacy code may require significant refactoring to comply with the standard

## Alternatives

- Allow unrestricted direct SQL queries throughout the application (rejected)
  Rejected because: This approach leads to inconsistent code, SQL injection risks, difficulty in testing, and tight coupling between business logic and database schema
  When valid: Never recommended for modern applications with domain-driven architecture
- Implement a strict repository pattern with interfaces for all data access (deferred)
  Rejected because: While more architecturally pure, this adds significant boilerplate and may be over-engineering for the current application size
  When valid: Consider if the application grows to require multiple database backends or complex data access patterns
- Use query builder exclusively without ORM models (rejected)
  Rejected because: Loses the benefits of model relationships, attribute casting, and event hooks that Laravel Eloquent provides
  When valid: Only for specific performance-critical reporting queries where ORM overhead is measurable

## Risks

- Developers may bypass the standard patterns under time pressure, leading to technical debt accumulation
  Mitigation: Implement automated code review checks and linting rules to detect non-compliant data access patterns. Provide clear documentation and examples.
  Owner: Engineering team leads
- Performance bottlenecks may emerge in complex queries that are difficult to optimize through ORM abstractions
  Mitigation: Establish clear exception process for performance-critical queries. Monitor query performance and maintain a list of approved raw SQL patterns.
  Owner: Database performance team
- Existing code may not comply with the standard, creating inconsistency during transition period
  Mitigation: Create a phased migration plan with prioritized refactoring of high-traffic code paths. Document both old and new patterns during transition.
  Owner: Engineering team

## Implementation Notes

- Use Laravel Eloquent models as the primary ORM abstraction for all domain entities
- Inject model dependencies into service constructors rather than using static calls or facades for better testability
- For view helpers that need data, prefer calling service layer methods or creating dedicated query classes
- Background jobs should wrap datastore operations in database transactions where data consistency is critical
- Create shared helper utilities in app/Helpers/ for common query patterns (e.g., ScoutHelper for search functionality)
- Document any raw SQL queries with comments explaining why ORM was insufficient

## Continuation Context


Verify commands:
- grep -r 'DB::raw\|DB::select\|DB::statement' app/Domains --exclude-dir=vendor | grep -v '// Performance exception'
- php artisan test --filter=DataAccessTest
- phpstan analyse app/Domains --level=5 --error-format=table

Accept when:
- All domain services, view helpers, and jobs use ORM models or approved repository patterns for datastore access
- No direct SQL queries exist without documented performance justification comments
- Static analysis passes without violations of data access patterns
- Unit tests successfully mock data access layers without requiring database connections

## Enforcement

- Verified by: Automated CI pipeline runs static analysis (PHPStan) to detect direct SQL usage
- Verified by: Code review checklist includes verification of datastore access patterns
- Verified by: Pre-commit hooks run linting rules that flag non-compliant data access
- Violation handling: CI build fails if static analysis detects unapproved direct SQL queries
- Violation handling: Pull requests with violations are blocked until corrected or exception is documented
- Violation handling: Quarterly code audits identify and prioritize refactoring of non-compliant legacy code
- Exception process: Developer creates exception request with performance justification and benchmark data
- Exception process: Tech lead reviews and approves/rejects based on documented criteria
- Exception process: Approved exceptions are documented in code comments with ticket references
- Exception process: Exception registry is maintained and reviewed quarterly for potential refactoring
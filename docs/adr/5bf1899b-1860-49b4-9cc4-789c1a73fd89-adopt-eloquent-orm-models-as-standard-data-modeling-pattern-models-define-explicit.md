# Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Explicit

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ALWAYS ACTIVE for all data modeling activities within the application layer.

## Context

- The application uses Laravel framework with Eloquent ORM as the primary data access layer, as evidenced by 7 model files in the app/Models directory
- Domain entities including File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, and QuickFact are consistently modeled using Eloquent Model classes
- The pattern shows consistent placement of model classes in the app/Models namespace, indicating a standardized organizational structure
- Eloquent provides Active Record pattern implementation with built-in relationship management, query building, and database abstraction capabilities
- The detected pattern has 82.66% confidence across 7 files, suggesting this is an established architectural convention rather than an isolated implementation

## Problem Statement

The application requires a consistent, maintainable approach to data modeling that provides database abstraction, relationship management, and query capabilities while maintaining code organization and developer productivity. Without a standardized data modeling pattern, teams may implement inconsistent data access patterns leading to maintenance challenges, code duplication, and reduced testability.

## Decision

1. SHOULD: Models SHOULD define explicit relationships using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.) rather than manual joins

## Policy Block

- SHOULD Models SHOULD define explicit relationships using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.) rather than manual joins

In scope:
- All database-backed domain entities in the application layer
- Data access patterns for CRUD operations
- Relationship definitions between domain entities
- Query building and data retrieval logic
- Model-level validation and data transformation

Out of scope:
- Database migration definitions (covered by separate migration system)
- Raw SQL queries for complex reporting or analytics (may use Query Builder directly)
- Non-database data sources (APIs, file systems, caches)
- View models or DTOs used for presentation layer
- Domain services containing complex business logic

Exceptions:
- EX-001: Performance-critical queries require raw SQL or Query Builder for optimization beyond Eloquent capabilities
- EX-002: Legacy database schemas with non-standard naming conventions that cannot be migrated

## Rationale

- Eloquent ORM provides a proven, well-documented Active Record implementation that reduces boilerplate code and accelerates development velocity
- The pattern is already established across 7 model files with 82.66% confidence, indicating successful adoption and team familiarity
- Standardizing on Eloquent ensures consistent data access patterns, improving code maintainability and reducing cognitive load for developers
- Laravel's ecosystem and tooling are built around Eloquent, providing benefits like automatic relationship eager loading, query optimization, and testing utilities

## Consequences

Positive:
- Reduced boilerplate code for common CRUD operations through Eloquent's expressive API
- Improved developer productivity with IDE autocompletion, type hinting, and Laravel's extensive documentation
- Enhanced testability through Eloquent's factory system and database transaction support in tests
- Consistent code organization with clear separation between data models and business logic
- Built-in protection against common vulnerabilities like SQL injection and mass assignment

Negative:
- Potential performance overhead for complex queries compared to hand-optimized SQL
- Learning curve for developers unfamiliar with Active Record pattern or Laravel conventions
- Risk of tight coupling between application code and database schema structure
- N+1 query problems can occur if relationships are not properly eager-loaded

## Alternatives

- Use Data Mapper pattern with separate repository classes and plain PHP objects (rejected)
  Rejected because: Adds significant complexity and boilerplate code without clear benefits for the application's current scale; Laravel ecosystem is optimized for Active Record pattern
  When valid: Consider for large enterprise applications with complex domain models requiring strict separation of persistence and domain logic
- Use Laravel Query Builder directly without model classes (rejected)
  Rejected because: Loses benefits of relationship management, model events, and code organization; increases code duplication across controllers
  When valid: Acceptable for one-off reporting queries or data migration scripts where model overhead is unnecessary
- Hybrid approach with Eloquent for simple entities and repositories for complex aggregates (deferred)
  Rejected because: Not rejected but deferred for future consideration as application complexity grows
  When valid: Revisit when domain complexity requires more sophisticated domain modeling beyond Active Record capabilities

## Risks

- N+1 query performance issues when relationships are not properly eager-loaded, leading to degraded application performance
  Mitigation: Implement query monitoring in development, use Laravel Debugbar to detect N+1 queries, establish code review checklist for relationship loading patterns
  Owner: Engineering team
- Models become bloated with too many responsibilities, violating single responsibility principle
  Mitigation: Enforce rule R-29-008 through code review, extract business logic to service classes, use traits for shared model behaviors
  Owner: Technical leads
- Tight coupling to Laravel framework makes future migration to different framework or architecture difficult
  Mitigation: Accept this trade-off for current productivity gains; if migration becomes necessary, implement repository pattern as abstraction layer incrementally
  Owner: Architecture team

## Implementation Notes

- Use 'php artisan make:model' command to generate new model classes with consistent structure and boilerplate
- Configure mass assignment protection immediately when creating models by defining $fillable or $guarded arrays
- Define relationships in dedicated methods using Eloquent relationship types; document inverse relationships for bidirectional navigation
- Use model observers or events for cross-cutting concerns like logging, caching, or notifications rather than duplicating logic across controllers
- Leverage Laravel's model factories for test data generation to improve test maintainability

## Continuation Context


Verify commands:
- find app/Models -type f -name '*.php' | xargs grep -L 'extends Model' | wc -l | grep -q '^0$'
- grep -r 'namespace App\\Models' app/Models/*.php | wc -l
- php artisan tinker --execute="echo count(get_declared_classes())" 2>&1 | grep -q '[0-9]'

Accept when:
- All PHP files in app/Models directory extend Illuminate\Database\Eloquent\Model class
- Model classes are properly namespaced under App\Models and follow PSR-4 autoloading standards
- No direct database queries using DB facade exist in controller methods where Eloquent models are available
- Code review checklist includes verification of mass assignment protection and relationship eager loading

## Enforcement

- Verified by: Automated static analysis using PHPStan or Psalm to verify model class structure and inheritance
- Verified by: Code review process with checklist items for model conventions and relationship definitions
- Verified by: CI pipeline checks for proper namespace usage and file organization in app/Models directory
- Violation handling: CI pipeline fails if models are detected outside app/Models namespace or not extending base Model class
- Violation handling: Code review blocks merge if models contain business logic beyond data access concerns
- Violation handling: Automated linting warnings for missing mass assignment protection or undocumented relationships
- Exception process: Developer documents exception rationale in pull request description with reference to specific exception policy (EX-001 or EX-002)
- Exception process: Technical lead or architect reviews exception request and approves/rejects based on documented criteria
- Exception process: Approved exceptions are documented in code comments with ADR reference and expiration date for future review
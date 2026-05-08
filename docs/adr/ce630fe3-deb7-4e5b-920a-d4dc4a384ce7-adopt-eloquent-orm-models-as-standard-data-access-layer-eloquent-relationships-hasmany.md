# Adopt Eloquent ORM Models as Standard Data Access Layer: Eloquent Relationships Hasmany

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all database-backed entities in the application. All data access operations MUST use Eloquent ORM models as the primary abstraction layer.

## Context

- The application requires a consistent approach to database interaction across multiple domain entities including Files, Accounts, Contact Information, Gift Occasions, Call Reasons, Post Templates, and Quick Facts
- Laravel framework provides Eloquent ORM as the native data modeling solution with built-in support for relationships, query building, and data validation
- Seven distinct model classes have been identified following the same architectural pattern, indicating an established convention across the codebase
- The pattern shows 82.66% confidence with consistent implementation across app/Models namespace, suggesting this is a deliberate architectural choice rather than ad-hoc implementation
- Domain complexity requires rich object-oriented representations of data entities with behavior encapsulation beyond simple data transfer objects

## Problem Statement

The application needs a standardized, maintainable approach to represent database entities as domain objects while providing type-safe data access, relationship management, and business logic encapsulation. Without a consistent data modeling pattern, the codebase risks fragmentation with mixed approaches (raw SQL, query builders, multiple ORM patterns) leading to increased maintenance burden and inconsistent data handling.

## Decision

1. SHOULD: Eloquent relationships (hasMany, belongsTo, belongsToMany, etc.) SHOULD be defined as methods within the model class rather than using manual joins

## Policy Block

- SHOULD Eloquent relationships (hasMany, belongsTo, belongsToMany, etc.) SHOULD be defined as methods within the model class rather than using manual joins

In scope:
- All persistent domain entities stored in relational database tables
- CRUD operations for File, Account, ContactInformationType, GiftOccasion, CallReasonType, PostTemplateSection, QuickFact, and similar entities
- Relationship definitions between domain entities
- Data validation rules at the model layer
- Entity-specific business logic and computed properties

Out of scope:
- Complex analytical queries requiring raw SQL for performance optimization
- Data transfer objects (DTOs) used for API responses or inter-service communication
- Read-only views or materialized views without corresponding base tables
- Temporary or session-based data not persisted to the database
- Third-party API integrations where data is not stored locally

Exceptions:
- EXC-001: Performance-critical queries require raw SQL optimization that cannot be achieved through Eloquent query builder
- EXC-002: Legacy database schemas with complex naming conventions incompatible with Eloquent conventions

## Rationale

- Pattern detection identified 7 model files with 82.66% confidence, demonstrating consistent adoption across the codebase and validating this as an established architectural standard
- Eloquent ORM provides Laravel-native integration with framework features including migrations, seeders, factories, and testing utilities, reducing integration complexity
- Object-oriented model representation enables encapsulation of business logic close to data, improving cohesion and reducing coupling between layers
- Eloquent's relationship system provides intuitive, declarative syntax for managing complex entity associations without manual join logic, improving code readability and maintainability

## Consequences

Positive:
- Consistent data access patterns across the application reduce cognitive load for developers and simplify onboarding
- Built-in features like eager loading, lazy loading, and relationship management reduce boilerplate code and common bugs
- Strong integration with Laravel ecosystem (migrations, factories, testing) accelerates development velocity
- Type-hinted model properties and IDE support improve developer experience and reduce runtime errors
- Centralized business logic in models improves testability through isolated unit tests

Negative:
- Eloquent abstraction may introduce performance overhead for complex queries compared to optimized raw SQL
- N+1 query problems can occur if developers don't properly use eager loading, potentially degrading performance
- Learning curve for developers unfamiliar with Active Record pattern or Eloquent-specific conventions
- Tight coupling to Laravel framework makes future migration to different frameworks more challenging
- Large model classes may become god objects if business logic is not properly extracted to service layers

## Alternatives

- Use Data Mapper pattern with separate repository classes and plain PHP objects (rejected)
  Rejected because: Adds significant boilerplate code and complexity without clear benefits for the application's current scale. Laravel's ecosystem is optimized for Active Record pattern, making Data Mapper integration more difficult.
  When valid: Consider for large enterprise applications with complex domain logic requiring strict separation between persistence and domain layers
- Use Laravel Query Builder directly without model abstraction (rejected)
  Rejected because: Loses object-oriented benefits, relationship management, and business logic encapsulation. Results in scattered data access logic across controllers and services.
  When valid: Acceptable for simple reporting queries or data migration scripts where model overhead is unnecessary
- Hybrid approach with models for simple entities and repositories for complex aggregates (deferred)
  When valid: May be adopted in future if application complexity grows and domain-driven design patterns become necessary for specific bounded contexts

## Risks

- Performance degradation from N+1 queries as application scales and relationship complexity increases
  Mitigation: Implement query monitoring in development environment, enforce eager loading code reviews, and add automated tests detecting N+1 patterns using Laravel Debugbar or Telescope
  Owner: Engineering Team
- Model classes becoming bloated god objects with excessive responsibilities as business logic accumulates
  Mitigation: Establish clear guidelines for extracting complex business logic to service classes, use traits for shared behavior, and conduct regular code reviews focusing on single responsibility principle
  Owner: Tech Lead
- Framework lock-in making future migration away from Laravel costly and time-consuming
  Mitigation: Document critical business logic separately, maintain clear boundaries between domain logic and framework-specific code, and consider interface abstractions for critical components
  Owner: Architecture Team

## Implementation Notes

- Use 'php artisan make:model' command to generate new models following Laravel conventions automatically
- Define $fillable or $guarded properties immediately after model creation to prevent mass assignment vulnerabilities
- Document relationship methods with PHPDoc annotations specifying return types for better IDE support and static analysis
- Use model events (creating, created, updating, updated) for cross-cutting concerns like logging and auditing rather than duplicating logic in controllers
- Leverage Laravel's attribute casting ($casts property) to automatically convert database values to appropriate PHP types (dates, JSON, booleans)
- Consider using model factories for testing to generate realistic test data without manual array construction

## Continuation Context


Verify commands:
- grep -r 'extends Model' app/Models/ | wc -l
- find app/Models -type f -name '*.php' | xargs grep -L 'namespace App\\Models'
- php artisan model:show --all | grep -E '(Table|Database)'
- grep -r 'DB::select\|DB::insert\|DB::update\|DB::delete' app/Http/Controllers/ app/Services/ | grep -v 'raw query approved'

Accept when:
- All model files exist in app/Models namespace and extend Illuminate\Database\Eloquent\Model
- No direct DB facade calls for CRUD operations found in controllers or services (excluding approved exceptions)
- Model count matches database table count for domain entities (excluding pivot tables and migrations table)
- All models define either $fillable or $guarded properties for mass assignment protection

## Enforcement

- Verified by: Automated CI pipeline checks using PHPStan or Psalm to detect direct DB facade usage in application layer
- Verified by: Code review checklist requiring verification of model existence for new database tables
- Verified by: Laravel Telescope monitoring in staging environment to identify raw SQL queries
- Verified by: Monthly architecture review examining new models for compliance with naming and structure conventions
- Violation handling: CI pipeline fails if direct DB facade calls detected in controllers/services without exception documentation
- Violation handling: Pull requests blocked until models are created for new database tables
- Violation handling: Violations flagged in code review with required remediation before merge
- Violation handling: Quarterly technical debt review to address accumulated violations and assess exception validity
- Exception process: Developer documents performance requirement or technical constraint in code comments
- Exception process: Tech Lead reviews exception request with performance benchmarks or technical justification
- Exception process: Approved exceptions tagged with 'raw query approved' comment for CI exclusion
- Exception process: Exception registry maintained in architecture documentation with review date for reassessment
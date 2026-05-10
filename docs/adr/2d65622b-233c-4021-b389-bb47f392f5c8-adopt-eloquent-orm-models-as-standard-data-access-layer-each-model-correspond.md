# Adopt Eloquent ORM Models as Standard Data Access Layer: Each Model Correspond

Status: proposed
Date: 2025-01-20
Deciders: Detection Pipeline (automated)

## Context

- The application requires a consistent approach to database interaction and object-relational mapping across multiple domain entities
- Seven distinct model classes (File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, QuickFact) demonstrate a standardized pattern for data modeling
- Laravel framework provides Eloquent ORM as the native data access abstraction layer with built-in support for relationships, query building, and model lifecycle events
- The codebase exhibits consistent placement of model classes in the app/Models namespace, indicating architectural standardization
- Domain complexity requires type-safe, object-oriented representations of database entities with clear separation between data access and business logic

## Problem Statement

The application needs a standardized, maintainable approach to represent database entities as domain objects while providing consistent query interfaces, relationship management, and data validation across diverse entity types including files, templates, contact information, occasions, accounts, and facts.

## Decision

1. MUST: Each model MUST correspond to a single database table with explicit or conventional table name mapping

## Policy Block

- MUST Each model MUST correspond to a single database table with explicit or conventional table name mapping

In scope:
- All database-backed domain entities requiring CRUD operations
- Entities with relationships to other database tables
- Data structures requiring validation, casting, or transformation
- Objects requiring query builder functionality and collection operations

Out of scope:
- Value objects without database persistence
- Data Transfer Objects (DTOs) used for API communication
- Temporary data structures for in-memory processing
- External service integrations not backed by application database

Exceptions:
- EXC-001: Legacy database schemas require raw SQL queries that cannot be efficiently expressed through Eloquent
- EXC-002: Read-only reporting queries spanning multiple complex joins benefit from query builder or raw SQL

## Rationale

- Pattern detected across 7 distinct model files with 82.66% confidence indicates strong architectural consistency and team adoption
- Eloquent ORM provides type-safe, testable abstractions that reduce SQL injection risks and improve code maintainability
- Standardized model structure enables developers to quickly understand data relationships and query patterns across the codebase
- Laravel ecosystem tooling (migrations, seeders, factories) integrates seamlessly with Eloquent models, accelerating development velocity

## Consequences

Positive:
- Consistent data access patterns reduce cognitive load and onboarding time for new developers
- Built-in relationship management simplifies complex queries and eager loading strategies
- Type casting and attribute accessors provide clean interfaces for data transformation
- Model events and observers enable clean separation of concerns for cross-cutting behaviors
- Query builder provides SQL injection protection and database portability

Negative:
- Eloquent abstraction may introduce performance overhead for extremely high-throughput queries
- N+1 query problems can occur if developers don't properly use eager loading
- Complex queries may be harder to optimize compared to hand-tuned SQL
- Model bloat can occur if business logic inappropriately accumulates in model classes
- Learning curve for developers unfamiliar with Active Record pattern

## Alternatives

- Use Laravel Query Builder directly without Eloquent models (rejected)
  Rejected because: Query Builder lacks object-oriented entity representation, relationship management, and model lifecycle hooks that are essential for complex domain modeling
  When valid: Appropriate for one-off reporting queries or data migrations where entity representation is unnecessary
- Implement custom Data Mapper pattern with separate mapper classes (rejected)
  Rejected because: Adds significant complexity and boilerplate code without clear benefits given Laravel's native Eloquent support and team familiarity
  When valid: Consider for microservices requiring database-agnostic persistence or complex domain-driven design implementations
- Use Doctrine ORM for more advanced data mapping capabilities (rejected)
  Rejected because: Introduces additional dependency, conflicts with Laravel conventions, and requires significant migration effort from existing Eloquent models
  When valid: Valid for applications requiring advanced features like composite keys, value objects, or strict DDD patterns

## Risks

- N+1 query problems causing performance degradation in production as data volume grows
  Mitigation: Implement query monitoring, enforce eager loading in code reviews, use Laravel Debugbar in development, and add automated tests for query counts
  Owner: Engineering team with database performance monitoring
- Model classes accumulating business logic leading to fat models and reduced testability
  Mitigation: Establish service layer pattern for complex business logic, enforce single responsibility in code reviews, and refactor models exceeding 300 lines
  Owner: Technical leads and code reviewers
- Inconsistent mass assignment protection leading to security vulnerabilities
  Mitigation: Require explicit $fillable or $guarded definitions in all models, add static analysis checks, and include mass assignment testing in security audits
  Owner: Security team and senior developers

## Implementation Notes

- Use php artisan make:model command to generate new models with consistent structure and optional migration/factory scaffolding
- Define relationships using type-hinted return types (e.g., public function posts(): HasMany) for better IDE support and static analysis
- Leverage model factories for testing to ensure consistent test data generation across the test suite
- Document complex query scopes and custom accessors with PHPDoc blocks explaining their purpose and usage
- Consider using model observers for cross-cutting concerns like logging, caching, or event dispatching rather than cluttering model methods

## Continuation Context


Verify commands:
- grep -r "extends Model" app/Models/ | wc -l
- find app/Models -name '*.php' -exec grep -L 'namespace App\\Models' {} \;
- php artisan model:show --all 2>&1 | grep -c 'class'
- grep -r "DB::table\|DB::select" app/Http app/Services | grep -v "// Exception" | wc -l

Accept when:
- All model files in app/Models extend Illuminate\Database\Eloquent\Model
- At least 7 model classes exist matching the detected pattern (File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, QuickFact)
- Models define either $fillable or $guarded properties for mass assignment protection
- Direct database queries outside models are documented with exception justifications

## Enforcement

- Verified by: Automated static analysis using PHPStan or Psalm to verify model structure
- Verified by: Code review checklist requiring model namespace and inheritance verification
- Verified by: CI pipeline checks for model file placement and naming conventions
- Verified by: Periodic architecture reviews examining query patterns and N+1 issues
- Violation handling: CI pipeline fails if models are created outside app/Models namespace
- Violation handling: Code review blocks merge if models lack mass assignment protection
- Violation handling: Performance monitoring alerts trigger investigation of N+1 query patterns
- Violation handling: Quarterly technical debt reviews identify and prioritize model refactoring
- Exception process: Developer documents exception rationale in code comments with EXC-ID reference
- Exception process: Technical lead reviews and approves exception via pull request comment
- Exception process: Exception is logged in architecture decision log with justification
- Exception process: Exceptions are reviewed quarterly to determine if they should become permanent patterns or be refactored
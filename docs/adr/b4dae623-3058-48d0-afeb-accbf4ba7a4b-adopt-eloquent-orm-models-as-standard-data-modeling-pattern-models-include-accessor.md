# Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Include Accessor

Status: proposed
Date: 2025-01-20
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all data modeling implementations in the application layer. All domain entities requiring database persistence MUST be represented using Eloquent ORM models.

## Context

- The application requires a consistent approach to modeling domain entities and their persistence layer interactions
- Laravel framework provides Eloquent ORM as the native data modeling abstraction layer
- Multiple model classes (File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, QuickFact) demonstrate established usage pattern across the codebase
- The pattern shows consistent adoption across 7 files with 82.66% confidence, indicating this is a deliberate architectural choice rather than ad-hoc implementation
- Domain-driven design principles require clear separation between business logic and data access concerns

## Problem Statement

The application needs a standardized approach to define data models that represent database entities, handle object-relational mapping, manage relationships between entities, and provide a consistent API for data access operations. Without a unified modeling pattern, the codebase would suffer from inconsistent data access patterns, duplicated persistence logic, and increased maintenance burden.

## Decision

1. MAY: Models MAY include accessor and mutator methods for computed attributes or attribute transformation

## Policy Block

- MAY Models MAY include accessor and mutator methods for computed attributes or attribute transformation

In scope:
- All domain entities requiring database persistence (users, accounts, files, templates, etc.)
- Entities with relationships to other database-backed entities
- Data models requiring ORM features like eager loading, lazy loading, or relationship management
- Entities requiring attribute casting, accessors, mutators, or event handling

Out of scope:
- Value objects that do not require database persistence
- Data Transfer Objects (DTOs) used for API communication
- View models or presentation layer objects
- Temporary data structures used only in memory
- External API response models that don't map to local database tables

Exceptions:
- EXC-001: Legacy database schemas require custom query builder usage that Eloquent cannot efficiently handle
- EXC-002: Performance-critical operations require raw SQL queries or database-specific features

## Rationale

- Pattern detection shows consistent adoption across 7 model files (File, PostTemplateSection, ContactInformationType, GiftOccasion, CallReasonType, Account, QuickFact) with 82.66% confidence, indicating this is an established architectural standard
- Eloquent ORM provides a mature, well-documented abstraction layer that reduces boilerplate code and improves developer productivity
- Laravel's native ORM integration ensures compatibility with framework features like migrations, seeders, factories, and testing utilities
- The Active Record pattern implemented by Eloquent aligns with rapid application development needs while maintaining code clarity and maintainability

## Consequences

Positive:
- Consistent data access patterns across the entire application reduce cognitive load for developers
- Eloquent's relationship management simplifies complex queries and eager loading strategies
- Built-in features like soft deletes, timestamps, and attribute casting reduce boilerplate code
- Strong integration with Laravel ecosystem (migrations, factories, seeders) improves development workflow
- Query builder provides fluent interface for complex queries while maintaining readability

Negative:
- Active Record pattern can lead to anemic domain models if business logic is improperly placed in model classes
- ORM abstraction may introduce performance overhead for complex queries compared to raw SQL
- Tight coupling to Laravel framework makes migration to other frameworks more difficult
- N+1 query problems can occur if developers don't properly use eager loading
- Learning curve for developers unfamiliar with Eloquent's conventions and magic methods

## Alternatives

- Use Data Mapper pattern with separate mapper classes for persistence logic (rejected)
  Rejected because: Adds complexity and boilerplate code without clear benefits for the application's current scale. The detected pattern shows strong adoption of Active Record (Eloquent), indicating this approach meets current needs.
  When valid: Consider for large-scale enterprise applications with complex domain logic requiring strict separation of concerns
- Use raw PDO or database query builder without ORM abstraction (rejected)
  Rejected because: Loses type safety, relationship management, and framework integration benefits. Increases development time and maintenance burden. Pattern evidence shows team has chosen ORM approach.
  When valid: Only for specific performance-critical operations where ORM overhead is demonstrably problematic
- Adopt Doctrine ORM as alternative to Eloquent (rejected)
  Rejected because: Requires additional dependencies and configuration. Loses native Laravel integration. Current pattern shows successful Eloquent adoption across 7 model classes.
  When valid: Consider if migrating away from Laravel or requiring advanced ORM features like Unit of Work pattern

## Risks

- Developers may place excessive business logic in model classes, violating single responsibility principle and creating fat models
  Mitigation: Establish coding standards requiring business logic in service classes or domain services. Conduct code reviews focusing on model class responsibilities. Provide training on proper model usage.
  Owner: Engineering team and architecture review board
- N+1 query problems may degrade performance as application scales if eager loading is not properly implemented
  Mitigation: Enable query logging in development environments. Use Laravel Debugbar or Telescope to monitor queries. Establish performance testing for critical paths. Document eager loading patterns.
  Owner: Engineering team and performance monitoring
- Framework lock-in makes future migration to different frameworks or ORMs more costly
  Mitigation: Use repository pattern or service layer to abstract data access where appropriate. Document data access patterns. Maintain clear boundaries between framework code and business logic.
  Owner: Architecture team

## Implementation Notes

- Place all model classes in app/Models directory with singular, PascalCase naming (e.g., User, PostTemplateSection, ContactInformationType)
- Define $fillable or $guarded properties in each model to control mass assignment. Prefer $fillable for explicit whitelisting.
- Use $casts property to define attribute type casting (e.g., 'is_active' => 'boolean', 'metadata' => 'array', 'published_at' => 'datetime')
- Define relationships using Eloquent methods (hasMany, belongsTo, belongsToMany, morphMany, etc.) with proper return type hints
- Use query scopes (scopeActive, scopeRecent, etc.) for reusable query logic specific to the model
- Leverage model events (creating, created, updating, updated, deleting, deleted) for cross-cutting concerns like logging or cache invalidation
- Use eager loading (with() method) to prevent N+1 query problems when accessing relationships
- Consider using API resources or transformers for serialization rather than exposing raw model attributes

## Continuation Context


Verify commands:
- grep -r "extends Model" app/Models/ | wc -l
- find app/Models -type f -name '*.php' -exec grep -L 'use Illuminate\\Database\\Eloquent\\Model' {} \;
- php artisan model:show --all 2>&1 | grep -E '(class|table)' | head -20

Accept when:
- All model files in app/Models directory extend Illuminate\Database\Eloquent\Model
- Each model class corresponds to a database table and follows Laravel naming conventions
- Models define appropriate fillable/guarded properties and casts for type safety
- Relationships between entities are defined using Eloquent relationship methods
- No raw SQL queries exist where Eloquent could reasonably be used instead

## Enforcement

- Verified by: Automated code review checks in CI pipeline scanning for Model class structure
- Verified by: PHPStan or Psalm static analysis rules enforcing Eloquent usage patterns
- Verified by: Manual code review checklist items for new model classes
- Verified by: Architecture decision review for any exceptions to the pattern
- Violation handling: CI pipeline fails if model classes are created outside app/Models directory
- Violation handling: Code review blocks merge if models don't extend Eloquent Model base class
- Violation handling: Static analysis warnings for missing fillable/guarded properties
- Violation handling: Performance monitoring alerts for N+1 query patterns in production
- Exception process: Developer documents specific technical limitation requiring exception in code comments
- Exception process: Tech lead or architect reviews exception request with justification
- Exception process: Exception is documented in ADR exceptions log with approval date and reviewer
- Exception process: Exception includes plan for future refactoring if applicable
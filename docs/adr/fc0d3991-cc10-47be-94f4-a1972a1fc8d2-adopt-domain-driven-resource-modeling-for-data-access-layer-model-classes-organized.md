# Adopt Domain-Driven Resource Modeling for Data Access Layer: Model Classes Organized

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application requires a consistent approach to modeling domain entities and their persistence layer representations
- Multiple domain contexts (Contact, File management) need standardized data access patterns that align with domain boundaries
- Resource-based modeling patterns (VCard, VCalendar) indicate integration with external standards and protocols requiring specialized data representations
- The codebase demonstrates a pattern of separating domain logic from data access concerns through dedicated resource and model classes

## Problem Statement

The application needs a consistent, maintainable approach to modeling data entities that supports both internal domain logic and external protocol integration (such as DAV resources), while maintaining clear separation of concerns between business logic and data persistence.

## Decision

1. SHOULD: Model classes SHOULD be organized by domain context (e.g., Contact, File) to maintain clear bounded contexts

## Policy Block

- SHOULD Model classes SHOULD be organized by domain context (e.g., Contact, File) to maintain clear bounded contexts

In scope:
- All Eloquent models representing persistent domain entities
- Resource classes for DAV protocol integration (VCard, VCalendar)
- Data transfer objects used for external API communication
- Domain-specific model classes within bounded contexts

Out of scope:
- View models or presentation layer DTOs
- Temporary data structures used only within single methods
- Third-party library models or external package entities
- Database migration files and schema definitions

## Rationale

- Pattern detected across 3 files with 79.73% confidence indicates a deliberate architectural approach to data modeling
- Separation of domain models (File.php) from protocol-specific resources (VCardResource, VCalendarResource) demonstrates adherence to single responsibility principle
- Domain-driven organization (app/Domains/Contact/Dav/) suggests intentional bounded context implementation
- This pattern enables maintainability by providing clear locations for data-related logic and facilitates testing through well-defined model boundaries

## Consequences

Positive:
- Clear separation between domain models and external protocol representations improves maintainability
- Consistent model organization by domain context makes the codebase more navigable and understandable
- Dedicated resource classes for standards like VCard/VCalendar enable clean integration with external systems
- Well-defined model boundaries facilitate unit testing and mocking in test scenarios

Negative:
- Additional abstraction layers may increase initial development time for simple CRUD operations
- Developers must understand the distinction between models, resources, and DTOs to work effectively
- Potential for code duplication between similar model structures across different domains
- Increased file count and directory depth may complicate navigation for new team members

## Alternatives

- Active Record pattern with all logic in single model classes (rejected)
  Rejected because: Mixing domain logic, persistence, and protocol transformation in single classes violates single responsibility principle and makes testing difficult
  When valid: Only appropriate for very simple applications with minimal external integrations
- Repository pattern with separate repository classes for all data access (deferred)
  Rejected because: Not rejected, but current pattern uses Eloquent models directly which is sufficient for current complexity
  When valid: Should be reconsidered if data access logic becomes more complex or multiple data sources are introduced
- Anemic domain models with all logic in service classes (rejected)
  Rejected because: Separating all behavior from data structures leads to procedural code and loses benefits of object-oriented encapsulation
  When valid: Only appropriate for purely data-transfer scenarios with no business logic

## Risks

- Inconsistent application of the pattern across different domains leading to architectural drift
  Mitigation: Establish code review guidelines and automated linting rules to enforce model organization standards
  Owner: engineering team
- Over-engineering simple entities with unnecessary abstraction layers
  Mitigation: Document clear criteria for when to create separate resource classes versus using models directly
  Owner: engineering team
- Tight coupling between domain models and ORM framework (Eloquent) making future migrations difficult
  Mitigation: Consider introducing repository interfaces if framework independence becomes a requirement
  Owner: engineering team

## Implementation Notes

- Place core domain models in app/Models/ directory with clear, singular naming (e.g., File.php, User.php)
- Organize domain-specific models and resources within app/Domains/{DomainName}/ subdirectories to maintain bounded contexts
- Create dedicated resource classes (e.g., VCardResource, VCalendarResource) for external protocol transformations in appropriate domain subdirectories
- Use consistent method naming for resource transformations (e.g., toVCard(), fromVCard()) to establish predictable APIs

## Continuation Context


Verify commands:
- find app/Models -name '*.php' -type f | wc -l
- grep -r 'class.*Resource' app/Domains/ --include='*.php' | wc -l
- find app/Domains -type d -name 'Dav' | wc -l

Accept when:
- All domain entities have corresponding model classes in app/Models/ or domain-specific directories
- External protocol integrations use dedicated resource classes separate from core models
- Domain organization follows consistent directory structure with clear bounded contexts

## Enforcement

- Verified by: Code review process checking for proper model organization and naming conventions
- Verified by: Static analysis tools verifying model class locations match domain structure
- Verified by: CI pipeline checks ensuring resource classes are properly separated from domain models
- Violation handling: Pull requests with improperly organized models are flagged during code review
- Violation handling: Automated linting failures block merge until models are reorganized according to pattern
- Violation handling: Architecture review required for new domain contexts to ensure consistent application of pattern
- Exception process: Exceptions must be documented in ADR amendments with clear justification
- Exception process: Technical lead approval required for deviations from standard model organization
- Exception process: Exception cases are tracked and reviewed quarterly to identify pattern improvements
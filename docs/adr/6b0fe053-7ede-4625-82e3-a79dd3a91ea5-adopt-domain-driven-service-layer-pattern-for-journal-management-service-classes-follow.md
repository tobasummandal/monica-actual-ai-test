# Adopt Domain-Driven Service Layer Pattern for Journal Management: Service Classes Follow

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The application implements a domain-driven architecture with clear separation between web controllers and business logic services within the Vault domain
- Journal management functionality is organized into dedicated service classes that encapsulate single-responsibility operations (create, update, destroy, remove)
- The ManageJournals subdomain contains 25+ files following a consistent pattern of Controllers delegating to Services for business operations
- This pattern emerged to maintain clean separation of concerns between HTTP handling and domain logic, enabling testability and reusability
- The architecture supports complex journal operations including posts, metrics, photos, tags, slices of life, and contact associations

## Problem Statement

Without a standardized service layer pattern, business logic becomes scattered across controllers, models, and ad-hoc helper classes, leading to code duplication, difficulty in testing, and inconsistent transaction boundaries. The journal management domain requires a cohesive approach to organizing operations that span multiple entities and enforce business rules consistently.

## Decision

1. MUST: Service classes MUST follow single-responsibility principle with one primary operation per class (e.g., CreatePostMetric, DestroySliceOfLife, UpdateJournalMetric)

## Policy Block

- MUST Service classes MUST follow single-responsibility principle with one primary operation per class (e.g., CreatePostMetric, DestroySliceOfLife, UpdateJournalMetric)

In scope:
- All journal management operations including posts, metrics, photos, tags, slices of life, and contacts
- Business logic that requires database transactions or multiple model interactions
- Operations that enforce domain-specific business rules and validation
- Functionality within the Vault domain's ManageJournals subdomain

Out of scope:
- Simple CRUD operations that only involve single-model persistence without business logic
- HTTP request/response handling and view rendering (belongs in controllers)
- Cross-domain operations that span multiple bounded contexts
- Infrastructure concerns like caching, logging, and external API integration

## Rationale

- The pattern is detected across 25 files with 78.49% confidence, indicating strong architectural consistency in the journal management domain
- Service layer pattern provides clear separation between HTTP concerns (controllers) and business logic (services), improving testability and maintainability
- Single-responsibility services enable fine-grained reusability and composition for complex workflows
- Domain-driven organization (Vault/ManageJournals) creates clear boundaries that align with business capabilities and team ownership

## Consequences

Positive:
- Business logic is centralized, testable, and reusable across different entry points (web, API, CLI, background jobs)
- Controllers remain thin and focused on HTTP concerns, improving code readability and reducing cognitive load
- Service classes provide natural transaction boundaries and can be easily mocked for testing
- Clear naming conventions and directory structure make it easy for developers to locate and understand functionality

Negative:
- Increased number of classes and files compared to fat controller approach, requiring more navigation during development
- Potential for over-engineering simple operations that don't require complex business logic
- Learning curve for developers unfamiliar with domain-driven design and service layer patterns
- Risk of service proliferation if not carefully managed, leading to too many small classes

## Alternatives

- Fat Controllers - Implement business logic directly in controller methods (rejected)
  Rejected because: Violates single responsibility principle, makes testing difficult, leads to code duplication across controllers, and couples HTTP concerns with business logic
  When valid: Only appropriate for trivial CRUD applications with no business rules
- Active Record Pattern - Place business logic in Eloquent model classes (rejected)
  Rejected because: Models become bloated with mixed concerns, difficult to test in isolation, and creates tight coupling between persistence and business logic
  When valid: Acceptable for simple domain logic that is intrinsically tied to a single model
- Command Bus Pattern - Use command objects with dedicated handlers (deferred)
  Rejected because: Adds additional abstraction layer that may be unnecessary for current complexity level
  When valid: Consider when cross-cutting concerns like authorization, logging, and queuing need to be applied uniformly across all operations

## Risks

- Service layer becomes anemic with services acting as simple pass-through to models without adding value
  Mitigation: Ensure services encapsulate meaningful business logic, validation, or orchestration. Review service classes during code review to verify they provide value beyond simple delegation
  Owner: Engineering team and architecture reviewers
- Inconsistent application of pattern across different domains leading to architectural fragmentation
  Mitigation: Document pattern in architecture guidelines, provide examples and templates, conduct architecture reviews for new domains
  Owner: Architecture team
- Performance overhead from additional abstraction layers in high-throughput scenarios
  Mitigation: Profile critical paths, optimize service composition, consider caching at service boundaries for expensive operations
  Owner: Engineering team and performance engineers

## Implementation Notes

- Use verb-noun naming for service classes (e.g., CreatePost, UpdateMetric, RemoveTag) to clearly communicate intent
- Keep controllers thin - they should validate input, call services, and return responses without implementing business logic
- Services should accept primitive types or DTOs as parameters rather than HTTP request objects to maintain independence from web layer
- Consider using dependency injection for service dependencies to improve testability and enable mocking
- Group related services in subdirectories if a domain grows large (e.g., ManageJournals/Services/Posts, ManageJournals/Services/Metrics)

## Continuation Context


Verify commands:
- find app/Domains/*/Services -type f -name '*.php' | wc -l
- grep -r 'class.*Controller' app/Domains/Vault/ManageJournals/Web/Controllers | wc -l
- grep -r 'namespace.*Services' app/Domains/Vault/ManageJournals/Services | head -5

Accept when:
- Service classes exist in dedicated Services directories within domain boundaries
- Controllers delegate to services rather than implementing business logic directly
- Service class names follow verb-noun convention and implement single-responsibility operations

## Enforcement

- Verified by: Code review process checking for business logic in controllers
- Verified by: Static analysis tools detecting controller method complexity
- Verified by: Architecture decision review for new domains and subdomains
- Violation handling: Code review feedback requesting refactoring of business logic into services
- Violation handling: Architecture review flagging violations for remediation in next sprint
- Violation handling: Documentation of technical debt when violations cannot be immediately addressed
- Exception process: Document rationale for exception in code comments or ADR
- Exception process: Obtain approval from tech lead or architect for significant deviations
- Exception process: Review exceptions quarterly to determine if pattern needs adjustment
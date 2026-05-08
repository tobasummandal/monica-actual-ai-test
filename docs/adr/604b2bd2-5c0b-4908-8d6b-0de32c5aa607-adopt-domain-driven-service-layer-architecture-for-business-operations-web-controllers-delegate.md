# Adopt Domain-Driven Service Layer Architecture for Business Operations: Web Controllers Delegate

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The application follows a domain-driven design approach with business logic organized into domain-specific service classes
- Account management operations (creation, cancellation, user invitations) are encapsulated in dedicated service classes within domain boundaries
- The architecture separates web controllers from business logic, with controllers delegating to domain services
- This pattern supports a modular, maintainable structure where business rules are isolated from presentation and infrastructure concerns
- The deployment target requires clear separation of concerns to support testing, scalability, and team collaboration across domain boundaries

## Problem Statement

How should business operations be structured and deployed in a web application to ensure maintainability, testability, and clear separation between presentation logic and domain logic while supporting a scalable deployment architecture?

## Decision

1. MUST: Web controllers MUST delegate business logic execution to domain service classes rather than implementing logic directly

## Policy Block

- MUST Web controllers MUST delegate business logic execution to domain service classes rather than implementing logic directly

In scope:
- All business logic for account management operations
- User invitation and acceptance workflows
- Domain-specific service classes handling core business rules
- Web controllers that serve as entry points for HTTP requests

Out of scope:
- Infrastructure-level services (database, caching, queuing)
- Third-party API integrations that don't represent core business logic
- Utility classes and helpers that provide cross-cutting concerns
- Framework-level middleware and request handling

## Rationale

- The pattern was detected across 3 files with 79.20% confidence, indicating consistent application of domain-driven service architecture
- Separating business logic into domain services enables independent testing without HTTP layer dependencies
- Domain-driven organization aligns with bounded context principles, making it easier for teams to work on specific business areas
- This architecture supports deployment flexibility, allowing services to be extracted into microservices if needed without major refactoring

## Consequences

Positive:
- Improved testability through isolation of business logic from web framework concerns
- Enhanced maintainability with clear separation of concerns and domain boundaries
- Better code reusability as services can be invoked from multiple controllers or other services
- Easier onboarding for new developers who can navigate the codebase by domain and feature

Negative:
- Increased number of classes and files compared to controller-heavy architectures
- Potential for over-engineering simple CRUD operations that don't require complex business logic
- Learning curve for developers unfamiliar with domain-driven design principles
- Risk of inconsistent implementation if team members interpret domain boundaries differently

## Alternatives

- Fat Controllers - Implement business logic directly in controller methods (rejected)
  Rejected because: Violates separation of concerns, makes testing difficult, and couples business logic to HTTP layer
  When valid: Only appropriate for trivial applications with minimal business logic
- Action Classes - Use single-action invokable classes instead of traditional controllers (deferred)
  Rejected because: Could be complementary to current approach but requires framework support evaluation
  When valid: When controllers become too large and single-action pattern is preferred
- CQRS with Command/Query Handlers - Separate read and write operations with dedicated handlers (rejected)
  Rejected because: Adds complexity that may not be justified for current application scale
  When valid: When read/write patterns diverge significantly or event sourcing is required

## Risks

- Inconsistent domain boundary definitions leading to unclear service placement
  Mitigation: Establish clear domain mapping documentation and conduct architecture reviews for new domains
  Owner: engineering team
- Service classes becoming too large and violating single responsibility principle
  Mitigation: Enforce code review standards and refactor services that exceed complexity thresholds
  Owner: engineering team
- Tight coupling between services across domain boundaries
  Mitigation: Use dependency injection and define clear interfaces for cross-domain communication
  Owner: engineering team

## Implementation Notes

- Create domain folders under app/Domains/ with subfolders for each feature area (e.g., CreateAccount, CancelAccount)
- Place service classes in Services/ subdirectories and controllers in Web/Controllers/ subdirectories within each feature
- Use dependency injection to provide services to controllers, avoiding direct instantiation
- Name service classes after the business operation they perform (e.g., CreateAccount, AcceptInvitation)
- Keep controllers thin by limiting them to request validation, service invocation, and response formatting

## Continuation Context


Verify commands:
- find app/Domains -type f -name '*.php' -path '*/Services/*' | wc -l
- grep -r 'namespace.*Domains.*Services' app/Domains --include='*.php' | wc -l
- find app/Domains -type f -name '*Controller.php' -path '*/Web/Controllers/*' | wc -l

Accept when:
- Service classes exist in app/Domains/{Domain}/{Feature}/Services/ directories
- Controllers exist in app/Domains/{Domain}/{Feature}/Web/Controllers/ directories
- At least 3 domain service classes follow the established pattern (matching detected evidence)

## Enforcement

- Verified by: Automated static analysis checking namespace and directory structure compliance
- Verified by: Code review process verifying business logic is in service classes, not controllers
- Verified by: CI pipeline checks for proper file organization using grep and find commands
- Violation handling: CI build fails if controllers contain business logic exceeding complexity thresholds
- Violation handling: Pull requests are blocked if service classes are not placed in correct domain directories
- Violation handling: Architecture review required for new domains or significant deviations from pattern
- Exception process: Document exception rationale in ADR amendment or inline code comments
- Exception process: Obtain approval from tech lead or architecture review board
- Exception process: Add technical debt ticket if exception is temporary workaround
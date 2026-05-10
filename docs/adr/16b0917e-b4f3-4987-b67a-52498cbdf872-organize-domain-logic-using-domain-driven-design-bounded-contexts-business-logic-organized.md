# Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Business Logic Organized

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The application exhibits a consistent pattern of organizing code into domain-specific bounded contexts, particularly evident in the Vault domain with the ManageJournals subdomain
- 25 files demonstrate a clear separation between Web controllers, Services, and domain logic within the app/Domains/Vault/ManageJournals namespace
- The codebase follows a modular architecture where business logic is encapsulated in service classes (e.g., RemoveContactFromPost, IncrementPostReadCounter, UpdateJournalMetric) separate from presentation layer controllers
- This pattern suggests a deliberate architectural choice to maintain domain boundaries and prevent cross-cutting concerns from bleeding across functional areas
- The high confidence (78.49%) and support count (25 files) indicate this is an established, consistently applied pattern rather than an isolated occurrence

## Problem Statement

As the application grows in complexity, maintaining clear boundaries between different functional areas becomes critical to prevent tight coupling, reduce cognitive load, and enable independent evolution of features. Without explicit domain organization, business logic tends to scatter across controllers, models, and utility classes, making the system difficult to understand, test, and modify.

## Decision

1. MUST: Business logic MUST be organized into domain-specific directories under app/Domains/{DomainName}

## Policy Block

- MUST Business logic MUST be organized into domain-specific directories under app/Domains/{DomainName}

In scope:
- All new business logic and feature development
- Service classes that encapsulate business operations
- Web controllers that handle HTTP requests within a domain
- Domain models and value objects specific to a bounded context
- Cross-cutting concerns that are domain-specific (e.g., domain events)

Out of scope:
- Infrastructure concerns such as database connections, caching, or logging
- Framework-level middleware and global exception handlers
- Shared utility functions that have no domain-specific logic
- Third-party library integrations that serve multiple domains
- Configuration files and environment-specific settings

Exceptions:
- EX-001: Legacy code that predates this architectural pattern and has not yet been refactored
- EX-002: Rapid prototyping or proof-of-concept code that is explicitly marked as temporary

## Rationale

- The detected pattern shows 25 files consistently following this structure with 78.49% confidence, indicating it is a proven, working approach in this codebase
- Domain-driven organization reduces cognitive load by allowing developers to focus on one bounded context at a time without needing to understand the entire system
- Clear separation between Services and Controllers enables easier testing, as business logic can be tested independently of HTTP concerns
- This structure supports the Open-Closed Principle by allowing new features to be added as new service classes without modifying existing code

## Consequences

Positive:
- Improved code discoverability: developers can quickly locate functionality by navigating the domain structure
- Enhanced testability: service classes can be unit tested without bootstrapping the web framework
- Better scalability: teams can work on different domains with minimal merge conflicts
- Clearer ownership: domain boundaries make it easier to assign responsibility for features and bugs
- Reduced coupling: changes within one domain are less likely to impact other domains

Negative:
- Increased directory depth may make file paths longer and navigation more complex for small projects
- Potential for over-engineering simple features that don't require full domain separation
- Learning curve for developers unfamiliar with domain-driven design principles
- Risk of creating artificial boundaries that don't align with actual business domains if not carefully designed

## Alternatives

- Organize code by technical layer (Controllers, Services, Models) at the top level without domain separation (rejected)
  Rejected because: This approach leads to large, monolithic directories where related business logic is scattered across multiple layers, making it difficult to understand feature boundaries and increasing coupling
  When valid: May be acceptable for very small applications with fewer than 10 controllers and minimal business logic
- Use a microservices architecture with separate codebases for each domain (rejected)
  Rejected because: Introduces significant operational complexity, deployment overhead, and distributed system challenges that are not justified for a monolithic application
  When valid: Should be reconsidered if domains need to scale independently or be deployed by separate teams
- Implement a modular monolith with explicit module boundaries enforced by dependency analysis tools (deferred)
  Rejected because: null
  When valid: Could be adopted as a future enhancement to enforce architectural boundaries programmatically once the domain structure is stable

## Risks

- Inconsistent application of domain boundaries leading to some domains being well-organized while others remain monolithic
  Mitigation: Establish clear guidelines and code review checklists to ensure new code follows the domain structure; conduct periodic architecture reviews
  Owner: Engineering team leads
- Domain boundaries may be drawn incorrectly, requiring costly refactoring as the business model evolves
  Mitigation: Start with coarse-grained domains and refine boundaries iteratively based on actual usage patterns; use event storming sessions with business stakeholders
  Owner: Architecture team
- Shared logic between domains may lead to duplication or inappropriate cross-domain dependencies
  Mitigation: Identify truly shared concerns and extract them to a Shared or Common namespace; use dependency inversion for cross-domain communication
  Owner: Engineering team

## Implementation Notes

- When creating a new feature, first identify which domain it belongs to; if no suitable domain exists, consult with the architecture team before creating a new one
- Service classes should follow a command pattern with a single public execute() or handle() method that encapsulates the business operation
- Use dependency injection to provide services with their dependencies (repositories, external services) rather than instantiating them directly
- Controllers should be thin adapters that validate input, call the appropriate service, and format the response
- Consider using domain events to communicate between bounded contexts rather than direct service-to-service calls

## Continuation Context


Verify commands:
- find app/Domains -type f -name '*Controller.php' | xargs grep -L 'namespace.*\\Web\\Controllers' | wc -l | grep -q '^0$'
- find app/Domains -type f -name '*Service.php' -path '*/Services/*' | wc -l
- grep -r 'class.*Controller' app/Domains --include='*.php' | grep -v 'namespace.*\\Web\\Controllers' | wc -l | grep -q '^0$'

Accept when:
- All controllers are located in Web/Controllers subdirectories within their respective domains
- Service classes are located in Services subdirectories and contain business logic separate from HTTP concerns
- New features added to the codebase follow the domain structure pattern with at least 95% compliance
- Code review checklist includes verification of proper domain organization

## Enforcement

- Verified by: Automated static analysis tools checking namespace and directory structure compliance
- Verified by: Code review process with explicit checklist items for domain organization
- Verified by: CI pipeline checks that fail if files are placed outside the domain structure
- Verified by: Periodic architecture audits reviewing domain boundaries and cohesion
- Violation handling: CI pipeline failures must be resolved before merge
- Violation handling: Code review feedback requires refactoring to comply with domain structure
- Violation handling: Technical debt tickets created for legacy code violations with prioritized remediation plan
- Violation handling: Architecture review board escalation for persistent or systemic violations
- Exception process: Developer submits exception request with justification to technical lead
- Exception process: Technical lead evaluates whether the exception is temporary (refactoring planned) or permanent (pattern doesn't apply)
- Exception process: Approved exceptions are documented in ADR amendments or inline code comments with expiration dates
- Exception process: Exception registry is reviewed quarterly to ensure temporary exceptions are resolved
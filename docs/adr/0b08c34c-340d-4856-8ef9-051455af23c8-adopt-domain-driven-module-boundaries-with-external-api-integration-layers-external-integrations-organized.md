# Adopt Domain-Driven Module Boundaries with External API Integration Layers: External Integrations Organized

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all external API integration implementations and domain boundary definitions within the codebase.

## Context

- The codebase exhibits a consistent pattern of organizing external API integrations (specifically DAV/CardDAV protocols) within domain-bounded modules following a layered architecture approach
- Multiple domains (Contact, Vault, Settings) implement external API integration layers with clear separation between client services, DTOs, backend interfaces, and resource handlers
- The pattern shows deliberate isolation of external protocol concerns (DAV) from core domain logic through dedicated client service layers and utility models
- ViewHelper classes provide presentation layer abstractions that maintain domain boundaries while exposing functionality to external consumers
- The architecture demonstrates a need to integrate with external standards (CardDAV, WebDAV) while preserving internal domain integrity and testability

## Problem Statement

When integrating external APIs and protocols into a domain-driven architecture, there is a risk of protocol-specific concerns bleeding into core domain logic, creating tight coupling, reducing testability, and making it difficult to swap or version external integrations. Without clear module boundaries and integration layers, external API changes can cascade through the system, and domain logic becomes entangled with protocol implementation details.

## Decision

1. MUST: External API integrations MUST be organized within domain-specific modules following the pattern: app/Domains/{DomainName}/{IntegrationName}/

## Policy Block

- MUST External API integrations MUST be organized within domain-specific modules following the pattern: app/Domains/{DomainName}/{IntegrationName}/

In scope:
- All external API integrations including REST, SOAP, WebDAV, CardDAV, and other protocol-based communications
- Third-party service integrations that require protocol-specific client implementations
- Data import/export operations involving external standards or formats
- Public API endpoints that expose domain functionality to external consumers

Out of scope:
- Internal service-to-service communication within the same application boundary
- Database access layers and repository patterns
- Framework-level HTTP routing and middleware
- Authentication and authorization mechanisms (unless specific to external API integration)

Exceptions:
- EXC-001: Legacy integrations predating this ADR that require significant refactoring effort
- EXC-002: Proof-of-concept or experimental integrations in non-production environments

## Rationale

- The detected pattern across 8 files with 75.46% confidence demonstrates a consistent architectural approach to external API integration that successfully maintains domain boundaries
- Separating external protocol concerns into dedicated client layers and DTOs enables independent evolution of domain logic and external integrations, reducing coupling and improving maintainability
- Using interface-based backend definitions (IDAVBackend) provides testability through mock implementations and allows for multiple protocol versions or providers without affecting domain code
- The ViewHelper pattern provides a clean presentation layer abstraction that can adapt domain functionality for external consumption without exposing internal implementation details

## Consequences

Positive:
- Clear separation of concerns between domain logic and external protocol implementations improves code maintainability and reduces cognitive load
- External API changes or version upgrades can be isolated to integration modules without cascading changes through domain logic
- Enhanced testability through interface-based designs and DTO patterns enables comprehensive unit testing without external dependencies
- Consistent module organization across domains improves developer onboarding and reduces time to understand integration patterns

Negative:
- Additional abstraction layers increase initial development time and code volume for simple integrations
- DTO mapping between external formats and domain models introduces boilerplate code and potential performance overhead
- Developers must understand and follow the layered architecture pattern, increasing learning curve for new team members
- Over-abstraction risk: simple integrations may become unnecessarily complex if pattern is applied too rigidly

## Alternatives

- Direct external API calls from domain services without dedicated integration layers (rejected)
  Rejected because: Creates tight coupling between domain logic and external protocols, making testing difficult and external API changes expensive to accommodate
  When valid: Only appropriate for throwaway prototypes or single-use scripts outside the main application
- Centralized API gateway layer handling all external integrations across domains (rejected)
  Rejected because: Violates domain-driven design principles by creating a shared coupling point and reducing domain autonomy; makes it harder to evolve integrations independently per domain
  When valid: May be appropriate for cross-cutting concerns like authentication, rate limiting, or logging that apply uniformly across all external APIs
- Hexagonal architecture with explicit ports and adapters for all external integrations (deferred)
  Rejected because: Not rejected; represents a more formal architectural pattern that could enhance the current approach
  When valid: Should be considered for future architectural evolution, particularly for complex domains with multiple external integration points requiring high flexibility

## Risks

- Inconsistent application of the pattern across different domains or by different teams leads to architectural drift
  Mitigation: Establish code review guidelines, provide reference implementations, and use automated linting to detect pattern violations
  Owner: Engineering team leads and architecture review board
- Over-engineering simple integrations with unnecessary abstraction layers reduces development velocity
  Mitigation: Define clear criteria for when full pattern application is required vs. simplified approaches for trivial integrations; document decision thresholds
  Owner: Engineering team
- DTO proliferation and mapping logic creates maintenance burden and potential data transformation bugs
  Mitigation: Use code generation tools for DTO mapping where appropriate; implement comprehensive integration tests covering data transformations; consider using established mapping libraries
  Owner: Engineering team

## Implementation Notes

- Start new external API integrations by creating the domain module structure first: {Domain}/{IntegrationName}/Services, /Utils/Model, /Web/Backend
- Define the backend interface contract before implementing concrete clients to ensure testability from the start
- Create DTOs that match external API schemas closely, then use separate mapper classes to transform between DTOs and domain entities
- Use dependency injection to provide backend implementations to domain services, enabling easy substitution for testing
- Document the external API version and protocol specifications in the integration module README for future maintainers

## Continuation Context


Verify commands:
- find app/Domains -type f -name '*Client*' -o -name '*Backend*' | xargs grep -l 'interface\|implements' | wc -l
- find app/Domains -path '*/Services/Utils/Model/*Dto.php' | wc -l
- grep -r 'use.*\\Dav\\' app/Domains --include='*.php' | grep -v 'DavClient\|Dav/' | wc -l

Accept when:
- All external API integration modules follow the domain-based directory structure with dedicated Services and Utils/Model subdirectories
- Backend interfaces exist for all external protocol implementations and are used via dependency injection
- No direct external protocol library usage is found in core domain entity or business logic classes (grep verification returns 0 violations)
- All data exchange with external APIs uses dedicated DTO classes rather than direct domain entity serialization

## Enforcement

- Verified by: Automated CI pipeline checks using grep and find commands to detect pattern violations
- Verified by: Code review checklist items specifically covering external API integration structure
- Verified by: Architecture decision review for new external integrations before implementation begins
- Violation handling: CI pipeline fails if direct external protocol usage is detected in core domain classes
- Violation handling: Code review blocks merge requests that don't follow the established module structure for new integrations
- Violation handling: Existing violations are logged as technical debt items with prioritized remediation plans
- Exception process: Developer submits exception request to architecture review board with justification and impact analysis
- Exception process: Review board evaluates request within 2 business days, considering scope, timeline, and technical constraints
- Exception process: Approved exceptions are documented in ADR exceptions log with review date and conditions
- Exception process: All exceptions require follow-up review after 6 months to assess whether they should be remediated or extended
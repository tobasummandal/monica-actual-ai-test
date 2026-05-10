# Standardize External API Integration with DAV Protocol and DTO Pattern: Resource Import Operations

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The application integrates with external DAV (Distributed Authoring and Versioning) servers for contact synchronization, requiring a standardized approach to handle protocol-specific operations
- Multiple domains (Contact, Vault, Settings) expose public-facing APIs and require consistent error handling, permission management, and data transfer patterns
- External API integrations need structured data transfer objects (DTOs) to maintain clear boundaries between external data formats (vCard) and internal domain models
- The system implements backend interfaces (IDAVBackend) to abstract DAV protocol complexity and enable testability and alternative implementations
- Custom exception types (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException, DavServerNotCompliantException) provide domain-specific error handling for external API interactions

## Problem Statement

External API integrations across multiple domains lack a consistent architectural pattern for protocol abstraction, data transfer, error handling, and permission management. Without standardized approaches, each integration may implement different patterns for similar concerns, leading to inconsistent behavior, duplicated code, and increased maintenance burden when interfacing with external systems.

## Decision

1. MUST: Resource import operations from external APIs MUST implement dedicated resource classes (e.g., ImportResource, ImportVCardResource) that handle protocol-specific data transformation

## Policy Block

- MUST Resource import operations from external APIs MUST implement dedicated resource classes (e.g., ImportResource, ImportVCardResource) that handle protocol-specific data transformation

In scope:
- All external API integrations including DAV, CardDAV, and CalDAV protocols
- Data transfer between external systems and internal domain models
- Resource import and export operations for contacts, calendars, and related entities
- Permission validation and error handling for public-facing API endpoints
- Backend interface implementations for protocol-specific operations

Out of scope:
- Internal service-to-service communication within the application
- Database access patterns and repository implementations
- Frontend API endpoints that do not interact with external systems
- Authentication mechanisms (covered by separate security ADRs)
- GraphQL or REST API design for the application's own public API

Exceptions:
- EX-001: Legacy integrations that predate this ADR and are scheduled for deprecation within 6 months
- EX-002: Proof-of-concept or experimental integrations in feature branches not intended for production

## Rationale

- Pattern detected across 11 files with 76.09% confidence indicates this is an established architectural approach in the codebase, particularly for DAV protocol integrations
- The DTO pattern (ContactDto, ContactDeleteDto) provides type safety and clear contracts when transforming external data formats like vCard into internal representations
- Interface-based abstraction (IDAVBackend) enables dependency injection, facilitates unit testing with mocks, and allows for multiple backend implementations without changing client code
- Domain-specific exceptions provide better error handling and debugging capabilities compared to generic exceptions, making it easier to diagnose integration issues with external systems

## Consequences

Positive:
- Consistent architectural pattern across all external API integrations improves code maintainability and reduces cognitive load for developers
- Clear separation between external data formats and internal models prevents external API changes from cascading through the entire application
- Interface-based design enables comprehensive unit testing without requiring live external services
- Domain-specific exceptions provide actionable error messages and enable targeted error handling strategies for different failure scenarios
- ViewHelper pattern separates presentation concerns from business logic, making it easier to modify API response formats

Negative:
- Additional abstraction layers (DTOs, interfaces, ViewHelpers) increase initial development time and code volume for new integrations
- Developers must understand multiple patterns (DTO, interface abstraction, ViewHelper) to implement external API integrations correctly
- Mapping between DTOs and domain models introduces potential for mapping errors and requires careful validation
- Custom exception hierarchy increases the number of exception types that must be handled and documented

## Alternatives

- Direct domain model usage without DTOs, mapping external data directly to internal entities (rejected)
  Rejected because: Tight coupling between external API formats and internal models makes the system fragile to external changes and violates separation of concerns
  When valid: Only appropriate for simple, stable APIs where external format exactly matches internal representation
- Generic API client library without protocol-specific abstractions (rejected)
  Rejected because: Lacks domain-specific error handling and forces protocol complexity into business logic layers, reducing code clarity
  When valid: Could be used for simple HTTP REST APIs that don't require complex protocol handling
- Event-driven integration using message queues for all external API interactions (deferred)
  Rejected because: Adds significant infrastructure complexity and latency for synchronous operations, though may be valuable for async bulk operations
  When valid: Should be reconsidered for high-volume batch import/export operations or when eventual consistency is acceptable

## Risks

- Proliferation of DTO classes and mapping logic increases maintenance burden as external APIs evolve
  Mitigation: Implement automated mapping libraries (e.g., AutoMapper patterns) and maintain comprehensive integration tests to catch mapping errors early
  Owner: Backend Engineering Team
- Interface abstractions may become too generic or too specific, requiring frequent refactoring as new external APIs are integrated
  Mitigation: Review interface design during architecture review sessions when adding new integrations; refactor interfaces when supporting 3+ implementations
  Owner: Architecture Review Board
- Custom exception types may not be caught properly, leading to unhandled exceptions and poor error messages for users
  Mitigation: Implement global exception handlers for all custom exception types and maintain exception handling documentation with examples
  Owner: Backend Engineering Team

## Implementation Notes

- When creating new external API integrations, start by defining the DTO classes that represent the external data format, then create mappers to internal domain models
- Define backend interfaces before implementing concrete classes; use dependency injection to provide implementations to consumers
- Create domain-specific exception types in the appropriate domain namespace (e.g., app/Domains/Contact/DavClient/Services/Utils/Dav/) with descriptive names and error messages
- Use ViewHelper classes in the Web layer to prepare data for API responses, keeping controllers thin and focused on HTTP concerns
- Add the Loggable trait to API client classes to ensure consistent logging of external API interactions for debugging and monitoring

## Continuation Context


Verify commands:
- grep -r "class.*Dto" app/Domains/*/DavClient/Services/Utils/Model/ | wc -l
- grep -r "interface.*Backend" app/Domains/*/Dav/Web/Backend/ | wc -l
- grep -r "class.*Exception extends" app/Domains/ | grep -E "(Permission|Compliant|Maximum)" | wc -l
- find app/Domains -name "*ViewHelper.php" -type f | wc -l

Accept when:
- All external API integrations use DTO classes for data transfer with at least one DTO per external entity type
- Protocol-specific operations are abstracted behind interface contracts with at least one concrete implementation
- Domain-specific exception types exist for common API failure scenarios (permission, compliance, limits) and are properly caught in controllers
- ViewHelper classes are present for domains that expose external APIs and are used in controller response preparation

## Enforcement

- Verified by: Automated code review checks for new API integration code to verify presence of DTOs, interfaces, and exception types
- Verified by: Architecture review sessions for new external API integrations to validate pattern compliance
- Verified by: Static analysis tools configured to detect direct external API usage without DTO abstraction
- Violation handling: Pull requests that introduce external API integrations without proper DTO/interface patterns are blocked until refactored
- Violation handling: Existing violations in legacy code are tracked in technical debt backlog with priority based on integration stability and maintenance frequency
- Violation handling: Critical violations (missing permission checks, generic exceptions) require immediate remediation before deployment
- Exception process: Developer submits exception request to Technical Lead with justification and impact analysis
- Exception process: Technical Lead reviews request and either approves with conditions or requests pattern compliance
- Exception process: Approved exceptions are documented in code with TODO comments linking to migration tickets
- Exception process: Exception review occurs quarterly to assess whether exceptions can be resolved
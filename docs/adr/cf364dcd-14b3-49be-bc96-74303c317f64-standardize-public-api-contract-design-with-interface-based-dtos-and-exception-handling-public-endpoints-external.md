# Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Endpoints External

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The codebase integrates with external DAV (Distributed Authoring and Versioning) services for contact synchronization, requiring well-defined public API contracts
- Multiple domains (Contact, Vault, Settings) expose public-facing interfaces and services that need consistent contract definitions
- External API integrations require robust error handling through custom exceptions (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException, DavServerNotCompliantException)
- Data transfer objects (DTOs) like ContactDto and ContactDeleteDto serve as contract boundaries between internal domain logic and external systems
- The pattern emerged across 11 files with 76.09% confidence, indicating a deliberate architectural approach to public API design

## Problem Statement

Public APIs and external integrations require explicit, stable contracts to ensure interoperability, backward compatibility, and clear error semantics. Without standardized interface definitions, DTOs, and exception hierarchies, external consumers face unpredictable behavior, breaking changes, and unclear failure modes.

## Decision

1. MUST: All public API endpoints and external integration points MUST define explicit interface contracts (e.g., IDAVBackend) that declare method signatures, parameters, and return types

## Policy Block

- MUST All public API endpoints and external integration points MUST define explicit interface contracts (e.g., IDAVBackend) that declare method signatures, parameters, and return types

In scope:
- All REST API endpoints exposed to external consumers
- WebDAV/CardDAV integration interfaces and backends
- Data transfer objects used in API request/response payloads
- Custom exception classes thrown by public API methods
- ViewHelper classes that prepare data for API responses
- Service layer interfaces that define public contracts

Out of scope:
- Internal domain models and entities not exposed via APIs
- Private service methods used only within domain boundaries
- Database repositories and data access layers
- Internal event handlers and message queue consumers
- Administrative CLI commands and internal tools

Exceptions:
- EXC-001: Legacy API endpoints that predate this ADR and have established external consumers
- EXC-002: Prototype or experimental APIs explicitly marked as unstable/alpha

## Rationale

- Pattern detected across 11 files with 76.09% confidence indicates this is an established architectural practice in the codebase
- Interface-based contracts (IDAVBackend) enable dependency inversion and testability while providing clear API boundaries
- DTOs (ContactDto, ContactDeleteDto) decouple internal domain models from external representations, enabling independent evolution
- Domain-specific exceptions (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException) provide clear error semantics and enable proper HTTP status code mapping
- The pattern supports integration with external standards (WebDAV/CardDAV) while maintaining internal architectural flexibility

## Consequences

Positive:
- External API consumers benefit from stable, well-documented contracts that reduce integration friction
- Clear separation between internal models and external DTOs enables independent evolution of domain logic without breaking API contracts
- Explicit exception hierarchies improve error handling and debugging for both internal developers and external consumers
- Interface-based design enables easier testing through mocking and supports multiple implementations (e.g., different DAV backends)
- Standardized logging through traits like Loggable provides consistent observability across all public API components

Negative:
- Additional boilerplate code required for DTOs, interfaces, and custom exceptions increases initial development time
- Mapping between domain models and DTOs introduces transformation logic that must be maintained
- Multiple layers of abstraction (interfaces, DTOs, exceptions) can make code harder to navigate for new developers
- Versioning and backward compatibility concerns add complexity to API evolution and deployment processes

## Alternatives

- Expose domain models directly through APIs without DTO layer (rejected)
  Rejected because: Tightly couples external API contracts to internal domain model changes, making backward compatibility impossible and forcing breaking changes on consumers
  When valid: Only appropriate for internal APIs within a monolithic application with no external consumers
- Use generic exception types (e.g., RuntimeException) instead of domain-specific exceptions (rejected)
  Rejected because: Loses semantic meaning of errors, makes proper HTTP status code mapping difficult, and reduces debuggability for API consumers
  When valid: Acceptable for internal service boundaries where exception types are not part of the contract
- Implement GraphQL or gRPC instead of REST with DTOs (deferred)
  Rejected because: Would require significant infrastructure changes and retraining; current REST+DTO approach meets requirements
  When valid: Consider for future API versions if complex querying or strong typing becomes critical requirement

## Risks

- DTO proliferation leads to excessive mapping code and maintenance burden as API surface area grows
  Mitigation: Implement automated mapping libraries (e.g., AutoMapper patterns) and code generation tools for common DTO transformations
  Owner: Engineering team
- Interface contracts become stale or diverge from actual implementations, reducing their value
  Mitigation: Enforce interface compliance through automated tests, static analysis tools, and code review checklists
  Owner: Engineering team
- Custom exception hierarchies become too granular, creating confusion about which exception to throw
  Mitigation: Document exception taxonomy and decision tree; limit to business-meaningful error categories; conduct periodic reviews
  Owner: Architecture team

## Implementation Notes

- Create base DTO abstract class with common serialization/validation logic to reduce boilerplate in concrete DTOs
- Establish naming conventions: interfaces prefixed with 'I' (IDAVBackend), DTOs suffixed with 'Dto', exceptions suffixed with 'Exception'
- Use PHP type hints and return type declarations on all interface methods to enforce contract compliance at runtime
- Implement centralized exception handler that maps domain exceptions to appropriate HTTP status codes and error response formats
- Document all public interfaces and DTOs with PHPDoc annotations including @api tag to clearly mark public contracts
- Consider implementing OpenAPI/Swagger specifications generated from interface definitions for external documentation

## Continuation Context


Verify commands:
- grep -r "class.*Dto" app/Domains --include="*.php" | wc -l
- grep -r "interface I[A-Z]" app/Domains --include="*.php" | wc -l
- grep -r "class.*Exception extends" app/Exceptions --include="*.php" | wc -l
- find app/Domains -name "*ViewHelper.php" -type f | wc -l

Accept when:
- All public API endpoints have corresponding interface definitions with explicit method signatures
- All API request/response payloads use dedicated DTO classes rather than exposing domain models
- All public API error conditions throw domain-specific exceptions with clear messages
- Grep commands show consistent presence of DTOs, interfaces, custom exceptions, and ViewHelpers across API-related code

## Enforcement

- Verified by: Automated static analysis tools checking for direct domain model exposure in API controllers
- Verified by: Code review checklist requiring interface definitions for all new public API endpoints
- Verified by: CI pipeline tests validating DTO serialization/deserialization contracts
- Verified by: Architecture decision review for new API endpoints and external integrations
- Violation handling: CI build fails if public API methods lack interface definitions or type hints
- Violation handling: Code review blocks merge if DTOs are not used for API boundaries
- Violation handling: Static analysis warnings escalated to errors for direct domain model exposure
- Violation handling: Quarterly architecture audits identify and remediate non-compliant API endpoints
- Exception process: Submit exception request to architecture review board with justification and impact analysis
- Exception process: Document exception in ADR exceptions registry with approval date and review timeline
- Exception process: Include migration plan for bringing non-compliant code into compliance within defined timeframe
- Exception process: Exceptions reviewed quarterly and automatically expire after 12 months unless renewed
# Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Non Compliant Dav

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all external API integrations involving contact synchronization via DAV/CardDAV protocols within domain-bounded contexts.

## Context

- The application requires synchronization with external contact management systems using industry-standard DAV/CardDAV protocols
- Contact data must be imported, exported, and synchronized across domain boundaries while maintaining data integrity and domain isolation
- External DAV servers may have varying levels of protocol compliance, requiring robust error handling and adapter patterns
- The Contact domain needs to interact with external systems through well-defined boundaries using DTOs and service abstractions
- VCard format is the standard interchange format for contact data in DAV/CardDAV ecosystems

## Problem Statement

How should the application architect external API integrations for contact synchronization using DAV/CardDAV protocols while maintaining clean domain boundaries, handling non-compliant servers, and ensuring data consistency across system boundaries?

## Decision

1. MUST: Non-compliant DAV server behaviors MUST be handled through explicit exception types (e.g., DavServerNotCompliantException) with clear error messaging

## Policy Block

- MUST Non-compliant DAV server behaviors MUST be handled through explicit exception types (e.g., DavServerNotCompliantException) with clear error messaging

In scope:
- All DAV/CardDAV protocol integrations for contact synchronization
- External API integrations requiring domain boundary enforcement
- VCard import/export operations across system boundaries
- Contact data synchronization with third-party DAV servers

Out of scope:
- Internal domain-to-domain communication within the application
- REST API endpoints for web/mobile clients
- Database-level data access patterns
- Non-contact related external integrations

Exceptions:
- EXC-001: Legacy DAV server integration requires direct database access for performance optimization

## Rationale

- Pattern detected across 8 files with 75.46% confidence indicates consistent architectural approach to external DAV/CardDAV integration
- Domain-driven design principles are enforced through dedicated DTO objects and service boundaries, preventing tight coupling between external systems and internal domain models
- Explicit exception handling for non-compliant servers demonstrates defensive programming practices necessary for real-world DAV server ecosystem variability
- Separation of import/export resources and use of interface contracts enables testability, maintainability, and future extensibility of external integrations

## Consequences

Positive:
- Clear domain boundaries prevent external API changes from cascading through the application
- DTO pattern enables independent evolution of internal domain models and external API contracts
- Interface-based backend implementations facilitate testing with mock DAV servers
- Explicit exception types improve error diagnostics and handling of non-compliant external systems
- ViewHelper pattern cleanly separates presentation concerns from domain logic

Negative:
- Additional abstraction layers (DTOs, interfaces, services) increase initial development complexity
- Mapping between DTOs and domain models introduces potential for synchronization bugs
- Multiple resource classes for import/export operations may lead to code duplication if not carefully managed
- Exception handling for non-compliant servers requires ongoing maintenance as DAV server behaviors evolve

## Alternatives

- Direct DAV library integration without domain service abstraction (rejected)
  Rejected because: Would tightly couple external DAV protocol details to domain logic, making testing difficult and violating domain boundary principles
  When valid: Only appropriate for throwaway prototypes or proof-of-concept implementations
- Generic API gateway pattern for all external integrations (rejected)
  Rejected because: DAV/CardDAV protocols have domain-specific semantics (VCard format, contact operations) that benefit from domain-aware service layers rather than generic gateways
  When valid: Could be reconsidered if the application needs to integrate with 10+ different external API types requiring unified authentication/rate limiting
- Event-driven asynchronous synchronization with message queues (deferred)
  Rejected because: Not rejected but deferred; current pattern supports synchronous operations which may be sufficient for initial requirements
  When valid: Should be adopted when synchronization volume exceeds 1000 contacts/minute or when offline-first capabilities are required

## Risks

- DAV server protocol variations may require extensive exception handling logic that becomes difficult to maintain
  Mitigation: Maintain comprehensive test suite with fixtures from known DAV server implementations (Nextcloud, Radicale, etc.); document known server quirks in wiki
  Owner: Integration team
- DTO mapping logic may become complex and error-prone as contact data model evolves
  Mitigation: Implement automated mapping tests; consider using mapping libraries (e.g., AutoMapper patterns) for complex transformations; version DTOs explicitly
  Owner: Domain team
- Performance overhead from multiple abstraction layers may impact synchronization speed for large contact sets
  Mitigation: Implement batch processing for bulk operations; add performance monitoring; establish SLAs for sync operations (e.g., 1000 contacts in <30s)
  Owner: Engineering team

## Implementation Notes

- Start by defining the IDAVBackend interface contract with clear method signatures for all DAV operations (connect, sync, import, export)
- Create DTO classes (ContactDto, ContactDeleteDto) with explicit validation rules and transformation methods to/from domain entities
- Implement ImportResource and ImportVCardResource classes with single responsibility for their respective import formats
- Add DavServerNotCompliantException and other specific exception types with detailed error messages including server response details for debugging
- Use ViewHelper classes to prepare data for presentation layers, keeping domain logic separate from view concerns
- Consider implementing a DAV server capability detection mechanism to handle known non-compliant servers gracefully

## Continuation Context


Verify commands:
- grep -r "class.*Dto" app/Domains/Contact/DavClient/Services/Utils/Model/ | wc -l
- grep -r "interface.*Backend" app/Domains/Contact/Dav/Web/Backend/ | grep -c "IDAVBackend"
- grep -r "DavServerNotCompliantException" app/Domains/Contact/DavClient/Services/Utils/Dav/ | wc -l
- find app/Domains/Contact/Dav -name "*Resource.php" -type f | wc -l

Accept when:
- At least 2 DTO classes exist in Contact domain DavClient services for data transfer
- IDAVBackend interface is defined and implemented by at least one concrete backend class
- DavServerNotCompliantException exists and is used in DAV client error handling
- Separate resource classes exist for import operations (ImportResource, ImportVCardResource)

## Enforcement

- Verified by: Automated architecture tests checking for DTO usage at domain boundaries
- Verified by: Code review checklist requiring interface contracts for all external integrations
- Verified by: Static analysis rules detecting direct DAV library usage outside service layers
- Verified by: CI pipeline verification commands checking for required pattern components
- Violation handling: CI build fails if external DAV calls are detected outside designated service layers
- Violation handling: Code review blocks merge if DTOs are not used for external data transfer
- Violation handling: Architecture review required for any new external integration patterns
- Violation handling: Quarterly architecture audits identify and remediate pattern violations
- Exception process: Submit exception request to architecture review board with justification and impact analysis
- Exception process: Document performance requirements or technical constraints preventing pattern compliance
- Exception process: Obtain approval from domain lead and architecture lead
- Exception process: Add technical debt ticket with migration plan to standard pattern
- Exception process: Review exception annually for continued validity
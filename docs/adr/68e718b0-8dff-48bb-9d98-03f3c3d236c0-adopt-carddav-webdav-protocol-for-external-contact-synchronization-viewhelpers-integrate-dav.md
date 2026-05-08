# Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Viewhelpers Integrate Dav

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all external contact synchronization integrations and DAV protocol implementations within the Contact domain.

## Context

- The application requires synchronization of contact data with external CardDAV/WebDAV servers to enable interoperability with third-party contact management systems
- Multiple files in the Contact domain implement DAV protocol handling, including import resources, backend interfaces, and client services for contact synchronization
- The system needs to handle vCard format imports and exports as the standard interchange format for contact data in DAV protocols
- External API integration requires robust error handling for non-compliant DAV servers and standardized DTOs for contact operations including create, update, and delete
- The architecture separates DAV client concerns from domain logic through dedicated service layers and backend abstractions

## Problem Statement

How should the application integrate with external contact management systems while maintaining data consistency, handling protocol compliance variations, and providing a clean separation between external API concerns and internal domain logic?

## Decision

1. MAY: ViewHelpers MAY integrate DAV synchronization status and controls into user interface components for vault and personalization features

## Policy Block

- MAY ViewHelpers MAY integrate DAV synchronization status and controls into user interface components for vault and personalization features

In scope:
- All contact synchronization with external CardDAV/WebDAV servers
- vCard import and export operations for contact data
- DAV backend interface implementations
- Contact DTO models for external API communication
- Error handling for non-compliant DAV servers

Out of scope:
- Internal contact storage and database operations
- REST API endpoints for web/mobile clients
- GraphQL APIs for internal services
- Non-DAV third-party integrations (OAuth-based APIs, webhooks)
- Real-time synchronization protocols (WebSocket, Server-Sent Events)

Exceptions:
- EX-001: Legacy contact import from proprietary formats (CSV, Excel) that cannot be converted to vCard
- EX-002: Emergency fallback to direct database operations when DAV server is persistently unavailable

## Rationale

- CardDAV/WebDAV are industry-standard protocols for contact synchronization, ensuring broad compatibility with existing contact management systems (Apple Contacts, Google Contacts, Thunderbird, etc.)
- The vCard format is the RFC-standardized interchange format for contact data, providing a well-defined schema that reduces integration complexity
- Separating DAV client concerns into dedicated services and DTOs creates clear architectural boundaries, making the codebase more maintainable and testable
- Pattern detection shows consistent implementation across 8 files with 75.46% confidence, indicating this is an established architectural pattern rather than an ad-hoc solution

## Consequences

Positive:
- Enables seamless integration with a wide ecosystem of CardDAV-compatible contact management systems without custom adapters
- Standardized vCard format reduces data transformation complexity and minimizes data loss during synchronization
- Clear separation of concerns through IDAVBackend interface and DTO models improves testability and allows mocking of external dependencies
- Explicit exception handling for non-compliant servers provides better diagnostics and user feedback during integration issues

Negative:
- CardDAV/WebDAV protocol complexity requires specialized knowledge and increases onboarding time for developers unfamiliar with these standards
- Dependency on external DAV server compliance means the application must handle various implementation quirks and non-standard behaviors
- vCard format limitations may not support all custom contact fields, requiring field mapping strategies or data loss acceptance
- Additional abstraction layers (backends, DTOs, services) increase code volume and may impact performance for high-frequency synchronization operations

## Alternatives

- Implement custom REST APIs for each third-party contact system integration (rejected)
  Rejected because: Would require maintaining multiple integration adapters, significantly increasing development and maintenance burden. CardDAV provides a single standard protocol that works across multiple systems.
  When valid: When integrating with systems that do not support CardDAV and have well-documented REST APIs with superior features
- Use OAuth-based contact APIs (Google People API, Microsoft Graph API) directly (rejected)
  Rejected because: Limits integration to specific vendors and requires separate OAuth flows for each provider. CardDAV provides vendor-neutral synchronization.
  When valid: When deep integration with specific platform features (Google Workspace, Microsoft 365) is required beyond basic contact synchronization
- Implement file-based import/export only (CSV, vCard files) without live synchronization (rejected)
  Rejected because: Does not support real-time or automated synchronization, requiring manual user intervention for every sync operation. CardDAV enables automated bidirectional sync.
  When valid: For one-time migration scenarios or when users explicitly prefer manual control over synchronization timing

## Risks

- External DAV servers may become unavailable or change their API implementations, breaking synchronization functionality
  Mitigation: Implement robust error handling with DavServerNotCompliantException, add retry logic with exponential backoff, and provide clear user notifications when synchronization fails. Monitor DAV server health and maintain fallback mechanisms.
  Owner: Engineering Team - External Integrations
- vCard format limitations may not accommodate all custom contact fields, leading to data loss during synchronization
  Mitigation: Document supported vCard fields clearly, implement field mapping validation, and provide warnings to users when custom fields cannot be synchronized. Consider using vCard extension fields (X-*) for custom data where appropriate.
  Owner: Engineering Team - Contact Domain
- Performance degradation during large-scale contact synchronization operations with slow or rate-limited DAV servers
  Mitigation: Implement batch processing with configurable batch sizes, add request throttling to respect server rate limits, use background job queues for large sync operations, and provide progress indicators to users.
  Owner: Engineering Team - Performance

## Implementation Notes

- Start by implementing the IDAVBackend interface for your target DAV server, ensuring all required CardDAV operations (PROPFIND, REPORT, GET, PUT, DELETE) are properly handled
- Use the ContactDto and ContactDeleteDto models consistently across all DAV client services to maintain type safety and enable easier testing with mock data
- Implement comprehensive error handling that distinguishes between network errors, authentication failures, and protocol compliance issues using DavServerNotCompliantException
- Create separate resource handlers (ImportResource, ImportVCardResource) to handle different import scenarios and maintain single responsibility principle
- Add integration tests that verify compatibility with major CardDAV implementations (Nextcloud, Radicale, Apple Calendar Server) to ensure broad compatibility

## Continuation Context


Verify commands:
- grep -r "IDAVBackend" app/Domains/Contact/Dav/ --include="*.php" | wc -l
- grep -r "ContactDto\|ContactDeleteDto" app/Domains/Contact/DavClient/ --include="*.php" | wc -l
- grep -r "DavServerNotCompliantException" app/Domains/Contact/ --include="*.php" | wc -l
- find app/Domains/Contact/Dav* -name "*Import*Resource.php" -o -name "*VCard*.php" | wc -l

Accept when:
- All DAV backend implementations implement the IDAVBackend interface (verify command returns > 0)
- Contact DTO models are consistently used across DavClient services (verify command returns >= 2 for both DTOs)
- DavServerNotCompliantException is present and used for error handling (verify command returns > 0)
- Import resource handlers exist for DAV and vCard operations (verify command returns >= 2)

## Enforcement

- Verified by: Automated static analysis checks for IDAVBackend interface implementation in all DAV backend classes
- Verified by: Code review checklist requiring verification of DTO usage in all external API communication
- Verified by: Integration test suite validating CardDAV protocol compliance with reference implementations
- Verified by: Architecture fitness functions checking namespace organization (DavClient separation from domain logic)
- Violation handling: CI pipeline fails if DAV backend classes do not implement IDAVBackend interface
- Violation handling: Pull requests are blocked if external API calls bypass DTO models and use raw arrays or stdClass objects
- Violation handling: Architecture review is triggered if new contact synchronization code is added outside the DavClient namespace
- Violation handling: Warning notifications are generated if DavServerNotCompliantException is not caught in DAV client service methods
- Exception process: Developer submits exception request with justification to Technical Lead via architecture decision log
- Exception process: Technical Lead reviews the request against policy exceptions (EX-001, EX-002) and architectural principles
- Exception process: If approved, exception is documented in ADR amendments with time-bound review date (max 6 months)
- Exception process: All exceptions are reviewed quarterly to determine if they should become permanent alternatives or be refactored to comply
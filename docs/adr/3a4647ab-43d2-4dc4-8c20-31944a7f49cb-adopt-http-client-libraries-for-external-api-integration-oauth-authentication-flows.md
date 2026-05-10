# Adopt HTTP Client Libraries for External API Integration: Oauth Authentication Flows

Status: proposed
Date: 2024-01-20
Deciders: Detection Pipeline (automated)

## Context

- The application integrates with multiple external services including OAuth providers (Socialite), Wikipedia API, DAV/CalDAV servers, and vCard/vCalendar standards
- External API communication requires robust HTTP client capabilities with support for authentication, headers, error handling, and various content types
- The codebase demonstrates consistent usage of HTTP client libraries across 7 files spanning authentication, contact management, DAV synchronization, and documentation setup
- Third-party service integration is a core feature requiring reliable, maintainable, and testable HTTP communication patterns
- The pattern shows integration with specialized libraries (Socialite for OAuth, Sabre for DAV/vCard) that abstract complex protocols over HTTP

## Problem Statement

The application needs a standardized approach for communicating with external APIs and services. Without established HTTP client libraries and integration patterns, developers may implement inconsistent solutions leading to duplicated code, poor error handling, security vulnerabilities, and difficulty in testing external service interactions. The system must support diverse integration scenarios including OAuth flows, RESTful APIs, WebDAV protocols, and structured data formats like vCard and vCalendar.

## Decision

1. MUST: OAuth authentication flows MUST utilize Laravel Socialite or equivalent OAuth client libraries

## Policy Block

- MUST OAuth authentication flows MUST utilize Laravel Socialite or equivalent OAuth client libraries

In scope:
- All outbound HTTP/HTTPS requests to external APIs and services
- OAuth provider integrations (Google, Facebook, GitHub, etc.)
- WebDAV, CalDAV, and CardDAV protocol communications
- Third-party REST API consumption (Wikipedia, documentation services, etc.)
- vCard and vCalendar data import/export operations

Out of scope:
- Internal service-to-service communication within the same application
- Database connections and queries
- File system operations
- Message queue or event bus communications
- WebSocket connections (unless using HTTP upgrade mechanism)

Exceptions:
- EXC-001: Legacy code maintenance where refactoring risk exceeds benefit
- EXC-002: Performance-critical scenarios where library overhead is demonstrably prohibitive

## Rationale

- Pattern detected across 7 files with 79.90% confidence indicates established architectural practice for external service integration
- Using specialized libraries (Socialite, Sabre DAV) reduces implementation complexity and ensures protocol compliance with OAuth, WebDAV, vCard, and vCalendar standards
- HTTP client libraries provide built-in features for authentication, error handling, retry logic, and testing that would be costly to implement manually
- Standardizing on established libraries improves code maintainability, reduces security vulnerabilities, and enables easier testing through mocking and stubbing capabilities

## Consequences

Positive:
- Reduced development time for new external API integrations through reusable patterns and libraries
- Improved security posture through battle-tested authentication and transport layer implementations
- Enhanced testability via HTTP client mocking and stubbing capabilities
- Better error handling and resilience with built-in retry, timeout, and circuit breaker patterns
- Simplified maintenance through well-documented, community-supported libraries

Negative:
- Additional dependency management overhead and potential version conflicts between libraries
- Learning curve for developers unfamiliar with specific libraries (Socialite, Sabre DAV)
- Potential performance overhead from library abstractions in high-throughput scenarios
- Risk of library abandonment or breaking changes requiring migration efforts

## Alternatives

- Implement custom HTTP client wrapper using raw PHP cURL or streams (rejected)
  Rejected because: Requires significant development effort to replicate features like authentication, error handling, and testing utilities already provided by established libraries. Increases maintenance burden and security risk.
  When valid: Only valid for extremely performance-critical scenarios where library overhead is demonstrably prohibitive (requires benchmarking)
- Use a single universal HTTP client (e.g., Guzzle) for all external communications without specialized protocol libraries (rejected)
  Rejected because: Complex protocols like OAuth, WebDAV, vCard, and vCalendar require significant domain knowledge and implementation effort. Specialized libraries provide standards compliance and reduce error-prone custom implementations.
  When valid: Acceptable for simple REST API integrations that don't require complex protocol handling
- Adopt microservices pattern with dedicated integration services for each external API (deferred)
  Rejected because: Adds architectural complexity and operational overhead that may not be justified for current scale. Could be reconsidered as integration complexity grows.
  When valid: When external API integration logic becomes sufficiently complex to warrant service isolation, or when multiple applications need shared integration capabilities

## Risks

- Library vulnerabilities or abandonment requiring emergency migration
  Mitigation: Regularly audit dependencies for security issues, monitor library maintenance status, and maintain abstraction layers that isolate library-specific code
  Owner: Engineering Team
- Performance degradation from library overhead in high-throughput scenarios
  Mitigation: Establish performance baselines, implement monitoring for external API call latency, and profile critical paths to identify bottlenecks early
  Owner: Engineering Team
- Inconsistent library usage patterns across the codebase leading to maintenance challenges
  Mitigation: Document standard integration patterns, provide code examples and templates, conduct code reviews focusing on external API integration patterns
  Owner: Engineering Team

## Implementation Notes

- Wrap HTTP client library usage in service classes (e.g., WikipediaHelper, DavClient) to encapsulate external API logic and provide domain-specific interfaces
- Configure HTTP clients with appropriate timeouts, retry policies, and error handling strategies based on the reliability requirements of each external service
- Use dependency injection to provide HTTP client instances, enabling easy mocking in unit tests and configuration flexibility across environments
- Document authentication patterns for each integration type (OAuth, Basic Auth, API keys) with examples in the codebase
- Implement logging and monitoring for external API calls to track performance, errors, and usage patterns

## Continuation Context


Verify commands:
- grep -r "use.*Socialite" app/ --include="*.php" | wc -l
- grep -r "use.*Sabre" app/ --include="*.php" | wc -l
- grep -r "curl_exec\|fsockopen" app/ --include="*.php" | wc -l

Accept when:
- Socialite library usage is detected in OAuth authentication flows
- Sabre DAV/VObject libraries are used for DAV protocol and vCard/vCalendar operations
- No raw cURL or socket implementations are found in new external API integration code
- Service classes encapsulate HTTP client library usage with clear domain interfaces

## Enforcement

- Verified by: Automated code review checks scanning for raw HTTP implementation patterns (curl_exec, fsockopen)
- Verified by: Dependency analysis ensuring approved HTTP client libraries are present in composer.json
- Verified by: Manual code review focusing on external API integration patterns and library usage
- Verified by: Unit test coverage requirements for service classes wrapping external API calls
- Violation handling: CI pipeline fails if raw HTTP implementations are detected in new code without documented exceptions
- Violation handling: Code review process flags non-compliant external API integrations for revision
- Violation handling: Technical debt tickets created for legacy code that doesn't comply, prioritized based on risk assessment
- Exception process: Developer submits exception request with performance benchmarks or technical justification to Technical Lead
- Exception process: Technical Lead reviews request and approves/rejects with documented rationale
- Exception process: Approved exceptions are documented in code comments with issue tracking reference and future migration plan
- Exception process: Exception registry is maintained and reviewed quarterly to identify patterns requiring policy updates
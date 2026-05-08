# Standardize Exception and Logging Formatting for External API Responses: Exception Classes Include

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all external API endpoints and exception handling components. All new exception classes and logging utilities MUST comply with the formatting standards defined herein.

## Context

- The codebase contains multiple exception classes (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException) and logging utilities (Loggable) that share a common formatting pattern (facet: style.formatter)
- External APIs require consistent, predictable error response formats to enable reliable client-side error handling and debugging
- The detected pattern (signature: 62cc4253c1e5a88e7a13809b986440a0) appears in 3 files with 77.77% confidence, indicating a deliberate architectural choice for API response formatting
- Standardized formatting across exceptions and logging improves API consumer experience, reduces integration friction, and enables automated error handling
- The pattern suggests a unified approach to structuring error messages, HTTP status codes, and contextual information for external API consumers

## Problem Statement

Without a standardized formatting approach for exceptions and logging in external APIs, clients receive inconsistent error responses that are difficult to parse programmatically. This leads to fragile error handling logic, poor debugging experiences, and increased support burden. The system needs a consistent formatter pattern that ensures all API errors and logs follow a predictable structure.

## Decision

1. MAY: Exception classes MAY include additional domain-specific fields in the formatted response if they enhance client-side error handling

## Policy Block

- MAY Exception classes MAY include additional domain-specific fields in the formatted response if they enhance client-side error handling

In scope:
- All custom exception classes that can be thrown from external API endpoints
- Logging utilities and traits used within API request/response lifecycle
- Error response middleware and exception handlers for public APIs
- API documentation and OpenAPI specifications describing error formats

Out of scope:
- Internal service-to-service communication errors (may use different formats)
- CLI command error output formatting
- Background job failure handling (unless exposed via API)
- Development/debug mode error pages (may include additional details)

Exceptions:
- EXC-001: Legacy API versions (v1, v2) that have established error formats with existing client dependencies
- EXC-002: Third-party library exceptions that cannot be wrapped without significant performance impact

## Rationale

- The pattern detected across 3 files (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException, Loggable) with 77.77% confidence indicates an intentional architectural decision to standardize formatting
- Consistent error formatting is a best practice for external APIs, enabling clients to implement robust error handling without parsing multiple response formats
- The facet 'style.formatter' suggests these components share formatting logic, which reduces code duplication and ensures maintainability
- Standardized logging and exception formatting improves observability by making it easier to correlate API errors with internal logs and metrics

## Consequences

Positive:
- API consumers can implement reliable, type-safe error handling with predictable response structures
- Reduced support burden as error messages are consistent and well-documented
- Improved debugging and monitoring through standardized log formats that integrate with observability tools
- Easier API versioning and evolution as the formatter pattern can be extended without breaking existing clients

Negative:
- Additional development overhead to ensure all new exceptions implement the formatter pattern
- Potential performance impact from formatting logic, though typically negligible
- May require refactoring existing exception classes that don't follow the pattern
- Formatter abstraction adds a layer of indirection that developers must understand and maintain

## Alternatives

- Use framework default exception handling without custom formatters (rejected)
  Rejected because: Framework defaults often expose too much internal detail and lack consistency across different exception types, making them unsuitable for external APIs
  When valid: For internal tools or admin interfaces where detailed error information is beneficial
- Implement formatting logic directly in each exception class without shared trait/interface (rejected)
  Rejected because: Leads to code duplication and inconsistency as each exception may format differently, defeating the purpose of standardization
  When valid: Never recommended for external APIs; only acceptable for one-off internal exceptions
- Use a centralized exception handler middleware that formats all exceptions uniformly (deferred)
  When valid: Could be used in combination with the formatter pattern to provide a fallback for unexpected exceptions; worth evaluating as a complementary approach

## Risks

- Inconsistent adoption across teams leading to mixed error formats in production
  Mitigation: Implement automated tests and linters that verify exception classes implement required formatter interface; include in code review checklist
  Owner: API Architecture Team
- Formatter pattern may inadvertently expose sensitive information if not carefully implemented
  Mitigation: Establish security review process for all formatter implementations; create sanitization utilities and guidelines for contextual data
  Owner: Security Team
- Breaking changes to formatter structure could impact existing API clients
  Mitigation: Version the formatter schema; use API versioning to introduce changes gradually; maintain backward compatibility for at least two major versions
  Owner: Engineering Team

## Implementation Notes

- Create a base Formattable interface or trait that all API exceptions must implement, defining methods like toArray(), toJson(), and getHttpStatusCode()
- Establish a standard error response schema (e.g., {error: {code, message, status, timestamp, context}}) and document it in OpenAPI specifications
- Refactor existing exception classes (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException) to serve as reference implementations
- Update the Loggable trait to use the same formatting methods, ensuring logs and API responses are structurally consistent
- Create generator/scaffold commands for new exception classes that automatically include the formatter implementation

## Continuation Context


Verify commands:
- grep -r "class.*Exception" app/ | xargs -I {} sh -c 'grep -l "Formattable\|toArray\|toJson" {}'
- php artisan test --filter ExceptionFormatterTest
- grep -r "use.*Loggable" app/ | xargs -I {} sh -c 'grep -l "format\|toArray" {}'

Accept when:
- All exception classes in app/Exceptions/ that are thrown from API routes implement the Formattable interface or equivalent formatter trait
- Automated tests verify that exception responses match the documented JSON schema with required fields (code, message, status, timestamp)
- The Loggable trait and all exception formatters produce structurally consistent output as verified by integration tests

## Enforcement

- Verified by: Automated CI pipeline tests that validate exception response formats against JSON schema
- Verified by: Static analysis tools (PHPStan/Psalm) configured to require Formattable interface on exception classes
- Verified by: Code review checklist requiring verification of formatter implementation for new exceptions
- Verified by: API contract tests that validate error response structures
- Violation handling: CI pipeline fails if exception classes lack required formatter interface
- Violation handling: Code review blocks merge if new exceptions don't follow formatting standards
- Violation handling: Runtime monitoring alerts on non-standard error responses in production
- Violation handling: Quarterly audits identify and remediate non-compliant exception classes
- Exception process: Submit exception request to API Architecture Team with justification and impact analysis
- Exception process: Security review required if exception involves sensitive data or third-party libraries
- Exception process: Document approved exceptions in ADR amendments with expiration date and migration plan
- Exception process: Re-review exceptions annually to determine if they can be brought into compliance
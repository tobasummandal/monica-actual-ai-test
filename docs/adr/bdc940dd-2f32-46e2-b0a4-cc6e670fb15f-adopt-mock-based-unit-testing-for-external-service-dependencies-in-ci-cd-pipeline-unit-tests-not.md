# Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Unit Tests Not

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Context

- The codebase contains extensive unit tests for DavClient services, jobs, and utilities that interact with external CardDAV/WebDAV services for contact synchronization
- Unit tests require isolation from external dependencies to ensure fast, reliable, and deterministic execution in CI/CD pipelines
- The testing.mocking facet indicates a consistent pattern of using test doubles (mocks, stubs, fakes) to simulate external service behavior
- 12 test files across the Contact/DavClient domain demonstrate a standardized approach to testing external service integrations
- CI/CD pipeline reliability depends on tests that can run without network access, external service availability, or authentication credentials

## Problem Statement

Unit tests that depend on real external services (CardDAV servers, WebDAV endpoints, authentication providers) create brittle CI/CD pipelines that fail due to network issues, service downtime, rate limiting, or credential management problems. Without a consistent mocking strategy, tests become slow, non-deterministic, and difficult to maintain, reducing developer confidence and pipeline reliability.

## Decision

1. MUST: Unit tests MUST NOT require network connectivity, external service availability, or real credentials to execute successfully

## Policy Block

- MUST Unit tests MUST NOT require network connectivity, external service availability, or real credentials to execute successfully

In scope:
- Unit tests for HTTP clients, API wrappers, and service integrations
- Tests for jobs and background workers that call external services
- Tests for synchronization utilities that interact with remote data sources
- Tests for authentication and authorization flows involving external providers

Out of scope:
- Integration tests explicitly designed to verify real service connectivity
- End-to-end tests that validate full system behavior
- Smoke tests run against staging or production environments
- Performance tests that measure real network latency and throughput

Exceptions:
- EXC-001: Testing framework-level HTTP client configuration or connection pooling behavior that cannot be adequately simulated

## Rationale

- Pattern detected across 12 test files with 81.12% confidence indicates this is an established and consistent practice in the codebase
- Mock-based testing enables fast test execution (milliseconds vs seconds) which is critical for CI/CD pipeline performance and developer feedback loops
- Isolation from external dependencies eliminates flaky tests caused by network issues, service outages, rate limiting, or authentication failures
- Mocking allows testing of error conditions and edge cases that are difficult or impossible to reproduce with real external services

## Consequences

Positive:
- CI/CD pipelines run faster and more reliably without external service dependencies
- Tests can run in any environment (local development, CI servers, air-gapped networks) without configuration
- Developers can test error handling and edge cases without manipulating external service state
- Test suite becomes deterministic and reproducible, improving debugging and confidence

Negative:
- Mocks can diverge from real service behavior if not kept in sync with API changes
- Over-mocking can lead to tests that pass but fail in production due to incorrect assumptions
- Additional effort required to maintain mock objects and update them when external APIs change
- Risk of false confidence if integration tests are not also maintained to validate real service interactions

## Alternatives

- Use real external services in all tests with test-specific accounts and data (rejected)
  Rejected because: Creates slow, brittle tests that fail due to network issues, service downtime, and rate limiting. Requires complex credential management and test data cleanup. Not feasible for offline development or secure CI environments.
  When valid: Only appropriate for dedicated integration test suites run in separate CI stages with appropriate timeouts and retry logic
- Use containerized mock servers (e.g., WireMock, MockServer) that simulate external APIs (deferred)
  Rejected because: Adds infrastructure complexity and container orchestration overhead. May be considered for complex multi-service integration scenarios.
  When valid: When testing complex multi-step workflows that require stateful service interactions or when contract testing is required
- Use recorded HTTP fixtures (VCR pattern) to capture and replay real service responses (deferred)
  Rejected because: Fixtures become stale and require periodic re-recording. Adds maintenance burden and storage overhead for large response payloads.
  When valid: Useful as a complement to mocks for validating that mock behavior matches real service responses

## Risks

- Mock drift: Mocks diverge from real external service behavior as APIs evolve, causing tests to pass while production code fails
  Mitigation: Maintain integration test suite that validates real service interactions. Use contract testing tools to verify mock behavior. Review and update mocks during dependency upgrades.
  Owner: Engineering team with support from QA
- Over-mocking leads to tests that verify mock interactions rather than business logic, reducing test value
  Mitigation: Focus mock assertions on critical interactions. Use behavior verification sparingly. Prefer state-based testing where possible. Code review should check for excessive mock complexity.
  Owner: Development team during code review
- Developers may skip integration tests entirely, relying solely on mocked unit tests
  Mitigation: Establish clear testing pyramid guidelines. Require integration tests for critical external service interactions. Include integration test coverage in CI/CD quality gates.
  Owner: Tech leads and CI/CD pipeline maintainers

## Implementation Notes

- Use the testing framework's native mocking capabilities (PHPUnit's createMock/getMockBuilder for PHP projects) for consistency
- Create reusable mock factories or test helpers for commonly mocked external services to reduce duplication
- Document expected external service behavior in test comments to help future maintainers understand mock setup
- Organize tests into clear unit test and integration test directories with separate CI/CD execution stages
- Consider using builder patterns or fluent interfaces for complex mock setup to improve test readability

## Continuation Context


Verify commands:
- grep -r "new.*Client\|->connect\|->request" tests/Unit/ | grep -v "Mock\|Stub\|Fake" | wc -l
- find tests/Unit -name '*Test.php' -exec grep -l 'createMock\|getMockBuilder\|shouldReceive' {} \; | wc -l
- phpunit --testsuite=unit --no-coverage --testdox | grep -i 'network\|connection\|timeout' || echo 'No network-dependent tests found'

Accept when:
- Unit tests execute successfully without network connectivity (verified by running tests with network disabled)
- Unit test suite completes in under 30 seconds for typical project size, indicating no real external service calls
- Grep verification shows that unit tests use mock/stub/fake patterns for external service dependencies
- CI/CD pipeline unit test stage has >95% success rate over 30-day period, indicating stable, non-flaky tests

## Enforcement

- Verified by: Automated CI/CD pipeline checks that unit tests complete within time thresholds (e.g., <30s)
- Verified by: Code review checklist includes verification that new unit tests use appropriate mocking for external dependencies
- Verified by: Static analysis or linting rules detect direct instantiation of HTTP clients or external service classes in unit test files
- Verified by: Periodic manual review of test suite structure and organization
- Violation handling: CI/CD pipeline fails if unit tests exceed execution time threshold, indicating potential real service calls
- Violation handling: Code review blocks merge if unit tests contain direct external service calls without documented exception approval
- Violation handling: Tech lead review required for any unit test that requires network access or external credentials
- Violation handling: Quarterly test suite audit identifies and refactors tests that violate mocking standards
- Exception process: Developer documents specific technical reason why mocking is insufficient in test file comments
- Exception process: Tech lead reviews exception request and approves if justified (e.g., testing framework-level behavior)
- Exception process: Exception is tracked in technical debt register with plan for future resolution if possible
- Exception process: Exceptional tests are clearly marked and isolated to prevent pattern spread
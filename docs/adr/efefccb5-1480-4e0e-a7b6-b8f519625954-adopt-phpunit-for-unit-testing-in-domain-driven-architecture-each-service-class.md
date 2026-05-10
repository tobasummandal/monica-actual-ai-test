# Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Each Service Class

Status: proposed
Date: 2024-01-20
Deciders: Detection Pipeline (automated)

## Context

- The codebase follows a domain-driven design architecture with clear separation between domains (Settings, ManageTemplates, ManageUserPreferences, ManageUsers)
- Unit tests are organized to mirror the domain structure, with tests located in tests/Unit/Domains/ following the same hierarchy as application code
- The application requires comprehensive testing coverage for service layer components, API controllers, and view helpers across multiple domains
- PHPUnit has been adopted as the standard testing framework, evidenced by 17 test files following consistent naming conventions (*Test.php)
- The testing strategy emphasizes isolated unit tests for individual services and components rather than integration tests

## Problem Statement

The project requires a standardized approach to unit testing that supports domain-driven architecture, enables CI/CD automation, provides consistent test structure across multiple domains, and ensures reliable verification of business logic in service classes, controllers, and view helpers.

## Decision

1. SHOULD: Each service class, controller, and view helper SHOULD have a corresponding unit test file

## Policy Block

- SHOULD Each service class, controller, and view helper SHOULD have a corresponding unit test file

In scope:
- Unit tests for service layer components in all domains
- Unit tests for API controllers
- Unit tests for web view helpers
- Tests for user preference management services
- Tests for template management services
- Tests for user management components

Out of scope:
- Integration tests requiring database connections
- End-to-end tests requiring full application stack
- Browser-based functional tests
- Performance and load tests
- Third-party library tests

## Rationale

- PHPUnit is the de facto standard testing framework for PHP applications with mature tooling, extensive documentation, and strong CI/CD integration support
- The pattern shows consistent adoption across 17 test files with 79.47% confidence, indicating an established and deliberate architectural choice
- Domain-driven architecture benefits from structured unit testing that mirrors the domain hierarchy, making tests easier to locate and maintain
- Automated testing in CI/CD pipelines is essential for maintaining code quality and preventing regressions in a multi-domain application

## Consequences

Positive:
- Consistent testing approach across all domains reduces cognitive load and improves developer productivity
- Automated test execution in CI/CD pipelines catches regressions early in the development cycle
- Clear test organization mirroring domain structure makes it easy to locate and update tests
- PHPUnit's mature ecosystem provides extensive mocking, assertion, and reporting capabilities
- Isolated unit tests execute quickly, enabling rapid feedback during development

Negative:
- PHPUnit requires additional dependency management and version compatibility maintenance
- Developers must learn PHPUnit-specific syntax and conventions
- Maintaining parallel directory structures between application code and tests increases organizational overhead
- Unit tests alone may miss integration issues between components
- Mock-heavy tests can become brittle and require updates when implementation details change

## Alternatives

- Use Pest PHP as the testing framework instead of PHPUnit (rejected)
  Rejected because: PHPUnit is already established with 17 existing test files; migration would require significant refactoring effort without clear benefits for this codebase
  When valid: For greenfield projects or when the team strongly prefers Pest's more expressive syntax
- Organize tests by type (services, controllers, helpers) rather than by domain (rejected)
  Rejected because: Domain-driven architecture benefits from keeping tests aligned with domain boundaries, making it easier to understand and maintain domain-specific logic
  When valid: For applications without clear domain boundaries or with cross-cutting concerns that don't fit domain structure
- Combine unit and integration tests in the same test suite (rejected)
  Rejected because: Separating unit tests from integration tests allows for faster feedback loops and clearer test purposes
  When valid: For smaller applications where the distinction between unit and integration tests provides minimal value

## Risks

- Test coverage may be incomplete if developers skip writing tests for new components
  Mitigation: Implement CI/CD checks that enforce minimum code coverage thresholds and require tests for new code
  Owner: Engineering team and CI/CD pipeline maintainers
- Over-reliance on mocking may lead to tests that pass but don't reflect real-world behavior
  Mitigation: Complement unit tests with integration tests and establish guidelines for when to use mocks versus real dependencies
  Owner: Engineering team and technical leads
- PHPUnit version updates may introduce breaking changes requiring test refactoring
  Mitigation: Pin PHPUnit versions in composer.json, test upgrades in isolated branches, and maintain upgrade documentation
  Owner: DevOps and engineering team

## Implementation Notes

- Install PHPUnit via Composer and configure phpunit.xml with appropriate test suites and directory mappings
- Establish a test template or generator to ensure consistent test structure across domains
- Configure CI/CD pipeline to run PHPUnit tests on every commit and pull request
- Set up code coverage reporting to track test coverage metrics over time
- Document testing conventions in project README or contributing guidelines
- Consider using PHPUnit data providers for testing multiple scenarios with the same test logic

## Continuation Context


Verify commands:
- find tests/Unit/Domains -name '*Test.php' -type f | wc -l
- grep -r 'use PHPUnit\\Framework\\TestCase' tests/Unit/Domains/ | wc -l
- vendor/bin/phpunit --testsuite=unit --testdox

Accept when:
- All test files in tests/Unit/Domains/ follow the {ClassName}Test.php naming convention
- PHPUnit test execution completes successfully with all tests passing
- Test directory structure mirrors the application domain hierarchy under tests/Unit/Domains/

## Enforcement

- Verified by: CI/CD pipeline automated test execution on every commit
- Verified by: Code review process verifying test presence for new components
- Verified by: Static analysis tools checking test file naming conventions
- Verified by: Code coverage reports generated during CI builds
- Violation handling: CI/CD pipeline fails if PHPUnit tests fail or coverage drops below threshold
- Violation handling: Pull requests without corresponding tests are flagged during code review
- Violation handling: Automated checks reject commits that don't follow test naming conventions
- Violation handling: Technical debt is tracked for components missing unit tests
- Exception process: Exceptions for legacy code without tests must be documented in technical debt backlog
- Exception process: New code exceptions require approval from technical lead with justification
- Exception process: Temporary exceptions must include a remediation plan and timeline
- Exception process: All exceptions are reviewed quarterly for resolution
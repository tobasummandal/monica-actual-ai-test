# Standardize Unit and Feature Test Organization in CI/CD Pipeline: Unit Tests Placed

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase contains a structured test suite with clear separation between Unit tests and Feature tests, indicating a mature testing strategy
- Test files are organized by domain boundaries (Contact, DAV, Jetstream) suggesting a domain-driven architecture that requires consistent test organization
- Multiple test files focus on DAV/CardDAV services and VCard operations, indicating critical integration points that need reliable CI/CD validation
- The presence of both unit tests (isolated component testing) and feature tests (end-to-end scenarios) demonstrates a comprehensive testing approach that must be maintained in the CI/CD pipeline
- Test organization follows Laravel conventions with tests/Unit and tests/Feature directories, establishing a framework-aligned pattern

## Problem Statement

Without standardized test organization and execution in the CI/CD pipeline, teams may inconsistently run tests, miss critical test suites, or fail to maintain the separation between unit and feature tests. This can lead to slower feedback loops, unreliable builds, and difficulty identifying whether failures are at the unit or integration level.

## Decision

1. MUST: All unit tests MUST be placed in the tests/Unit directory and organized by domain boundaries

## Policy Block

- MUST All unit tests MUST be placed in the tests/Unit directory and organized by domain boundaries

In scope:
- All PHP test files in tests/Unit and tests/Feature directories
- CI/CD pipeline configuration files (e.g., .github/workflows, .gitlab-ci.yml, phpunit.xml)
- Test execution scripts and automation tools
- PHPUnit configuration and test suite definitions

Out of scope:
- Manual testing procedures and QA processes
- End-to-end browser testing frameworks (e.g., Selenium, Cypress)
- Performance and load testing suites
- Third-party package tests within vendor directories

Exceptions:
- EX-001: Legacy tests that predate this standard and require significant refactoring
- EX-002: Experimental or spike tests that are explicitly marked as temporary

## Rationale

- The detected pattern shows 8 test files with 79.25% confidence, demonstrating a consistent and established testing structure that should be formalized
- Clear separation between unit and feature tests enables faster feedback loops by running isolated tests first before expensive integration tests
- Domain-organized test structure (Contact/DAV/Jetstream) aligns with domain-driven design principles and improves test maintainability
- Standardizing test organization in CI/CD ensures all developers follow the same conventions, reducing onboarding time and preventing test suite fragmentation

## Consequences

Positive:
- Faster CI/CD feedback loops by running unit tests first and failing fast on isolated component issues
- Improved test discoverability and maintainability through consistent directory structure and naming conventions
- Better separation of concerns between unit-level and integration-level testing
- Reduced build times through potential parallelization of test suites
- Easier debugging by clearly identifying whether failures occur at unit or feature level

Negative:
- Requires discipline to maintain proper test categorization as unit vs feature tests
- May require refactoring of existing tests that don't follow the established structure
- Potential for confusion about edge cases (e.g., integration tests that aren't full features)
- Additional CI/CD configuration complexity to manage multiple test suite executions

## Alternatives

- Single flat tests directory without unit/feature separation (rejected)
  Rejected because: Loses the ability to run fast unit tests separately from slower feature tests, resulting in longer feedback loops and reduced developer productivity
  When valid: Only appropriate for very small projects with fewer than 50 tests
- Three-tier structure with tests/Unit, tests/Integration, and tests/Feature (rejected)
  Rejected because: Adds complexity without clear benefit given the current codebase structure; the unit/feature distinction is sufficient for current needs
  When valid: May be reconsidered if the project grows to require explicit integration test categorization separate from features
- Co-locate tests with source code in src directories (rejected)
  Rejected because: Conflicts with Laravel framework conventions and makes it harder to exclude tests from production builds
  When valid: Not applicable for Laravel-based projects

## Risks

- Developers may incorrectly categorize tests as unit tests when they are actually feature tests, leading to slow unit test suites
  Mitigation: Provide clear guidelines and examples in documentation; implement code review checklist items for test categorization; consider automated checks for common anti-patterns (e.g., unit tests that hit the database)
  Owner: Engineering Team Lead
- CI/CD pipeline changes may break existing workflows or increase build times unexpectedly
  Mitigation: Implement changes incrementally; monitor build times before and after; maintain rollback capability; test pipeline changes in feature branches first
  Owner: DevOps Team
- Legacy tests may not fit cleanly into unit/feature categories, requiring significant refactoring effort
  Mitigation: Use exception process for legacy tests; create migration plan with prioritization; refactor incrementally during normal feature work
  Owner: Engineering Team

## Implementation Notes

- Update PHPUnit configuration (phpunit.xml) to define separate test suites for 'unit' and 'feature' with appropriate directory mappings
- Modify CI/CD pipeline configuration to execute unit tests first (php artisan test --testsuite=unit) followed by feature tests (php artisan test --testsuite=feature)
- Create or update CONTRIBUTING.md with clear guidelines on when to write unit vs feature tests, including examples from the existing codebase
- Consider adding a pre-commit hook or CI check that validates test file locations match their namespace and test type
- Document the domain structure (Contact/DAV/Jetstream) and encourage new tests to follow the same organizational pattern

## Continuation Context


Verify commands:
- grep -r "class.*Test extends" tests/Unit/ | wc -l
- grep -r "class.*Test extends" tests/Feature/ | wc -l
- php artisan test --testsuite=unit --stop-on-failure
- php artisan test --testsuite=feature --stop-on-failure

Accept when:
- Both unit and feature test directories exist and contain test files following the *Test.php naming convention
- PHPUnit configuration defines separate test suites for unit and feature tests
- CI/CD pipeline successfully executes both test suites sequentially (unit first, then feature) on every commit
- All tests pass in both suites without errors or warnings

## Enforcement

- Verified by: Automated CI/CD pipeline checks that fail builds if tests are not properly organized
- Verified by: Code review checklist requiring verification of test placement and categorization
- Verified by: PHPUnit test suite execution reports showing separate unit and feature test results
- Verified by: Static analysis tools checking for test file naming conventions and directory structure
- Violation handling: CI/CD pipeline fails if tests are placed in incorrect directories or don't follow naming conventions
- Violation handling: Pull requests are blocked until test organization issues are resolved
- Violation handling: Automated comments on PRs highlighting test organization violations with links to documentation
- Violation handling: Monthly audit reports identifying non-compliant tests for remediation
- Exception process: Developer submits exception request via ADR amendment or GitHub issue with justification
- Exception process: Tech Lead reviews exception request and approves/rejects within 2 business days
- Exception process: Approved exceptions are documented in the codebase with TODO comments and tracked in project management system
- Exception process: All exceptions are reviewed quarterly to determine if they can be resolved or need extension
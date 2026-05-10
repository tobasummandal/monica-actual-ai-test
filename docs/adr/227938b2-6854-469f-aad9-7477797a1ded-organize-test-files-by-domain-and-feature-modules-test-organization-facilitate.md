# Organize Test Files by Domain and Feature Modules: Test Organization Facilitate

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase follows a domain-driven design approach with clear separation between business domains (Settings, ManageTemplates, ManageUserPreferences, ManageUsers)
- Test files mirror the production code structure with a parallel hierarchy under tests/Unit/Domains/, maintaining consistent naming conventions
- Multiple feature modules exist within each domain (ManageTemplates, ManageUserPreferences, ManageUsers) that require isolated testing
- The test organization supports CI/CD pipelines by enabling selective test execution based on domain or module boundaries
- A consistent module boundary convention emerged across 17 test files with 79.47% confidence, indicating a deliberate architectural pattern

## Problem Statement

Without a standardized approach to organizing test files by domain and feature modules, test suites become difficult to navigate, selective test execution becomes challenging, and the relationship between tests and production code becomes obscured, hindering CI/CD efficiency and developer productivity.

## Decision

1. SHOULD: Test organization SHOULD facilitate parallel test execution by allowing independent domain or module test runs

## Policy Block

- SHOULD Test organization SHOULD facilitate parallel test execution by allowing independent domain or module test runs

In scope:
- All unit test files under tests/Unit/Domains/
- Integration tests that follow domain-driven organization
- Feature module test suites within Settings and other domains
- CI/CD pipeline test execution strategies

Out of scope:
- End-to-end tests that span multiple domains
- Legacy test files not yet migrated to domain structure
- Third-party package tests
- Performance or load tests with different organizational needs

Exceptions:
- EXC-001: Shared test utilities or base test classes that serve multiple domains
- EXC-002: Migration period for legacy tests being refactored into domain structure

## Rationale

- The pattern was detected across 17 test files with 79.47% confidence, indicating widespread adoption and consistency in the codebase
- Domain-driven test organization directly supports CI/CD efficiency by enabling targeted test execution, reducing pipeline duration when only specific domains are modified
- Mirroring production code structure in tests improves discoverability and maintainability, reducing cognitive load for developers navigating between production and test code
- Module boundary conventions facilitate parallel test execution and support microservices or modular monolith architectures where domains may be deployed independently

## Consequences

Positive:
- Improved test discoverability through predictable, hierarchical organization matching production code structure
- Enhanced CI/CD pipeline efficiency through selective test execution based on changed domains or modules
- Better support for parallel test execution, reducing overall test suite runtime
- Clearer ownership and responsibility boundaries for test maintenance aligned with domain teams
- Simplified navigation between production code and corresponding tests

Negative:
- Deeper directory hierarchies may increase path length and complexity for deeply nested modules
- Refactoring production code structure requires corresponding test file reorganization
- Initial migration effort required for existing tests not following the convention
- Potential for duplicate test utilities across domains if shared testing infrastructure is not properly abstracted

## Alternatives

- Flat test directory structure with all tests in a single directory organized by test type only (rejected)
  Rejected because: Does not scale well with codebase growth, makes selective test execution difficult, and obscures the relationship between tests and production code domains
  When valid: Only suitable for very small projects with fewer than 50 test files
- Organize tests by test type first (Unit, Integration, E2E) without domain subdivision (rejected)
  Rejected because: Breaks the connection between domain boundaries and test organization, making domain-specific test execution and ownership unclear
  When valid: May be appropriate for projects without clear domain boundaries or using a transaction script architecture
- Co-locate tests with production code in the same directory structure (deferred)
  Rejected because: Not rejected but deferred; requires different build and deployment configurations to exclude tests from production artifacts
  When valid: Valid for projects using languages/frameworks with strong conventions for co-located tests (e.g., Go, Rust)

## Risks

- Deep directory nesting may exceed filesystem path length limits on some operating systems or CI environments
  Mitigation: Monitor path lengths during code review; establish maximum nesting depth guidelines (e.g., 6-7 levels); use shorter domain/module names where possible
  Owner: Engineering team and CI/CD maintainers
- Inconsistent application of the pattern across teams may lead to fragmented test organization
  Mitigation: Implement automated checks in CI to verify test file locations match production code structure; provide clear documentation and examples; conduct team training
  Owner: Engineering team leads
- Large-scale refactoring of production code domains may require extensive test file reorganization
  Mitigation: Use automated refactoring tools and scripts to move test files in sync with production code; include test reorganization in refactoring effort estimates
  Owner: Development team performing refactoring

## Implementation Notes

- Create a tests/Unit/Domains/ directory structure that mirrors the app/Domains/ or src/Domains/ production code structure
- When creating a new test file, navigate to the corresponding production code location and replicate the path under tests/Unit/Domains/, appending 'Test' to the filename
- Configure CI/CD pipelines to support domain-based test execution using path filters (e.g., phpunit --filter tests/Unit/Domains/Settings/)
- Establish naming conventions for domain and module directories that are concise yet descriptive to minimize path length
- Consider implementing IDE templates or code generation tools that automatically create test files in the correct location based on production code paths
- Document the test organization pattern in the project's testing guidelines with concrete examples from each major domain

## Continuation Context


Verify commands:
- find tests/Unit/Domains -type f -name '*Test.php' | head -20
- grep -r 'namespace.*Tests\\Unit\\Domains' tests/Unit/Domains/ | head -10
- ls -R tests/Unit/Domains/Settings/ | grep -E '(ManageTemplates|ManageUserPreferences|ManageUsers)'

Accept when:
- Test files exist under tests/Unit/Domains/ with subdirectories matching production domain structure
- Test file names consistently append 'Test' suffix to production class names
- Domain feature modules (ManageTemplates, ManageUserPreferences, ManageUsers) are represented as subdirectories within their respective domains
- Test file paths mirror production code paths with tests/Unit/Domains/ prefix replacing src/ or app/ prefix

## Enforcement

- Verified by: CI pipeline checks verifying test file locations match production code structure
- Verified by: Code review checklist items confirming new tests follow domain organization pattern
- Verified by: Automated linting rules that validate test file naming and location conventions
- Verified by: Pre-commit hooks that verify test files are placed in correct domain directories
- Violation handling: CI pipeline fails if test files are detected outside the expected domain structure
- Violation handling: Code review requires changes before merge if test organization does not follow the pattern
- Violation handling: Automated PR comments flag test files in incorrect locations with suggested correct paths
- Violation handling: Quarterly audits identify and track technical debt for tests not following the convention
- Exception process: Developer submits exception request to tech lead with justification for alternative test organization
- Exception process: Tech lead reviews request considering factors like shared utilities, migration status, or special test requirements
- Exception process: Approved exceptions are documented in test class docblock with EXC-ID reference and expiration date if temporary
- Exception process: Exception registry is maintained and reviewed quarterly to ensure temporary exceptions are resolved
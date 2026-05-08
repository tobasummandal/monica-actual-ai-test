# Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Test Directory Root

Status: proposed
Date: 2025-01-17
Deciders: Detection Pipeline (automated)

## Context

- The codebase exhibits a domain-driven design structure with clear bounded contexts organized under a Settings domain, including ManageTemplates, ManageUserPreferences, and ManageUsers sub-domains
- Test files are organized in a parallel directory structure that mirrors the production code hierarchy, maintaining a 1:1 correspondence between test and implementation files
- The architecture separates concerns between API controllers (Api/Controllers) and web presentation logic (Web/ViewHelpers), with dedicated service classes handling business logic
- This pattern appears consistently across 17 test files with 79.47% confidence, indicating a deliberate architectural decision rather than ad-hoc organization
- The CI/CD pipeline benefits from predictable test locations, enabling automated test discovery and parallel execution based on domain boundaries

## Problem Statement

As codebases grow with domain-driven architectures, maintaining clear boundaries between domains while ensuring comprehensive test coverage becomes challenging. Without a consistent organizational strategy, tests become scattered, difficult to locate, and hard to execute selectively during CI/CD processes. Teams need a standardized approach to organize tests that reflects domain boundaries, supports automated test discovery, and enables efficient parallel test execution in continuous integration pipelines.

## Decision

1. MUST: The test directory root MUST be located at tests/Unit/ for unit tests, with integration and functional tests in separate parallel hierarchies

## Policy Block

- MUST The test directory root MUST be located at tests/Unit/ for unit tests, with integration and functional tests in separate parallel hierarchies

In scope:
- All unit tests for domain-driven code organized under Domains/ directory
- Service layer tests, controller tests, and view helper tests
- Tests for both API and Web presentation layers
- Automated test discovery mechanisms in CI/CD pipelines

Out of scope:
- Integration tests that span multiple domains (may use different organization)
- End-to-end tests that test full user workflows
- Performance and load tests
- Third-party library tests or vendor code

Exceptions:
- EX-001: Shared test utilities or abstract test base classes that support multiple domains
- EX-002: Legacy code being gradually migrated to domain-driven structure

## Rationale

- The pattern detection shows 79.47% confidence across 17 files, indicating strong consistency in applying this organizational approach throughout the Settings domain
- Mirrored directory structures reduce cognitive load by making test locations predictable, enabling developers to quickly locate and modify tests when changing production code
- Domain-based organization aligns with bounded context principles from DDD, ensuring tests respect architectural boundaries and can be executed independently per domain
- CI/CD pipelines benefit from predictable test locations through automated test discovery, parallel execution by domain, and selective test runs based on changed code paths

## Consequences

Positive:
- Developers can instantly locate tests for any production class by following the mirrored directory structure
- CI/CD pipelines can execute tests in parallel by domain, reducing overall build times
- Domain boundaries are reinforced through test organization, preventing cross-domain coupling
- New team members can navigate the test suite more easily due to consistent, predictable organization
- Automated tooling can generate test stubs in the correct location based on production code paths

Negative:
- Deep directory hierarchies may result in longer file paths and more navigation required in IDEs
- Refactoring domain boundaries requires moving both production code and corresponding tests
- Shared test utilities may need to be duplicated across domains or placed in a separate shared location
- Initial setup requires discipline to maintain the mirrored structure as the codebase evolves

## Alternatives

- Flat test directory structure with all tests in a single directory organized by test type (unit, integration, functional) (rejected)
  Rejected because: Does not scale well for large codebases with multiple domains; makes it difficult to locate tests for specific production classes; prevents domain-based parallel test execution
  When valid: May be acceptable for small projects with fewer than 50 test files and no clear domain boundaries
- Organize tests by feature or user story rather than by code structure (rejected)
  Rejected because: Creates disconnect between production code and tests; features often span multiple domains making organization ambiguous; harder to maintain as features evolve
  When valid: Could be used for acceptance tests or BDD scenarios that test complete user workflows
- Co-locate tests with production code in the same directory (rejected)
  Rejected because: Mixes test and production code in deployment artifacts; complicates build processes; violates separation of concerns between test and production environments
  When valid: May be appropriate for component-based frontend frameworks where tests are tightly coupled to components

## Risks

- Directory structure becomes too deep, making navigation cumbersome and file paths excessively long
  Mitigation: Establish maximum depth guidelines (e.g., 6 levels); use IDE navigation shortcuts; consider flattening sub-domains if hierarchy exceeds practical limits
  Owner: Engineering team and architecture review board
- Developers may create tests in incorrect locations, breaking the mirrored structure convention
  Mitigation: Implement automated checks in CI to verify test file locations match production code paths; provide IDE templates and generators; include structure validation in code review checklists
  Owner: CI/CD team and development leads
- Refactoring domain boundaries becomes more expensive due to need to move both code and tests
  Mitigation: Use automated refactoring tools that move tests alongside production code; plan domain boundary changes carefully; maintain good test coverage to catch issues after moves
  Owner: Architecture team and domain owners

## Implementation Notes

- Create a test file generator script or IDE template that automatically creates test files in the correct mirrored location based on the production class path
- Configure test runners (PHPUnit, Jest, etc.) to leverage the directory structure for selective test execution using path-based filters
- Document the directory structure convention in the project README and developer onboarding materials with clear examples
- Set up CI pipeline jobs that can execute tests by domain in parallel, using the directory structure to partition test suites
- Consider implementing a pre-commit hook or CI check that validates test file locations match the expected mirrored structure

## Continuation Context


Verify commands:
- find tests/Unit/Domains -name '*Test.php' | while read test; do src=$(echo $test | sed 's|tests/Unit/||' | sed 's|Test.php|.php|'); [ -f "src/$src" ] || echo "Orphaned test: $test"; done
- grep -r 'namespace.*Tests\\Unit\\Domains' tests/Unit/Domains --include='*.php' | awk -F: '{print $1}' | while read f; do ns=$(grep namespace $f | head -1 | sed 's/.*namespace //;s/;//'); path=$(echo $ns | sed 's/\\/\//g' | sed 's/Tests\/Unit\///'); expected="tests/Unit/$path"; actual=$(dirname $f); [ "$expected" = "$actual" ] || echo "Mismatch: $f"; done
- phpunit --list-tests-xml | xmllint --xpath '//testCaseClass/@file' - | grep -v 'tests/Unit/Domains/.*/.*Test.php' && echo 'Non-conforming test locations found' || echo 'All tests follow mirrored structure'

Accept when:
- All test files under tests/Unit/Domains/ have corresponding production files in src/Domains/ with matching directory paths
- Test file namespaces match the directory structure and mirror production code namespaces with Tests\Unit prefix
- CI pipeline successfully executes domain-specific test suites using directory-based filtering
- No orphaned test files exist without corresponding production code, and no production classes lack corresponding test files in the mirrored location

## Enforcement

- Verified by: Automated CI checks that validate test file locations match production code structure
- Verified by: Code review checklist items verifying new tests follow the mirrored directory convention
- Verified by: Static analysis tools that detect namespace and directory structure mismatches
- Verified by: Periodic architecture audits reviewing test organization compliance
- Violation handling: CI pipeline fails if test files are found in non-conforming locations
- Violation handling: Pull requests are blocked until test organization issues are resolved
- Violation handling: Automated notifications sent to developers when violations are detected
- Violation handling: Technical debt tickets created for legacy tests that need migration to correct locations
- Exception process: Developer submits exception request to tech lead with justification for non-standard test location
- Exception process: Architecture review board evaluates exception requests for shared utilities or cross-cutting concerns
- Exception process: Approved exceptions are documented in a TESTING_EXCEPTIONS.md file with rationale and expiration date
- Exception process: Exceptions are reviewed quarterly to determine if they can be resolved or need renewal
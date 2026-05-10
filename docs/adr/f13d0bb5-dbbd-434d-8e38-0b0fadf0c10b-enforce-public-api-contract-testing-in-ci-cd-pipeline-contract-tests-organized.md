# Enforce Public API Contract Testing in CI/CD Pipeline: Contract Tests Organized

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase contains 17 files demonstrating a consistent pattern of unit testing for public API contracts, particularly in the Settings domain covering templates, user preferences, and user management
- Public APIs serve as contracts between system components and external consumers, requiring strict validation to prevent breaking changes from reaching production
- The pattern shows comprehensive test coverage across service layers (Services, Web ViewHelpers, API Controllers) indicating a multi-tier testing strategy
- CI/CD pipelines require automated verification mechanisms to catch contract violations early in the development lifecycle before deployment
- The facet 'api.public.contracts' combined with unit test patterns suggests a deliberate architectural decision to validate API stability through automated testing

## Problem Statement

Without systematic testing of public API contracts in the CI/CD pipeline, breaking changes can be inadvertently introduced during development, causing integration failures, breaking downstream consumers, and requiring costly rollbacks or emergency patches in production environments.

## Decision

1. SHOULD: API contract tests SHOULD be organized by domain boundaries (e.g., Settings/ManageTemplates, Settings/ManageUsers) to maintain clear separation of concerns

## Policy Block

- SHOULD API contract tests SHOULD be organized by domain boundaries (e.g., Settings/ManageTemplates, Settings/ManageUsers) to maintain clear separation of concerns

In scope:
- All public API endpoints exposed to external consumers or other services
- Service layer contracts that form domain boundaries
- API controllers handling HTTP requests and responses
- ViewHelper contracts that provide data transformation for presentation layers
- Any interface or contract marked as @api or explicitly documented as public

Out of scope:
- Internal private methods not exposed outside their containing class
- Implementation details that do not affect external contracts
- Database schema changes that do not impact API response structures
- UI-only changes that do not modify underlying API contracts
- Experimental or feature-flagged APIs not yet released to production

Exceptions:
- EXC-001: Emergency hotfixes addressing critical production incidents where contract changes are unavoidable
- EXC-002: Deprecated APIs scheduled for removal where breaking changes are intentional and communicated

## Rationale

- Pattern detection identified 17 files with 79.47% confidence demonstrating consistent API contract testing practices across the Settings domain, indicating this is an established architectural pattern worth codifying
- Automated contract testing in CI/CD pipelines provides immediate feedback to developers, reducing the cost and time required to fix breaking changes compared to discovering them in later stages
- The multi-tier testing approach (Services, Controllers, ViewHelpers) ensures comprehensive validation of contracts at different architectural layers, preventing integration issues
- Enforcing contract stability through automated testing enables safer refactoring, faster deployment cycles, and greater confidence in continuous delivery practices

## Consequences

Positive:
- Breaking changes to public APIs are caught automatically during development, preventing production incidents and reducing emergency rollbacks
- Developers receive immediate feedback on contract violations, enabling faster iteration and reducing debugging time
- API consumers gain confidence in system stability, knowing that contracts are validated before deployment
- Documentation of API behavior through tests serves as living documentation that stays synchronized with implementation
- Enables safe refactoring of internal implementations without fear of breaking external contracts

Negative:
- Increases initial development time as developers must write and maintain contract tests alongside implementation code
- CI/CD pipeline execution time increases proportionally to the number of contract tests, potentially slowing feedback loops
- May create false sense of security if tests only validate happy paths and miss edge cases or error conditions
- Requires discipline to keep tests synchronized with evolving contracts, risking test rot if not properly maintained

## Alternatives

- Manual API testing and code review without automated contract validation (rejected)
  Rejected because: Manual testing is error-prone, time-consuming, and does not scale with team size or deployment frequency. Human reviewers may miss subtle contract violations that automated tests would catch consistently.
  When valid: Only appropriate for very small teams with infrequent deployments and simple APIs
- Integration tests only without dedicated unit-level contract tests (rejected)
  Rejected because: Integration tests are slower, more brittle, and provide less precise feedback about which specific contract was violated. They also require more complex test infrastructure and are harder to maintain.
  When valid: May be sufficient for internal APIs with single consumers where tight coupling is acceptable
- Consumer-driven contract testing (e.g., Pact) with provider verification (deferred)
  Rejected because: While more sophisticated, consumer-driven contract testing requires additional infrastructure, tooling, and coordination between teams. The current unit testing approach provides sufficient value with lower complexity.
  When valid: Should be reconsidered when multiple independent teams consume the same APIs and need to evolve contracts independently

## Risks

- Test coverage gaps may exist where public APIs lack corresponding contract tests, creating blind spots in validation
  Mitigation: Implement code coverage analysis specifically for public API surfaces and require minimum coverage thresholds (e.g., 80%) for contract tests. Add linting rules to detect public APIs without tests.
  Owner: Engineering team with CI/CD ownership
- Developers may write superficial tests that pass CI but do not adequately validate contract behavior, defeating the purpose
  Mitigation: Establish code review guidelines requiring reviewers to verify test quality. Implement mutation testing to validate that tests actually catch contract violations. Provide training on effective contract testing practices.
  Owner: Tech leads and senior engineers
- Accumulation of contract tests over time may significantly slow CI/CD pipeline, impacting developer productivity
  Mitigation: Monitor pipeline execution times and optimize slow tests. Consider parallel test execution, test result caching, and selective test execution based on changed files. Set SLA targets for pipeline duration.
  Owner: DevOps and platform engineering team

## Implementation Notes

- Start by identifying all public API surfaces in the codebase (controllers, service interfaces, public methods) and create an inventory of existing test coverage
- Establish naming conventions for contract tests (e.g., *ControllerTest.php for API controllers, *ServiceTest.php for service contracts) to make them easily identifiable
- Configure CI/CD pipeline to run contract tests as a separate stage with clear failure reporting that identifies which specific contract was violated
- Create test templates and examples for common contract testing scenarios to help developers write consistent, high-quality tests
- Integrate code coverage tools to track contract test coverage separately from general test coverage, setting minimum thresholds for public APIs
- Document the contract testing strategy in team onboarding materials and architectural decision records to ensure consistent understanding across the team

## Continuation Context


Verify commands:
- find tests/Unit -name '*ControllerTest.php' -o -name '*ServiceTest.php' -o -name '*ViewHelperTest.php' | wc -l
- grep -r 'public function test' tests/Unit/Domains/Settings/ | wc -l
- phpunit --testsuite=unit --coverage-text --coverage-filter='app/Domains/*/Api/Controllers' | grep 'Lines:' | awk '{print $2}'

Accept when:
- All public API endpoints in the Settings domain have corresponding unit tests with at least 80% code coverage
- CI/CD pipeline includes a dedicated stage for contract tests that must pass before merge approval
- Contract test execution completes within acceptable time limits (e.g., under 5 minutes for the full suite)
- Code review checklist includes verification that new or modified public APIs have corresponding contract tests

## Enforcement

- Verified by: Automated CI/CD pipeline execution on every pull request and commit to protected branches
- Verified by: Code coverage analysis tools integrated into CI pipeline with minimum threshold enforcement
- Verified by: Mandatory code review process requiring reviewer verification of contract test presence and quality
- Verified by: Static analysis tools to detect public API methods without corresponding test coverage
- Violation handling: CI/CD pipeline fails and prevents merge if contract tests fail or coverage thresholds are not met
- Violation handling: Pull requests without contract tests for modified public APIs are automatically flagged for reviewer attention
- Violation handling: Quarterly audits identify public APIs lacking contract tests, with remediation tickets created and prioritized
- Violation handling: Metrics dashboard tracks contract test coverage trends, with alerts for declining coverage
- Exception process: Developer submits exception request via documented process (e.g., GitHub issue or Jira ticket) with justification
- Exception process: Tech lead reviews exception request and approves only for valid scenarios (emergency hotfix, deprecated API)
- Exception process: Approved exceptions are time-limited (e.g., 48-72 hours) with automatic follow-up ticket creation for remediation
- Exception process: All exceptions are logged and reviewed in monthly architecture review meetings to identify systemic issues
# Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Test File Naming

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase contains 18 unit test files following a consistent PHPUnit testing pattern with setUp methods and helper traits
- Tests are organized under tests/Unit/ directory structure with clear separation between Models and Helpers test suites
- The pattern demonstrates a mature testing infrastructure with standardized test initialization and shared testing utilities
- Consistent test structure across multiple domains (Account, Group, Gift, Call, LifeEvent, Address, Label, etc.) indicates an established testing convention
- The testing pattern supports CI/CD pipeline requirements for automated test execution and quality gates

## Problem Statement

Without a standardized approach to unit test structure and initialization, test suites become inconsistent, difficult to maintain, and prone to setup duplication. Teams need clear guidance on how to structure PHPUnit tests, initialize test dependencies, and leverage shared testing utilities to ensure reliable CI/CD pipeline execution.

## Decision

1. SHOULD: Test file naming SHOULD follow the pattern {ClassName}Test.php matching the class under test

## Policy Block

- SHOULD Test file naming SHOULD follow the pattern {ClassName}Test.php matching the class under test

In scope:
- All PHPUnit unit tests in the tests/Unit/ directory
- Model test classes testing domain entities
- Helper test classes testing utility functions
- Test initialization and setup logic
- Shared testing traits and utilities

Out of scope:
- Integration tests in tests/Integration/ or tests/Feature/ directories
- End-to-end tests or browser tests
- Performance or load tests
- Third-party test libraries or frameworks
- Test execution configuration (phpunit.xml)

## Rationale

- The pattern appears in 18 files with 82.74% confidence, indicating a well-established and consistently applied testing convention across the codebase
- Standardized test structure improves maintainability by making tests predictable and easier to understand for all team members
- Using setUp() methods and traits promotes DRY principles by centralizing common initialization logic and reducing code duplication
- Consistent test organization supports CI/CD automation by providing predictable test discovery and execution patterns

## Consequences

Positive:
- Improved test maintainability through consistent structure and shared utilities across all unit tests
- Faster onboarding for new developers who can quickly understand test patterns and conventions
- Reduced code duplication in test setup through trait-based helpers and setUp() methods
- Better CI/CD pipeline reliability with predictable test organization and execution
- Enhanced test discoverability through standardized naming and directory structure

Negative:
- Initial learning curve for developers unfamiliar with PHPUnit traits and setUp() patterns
- Potential over-reliance on shared traits may create hidden dependencies between tests
- Refactoring shared test utilities requires coordinated updates across multiple test files
- Strict directory structure may feel constraining for edge cases or experimental tests

## Alternatives

- Use inline test setup without setUp() methods, initializing dependencies directly in each test method (rejected)
  Rejected because: Creates significant code duplication and makes tests harder to maintain. setUp() provides a standard PHPUnit lifecycle hook that all developers understand.
  When valid: May be acceptable for very simple tests with no shared setup requirements
- Organize tests by feature or user story rather than by application structure (Models, Helpers) (rejected)
  Rejected because: Makes it harder to locate tests for specific classes and breaks the convention of mirroring application structure in test organization
  When valid: Could be used for integration or feature tests that span multiple components
- Use base test classes with template methods instead of traits for shared functionality (deferred)
  Rejected because: Not rejected, but traits offer more flexibility for composing multiple behaviors without deep inheritance hierarchies
  When valid: Valid when there is a clear single inheritance hierarchy and shared setup logic that all tests need

## Risks

- Shared test traits may introduce hidden coupling between tests, making failures harder to debug
  Mitigation: Document trait behavior clearly, keep traits focused on single responsibilities, and ensure traits are stateless where possible
  Owner: Engineering team
- Over-standardization may discourage developers from writing tests that don't fit the standard pattern
  Mitigation: Provide clear guidance on when exceptions are acceptable and maintain flexibility for edge cases while preserving the standard for common scenarios
  Owner: Engineering team
- Changes to shared test utilities or traits could break multiple test files simultaneously
  Mitigation: Implement comprehensive test coverage for test utilities themselves, use semantic versioning for breaking changes, and communicate changes broadly
  Owner: Engineering team

## Implementation Notes

- Create or document standard test traits (e.g., DatabaseTransactions, RefreshDatabase) that encapsulate common setup patterns
- Establish a base test class if needed that provides common assertions or utilities while allowing trait composition
- Use PHPUnit's @before and @after annotations for additional lifecycle hooks when setUp() and tearDown() are insufficient
- Leverage Laravel's testing utilities (if applicable) such as factories, seeders, and database transactions for test data management
- Document the standard test structure in the project's testing guidelines with examples from existing tests

## Continuation Context


Verify commands:
- find tests/Unit -name '*Test.php' -type f | xargs grep -L 'function setUp' | wc -l
- grep -r 'class.*Test extends' tests/Unit/ | grep -v 'PHPUnit\\Framework\\TestCase' | wc -l
- find tests/Unit -type f -name '*.php' ! -name '*Test.php' | wc -l

Accept when:
- All test files in tests/Unit/ contain a setUp() method or explicitly document why it's not needed
- All test classes extend PHPUnit\Framework\TestCase or a documented base test class
- Test file names match the pattern {ClassName}Test.php and are organized in directories mirroring the application structure

## Enforcement

- Verified by: CI pipeline executes PHPUnit test suite and fails on test errors
- Verified by: Code review process checks for adherence to test structure standards
- Verified by: Static analysis tools verify test file naming and organization conventions
- Verified by: Automated linting rules check for presence of setUp() methods in test classes
- Violation handling: CI pipeline blocks merge if tests fail or are improperly structured
- Violation handling: Code review feedback requests changes to align with testing standards
- Violation handling: Documentation and examples provided to help developers correct violations
- Violation handling: Team retrospectives address recurring violations and improve testing guidelines
- Exception process: Developer documents rationale for deviation in test file comments or PR description
- Exception process: Tech lead or senior developer reviews and approves exception during code review
- Exception process: Exception is documented in testing guidelines if it represents a valid new pattern
- Exception process: Periodic review of exceptions to determine if standards need updating
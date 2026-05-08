<rule_activation id="ee1e94f1-ac78-41ec-bfaa-dd1cdca35d65" title="Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Test Suites Executable" applies_to="tests/**/*.php">
These rules are ALWAYS ACTIVE for all test files matching `tests/**/*.php`.
</rule_activation>

### Rules

- **R-PHPUNIT-001** SHOULD: Test suites SHOULD be executable in CI/CD pipelines for automated verification.
- **R-PHPUNIT-002** MUST: All test files in tests/Unit/Domains/ MUST follow the {ClassName}Test.php naming convention.
- **R-PHPUNIT-003** MUST: Test directory structure MUST mirror the application domain hierarchy under tests/Unit/Domains/.
- **R-PHPUNIT-004** MUST: All unit tests MUST extend PHPUnit\Framework\TestCase.
- **R-PHPUNIT-005** MAY: Tests MAY use PHPUnit data providers for testing multiple scenarios with the same test logic.

**In scope:**
- Unit tests for service layer components in all domains
- Unit tests for API controllers
- Unit tests for web view helpers
- Tests for user preference management services
- Tests for template management services
- Tests for user management components

**Out of scope:**
- Integration tests requiring database connections
- End-to-end tests requiring full application stack
- Browser-based functional tests
- Performance and load tests
- Third-party library tests

### Verify

```bash
# Count test files following naming convention
find tests/Unit/Domains -name '*Test.php' -type f | wc -l

# Verify PHPUnit TestCase usage
grep -r 'use PHPUnit\\Framework\\TestCase' tests/Unit/Domains/ | wc -l

# Execute unit test suite
vendor/bin/phpunit --testsuite=unit --testdox
```

**Accept when:**
- All test files in tests/Unit/Domains/ follow the {ClassName}Test.php naming convention
- PHPUnit test execution completes successfully with all tests passing
- Test directory structure mirrors the application domain hierarchy under tests/Unit/Domains/

<enforcement>
Claude Code MUST NOT skip or defer verification. CI/CD pipeline MUST fail if PHPUnit tests fail or coverage drops below threshold. Pull requests without corresponding tests MUST be flagged during code review.
</enforcement>
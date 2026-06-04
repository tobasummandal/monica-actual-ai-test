<rule_activation id="ee1e94f1-ac78-41ec-bfaa-dd1cdca35d65" title="Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Test Suites Executable" applies_to="**/*">
These rules are ALWAYS ACTIVE for all files in the codebase. PHPUnit is the standard testing framework for this domain-driven architecture project. All unit tests MUST be executable in CI/CD pipelines and organized to mirror domain structure.
</rule_activation>

### Rules

- **R-PHPUNIT-001** SHOULD: Test suites SHOULD be executable in CI/CD pipelines for automated verification.
- **R-PHPUNIT-002** MUST: All test files in tests/Unit/Domains/ MUST follow the {ClassName}Test.php naming convention.
- **R-PHPUNIT-003** MUST: Test directory structure MUST mirror the application domain hierarchy under tests/Unit/Domains/.
- **R-PHPUNIT-004** SHOULD: Unit tests SHOULD cover service layer components, API controllers, and view helpers across all domains.
- **R-PHPUNIT-005** MUST: PHPUnit test execution MUST complete successfully with all tests passing before merge.
- **R-PHPUNIT-006** SHOULD: New components SHOULD have corresponding unit tests verified during code review.
- **R-PHPUNIT-007** MUST: Code coverage MUST not drop below established thresholds in CI/CD builds.

### Verify

```bash
# Count test files in domain structure
find tests/Unit/Domains -name '*Test.php' -type f | wc -l

# Verify PHPUnit usage across test files
grep -r 'use PHPUnit\\Framework\\TestCase' tests/Unit/Domains/ | wc -l

# Execute unit test suite with test documentation
vendor/bin/phpunit --testsuite=unit --testdox
```

**Accept when:**
- All test files in tests/Unit/Domains/ follow the {ClassName}Test.php naming convention
- PHPUnit test execution completes successfully with all tests passing
- Test directory structure mirrors the application domain hierarchy under tests/Unit/Domains/
- Code coverage reports are generated and meet minimum thresholds
- CI/CD pipeline confirms test execution on every commit

<enforcement>
Claude Code MUST NOT skip or defer verification. All PHPUnit tests MUST execute successfully and pass before any code is committed. Violations of naming conventions or test organization MUST be caught by automated checks and code review.
</enforcement>
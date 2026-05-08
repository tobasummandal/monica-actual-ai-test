<rule_activation id="f13d0bb5-dbbd-434d-8e38-0b0fadf0c10b" title="Enforce Public API Contract Testing in CI/CD Pipeline: Contract Tests Organized" applies_to="**/*.php">
These rules are ALWAYS ACTIVE for all PHP files. Public APIs serve as contracts between system components and external consumers, requiring strict validation to prevent breaking changes from reaching production.

**In scope:**
- All public API endpoints exposed to external consumers or other services
- Service layer contracts that form domain boundaries
- API controllers handling HTTP requests and responses
- ViewHelper contracts that provide data transformation for presentation layers
- Any interface or contract marked as @api or explicitly documented as public

**Out of scope:**
- Internal private methods not exposed outside their containing class
- Implementation details that do not affect external contracts
- Database schema changes that do not impact API response structures
- UI-only changes that do not modify underlying API contracts
- Experimental or feature-flagged APIs not yet released to production

**Exceptions:**
- EXC-001: Emergency hotfixes addressing critical production incidents where contract changes are unavoidable
- EXC-002: Deprecated APIs scheduled for removal where breaking changes are intentional and communicated
</rule_activation>

### Rules

- **R-APIC-001** SHOULD: API contract tests SHOULD be organized by domain boundaries (e.g., Settings/ManageTemplates, Settings/ManageUsers) to maintain clear separation of concerns

### Verify

```bash
# Count contract test files organized by type
find tests/Unit -name '*ControllerTest.php' -o -name '*ServiceTest.php' -o -name '*ViewHelperTest.php' | wc -l

# Count test methods in Settings domain
grep -r 'public function test' tests/Unit/Domains/Settings/ | wc -l

# Check code coverage for API controllers
phpunit --testsuite=unit --coverage-text --coverage-filter='app/Domains/*/Api/Controllers' | grep 'Lines:' | awk '{print $2}'
```

**Accept when:**
- All public API endpoints in the Settings domain have corresponding unit tests with at least 80% code coverage
- CI/CD pipeline includes a dedicated stage for contract tests that must pass before merge approval
- Contract test execution completes within acceptable time limits (e.g., under 5 minutes for the full suite)
- Code review checklist includes verification that new or modified public APIs have corresponding contract tests

<enforcement>
Verification is MANDATORY. Claude Code MUST NOT skip or defer verification of API contract test coverage.

**Verified by:**
- Automated CI/CD pipeline execution on every pull request and commit to protected branches
- Code coverage analysis tools integrated into CI pipeline with minimum threshold enforcement
- Mandatory code review process requiring reviewer verification of contract test presence and quality
- Static analysis tools to detect public API methods without corresponding test coverage

**Violation handling:**
- CI/CD pipeline fails and prevents merge if contract tests fail or coverage thresholds are not met
- Pull requests without contract tests for modified public APIs are automatically flagged for reviewer attention
- Quarterly audits identify public APIs lacking contract tests, with remediation tickets created and prioritized
- Metrics dashboard tracks contract test coverage trends, with alerts for declining coverage

**Exception process:**
- Developer submits exception request via documented process (e.g., GitHub issue or Jira ticket) with justification
- Tech lead reviews exception request and approves only for valid scenarios (emergency hotfix, deprecated API)
- Approved exceptions are time-limited (e.g., 48-72 hours) with automatic follow-up ticket creation for remediation
- All exceptions are logged and reviewed in monthly architecture review meetings to identify systemic issues
</enforcement>
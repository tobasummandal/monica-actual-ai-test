<rule_activation id="f13d0bb5-dbbd-434d-8e38-0b0fadf0c10b" title="Enforce Public API Contract Testing in CI/CD Pipeline: Contract Tests Organized" applies_to="**/*">
These rules are ALWAYS ACTIVE for all files matching public API surfaces, service layer contracts, API controllers, and ViewHelper contracts in the codebase.
</rule_activation>

### Rules

- **R-API-001** SHOULD: API contract tests SHOULD be organized by domain boundaries (e.g., Settings/ManageTemplates, Settings/ManageUsers) to maintain clear separation of concerns.

### Scope

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

### Verify

```bash
# Count contract test files by naming convention
find tests/Unit -name '*ControllerTest.php' -o -name '*ServiceTest.php' -o -name '*ViewHelperTest.php' | wc -l

# Count public test methods in Settings domain
grep -r 'public function test' tests/Unit/Domains/Settings/ | wc -l

# Check code coverage for API controllers
phpunit --testsuite=unit --coverage-text --coverage-filter='app/Domains/*/Api/Controllers' | grep 'Lines:' | awk '{print $2}'
```

**Accept when:**
- All public API endpoints in the Settings domain have corresponding unit tests with at least 80% code coverage
- CI/CD pipeline includes a dedicated stage for contract tests that must pass before merge approval
- Contract test execution completes within acceptable time limits (e.g., under 5 minutes for the full suite)
- Code review checklist includes verification that new or modified public APIs have corresponding contract tests
- Contract tests are organized by domain boundaries with clear naming conventions (*ControllerTest.php, *ServiceTest.php, *ViewHelperTest.php)

<enforcement>
Claude Code MUST NOT skip or defer verification. Contract tests MUST be present for all public API modifications. CI/CD pipeline failures due to missing or failing contract tests MUST block merge approval. Code coverage analysis MUST enforce minimum 80% threshold for public API surfaces.
</enforcement>
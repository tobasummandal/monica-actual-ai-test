<rule_activation id="5dba8b3a-57ed-4265-a5cf-bb7f9ba27e7f" title="Adopt Quality Gates Pattern for Domain Service Layer Validation: Domain Service Methods" applies_to="**/*">
These rules are ALWAYS ACTIVE for all domain service implementations, view helpers, and controller methods that process user input or external data. Quality gates MUST be implemented at service boundaries.
</rule_activation>

### Rules

- **R-QG-001** MUST: All domain service methods that accept external input or cross-domain data MUST implement quality gate validation before processing business logic.

### Scope

**In scope:**
- All domain service classes in `app/Domains/*/Services/`
- All view helper classes in `app/Domains/*/Web/ViewHelpers/`
- All controller methods in `app/Domains/*/Web/Controllers/` that handle external requests
- Synchronization and integration services that process external data sources
- Command and query handlers that accept user input or cross-domain data

**Out of scope:**
- Private helper methods within a service that operate on already-validated data
- Pure data transfer objects (DTOs) and value objects that enforce validation in constructors
- Database query builders and repository methods that operate on typed parameters
- Unit test fixtures and test helper methods

**Exceptions:**
- EXC-001: Performance-critical hot paths where validation overhead is measured and documented as unacceptable
- EXC-002: Legacy code undergoing gradual refactoring where immediate compliance would block critical business features

### Verify

```bash
# Count total service methods across domains
grep -r 'function.*(' app/Domains/*/Services/ app/Domains/*/Web/ViewHelpers/ app/Domains/*/Web/Controllers/ | wc -l

# Count validation statements in service layer
grep -r 'throw new.*Exception\|if.*empty\|if.*null\|assert\|validate' app/Domains/*/Services/ app/Domains/*/Web/ViewHelpers/ | wc -l

# Run validation tests
php artisan test --filter=ValidationTest --testsuite=Unit
```

**Accept when:**
- Ratio of validation statements to service methods is at least 1:1, indicating each method has at least one quality gate check
- All new service methods in code review demonstrate explicit validation of input parameters before business logic execution
- Unit tests exist for validation failure scenarios in addition to happy path tests

### Implementation Guidance

- Start by identifying all service methods that accept parameters from external sources (HTTP requests, webhooks, file imports, API calls)
- Implement quality gates immediately after parameter acceptance and before any business logic execution
- Use descriptive exception types (e.g., `InvalidJournalDataException`, `MalformedWebhookPayloadException`) to clearly communicate validation failures
- Consider creating a base validator trait or abstract class that provides common validation utilities (e.g., `requireField`, `validateFormat`, `assertType`)
- Document validation rules in method docblocks to make expectations explicit for API consumers and maintainers

<enforcement>
Claude Code MUST verify quality gate implementation for all service methods accepting external input. Code review MUST include verification of quality gate implementation. Static analysis tools MUST scan for service methods lacking validation logic and flag them in CI pipeline. Unit test coverage MUST mandate tests for validation failure scenarios. Violations result in CI pipeline warnings and code review rejection. Exception requests require architecture team approval with documented justification and compensating controls.
</enforcement>
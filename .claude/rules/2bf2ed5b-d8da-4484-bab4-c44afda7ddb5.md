<rule_activation id="2bf2ed5b-d8da-4484-bab4-c44afda7ddb5" title="Standardize Exception and Logging Formatting for External API Responses: Logging Utilities Such" applies_to="**/*">
These rules are ALWAYS ACTIVE for all external API endpoints and exception handling components. All new exception classes and logging utilities MUST comply with the formatting standards defined herein.
</rule_activation>

### Rules

- **R-API-001** MUST: Logging utilities (such as Loggable trait) MUST use the same formatting pattern as exception handlers to ensure consistency across error tracking and API responses.
- **R-API-002** MUST: All custom exception classes that can be thrown from external API endpoints MUST implement a Formattable interface or equivalent formatter trait with methods like toArray(), toJson(), and getHttpStatusCode().
- **R-API-003** MUST: All exception classes in app/Exceptions/ that are thrown from API routes MUST implement the Formattable interface or equivalent formatter trait.
- **R-API-004** MUST: Exception responses MUST match the documented JSON schema with required fields (code, message, status, timestamp).
- **R-API-005** MUST: The Loggable trait and all exception formatters MUST produce structurally consistent output.
- **R-API-006** SHOULD: Establish a standard error response schema (e.g., {error: {code, message, status, timestamp, context}}) and document it in OpenAPI specifications.
- **R-API-007** SHOULD: Create a base Formattable interface or trait that all API exceptions must implement.
- **R-API-008** SHOULD: Refactor existing exception classes (NotEnoughPermissionException, MaximumNumberOfUsersInVaultException) to serve as reference implementations.
- **R-API-009** SHOULD: Create generator/scaffold commands for new exception classes that automatically include the formatter implementation.

### Verify

```bash
# Verify all exception classes implement Formattable interface
grep -r "class.*Exception" app/ | xargs -I {} sh -c 'grep -l "Formattable\|toArray\|toJson" {}'

# Run exception formatter tests
php artisan test --filter ExceptionFormatterTest

# Verify Loggable trait uses consistent formatting
grep -r "use.*Loggable" app/ | xargs -I {} sh -c 'grep -l "format\|toArray" {}'
```

**Accept when:**
- All exception classes in app/Exceptions/ that are thrown from API routes implement the Formattable interface or equivalent formatter trait
- Automated tests verify that exception responses match the documented JSON schema with required fields (code, message, status, timestamp)
- The Loggable trait and all exception formatters produce structurally consistent output as verified by integration tests
- Static analysis tools (PHPStan/Psalm) confirm Formattable interface requirement on exception classes
- API contract tests validate error response structures

<enforcement>
Claude Code MUST NOT skip or defer verification. All exception classes and logging utilities MUST be validated against the Formattable interface requirement and JSON schema compliance before code is committed. CI pipeline MUST fail if violations are detected.
</enforcement>
<rule_activation id="2bf2ed5b-d8da-4484-bab4-c44afda7ddb5" title="Standardize Exception and Logging Formatting for External API Responses: Logging Utilities Such" applies_to="**/*">
These rules are ALWAYS ACTIVE for all external API endpoints and exception handling components.

**In scope:**
- All custom exception classes that can be thrown from external API endpoints
- Logging utilities and traits used within API request/response lifecycle
- Error response middleware and exception handlers for public APIs
- API documentation and OpenAPI specifications describing error formats

**Out of scope:**
- Internal service-to-service communication errors (may use different formats)
- CLI command error output formatting
- Background job failure handling (unless exposed via API)
- Development/debug mode error pages (may include additional details)

**Exceptions:**
- EXC-001: Legacy API versions (v1, v2) that have established error formats with existing client dependencies
- EXC-002: Third-party library exceptions that cannot be wrapped without significant performance impact
</rule_activation>

### Rules

- **R-ELF-001** MUST: Logging utilities (such as Loggable trait) MUST use the same formatting pattern as exception handlers to ensure consistency across error tracking and API responses.
- **R-ELF-002** MUST: All API exception classes MUST implement a base Formattable interface or trait that defines methods like toArray(), toJson(), and getHttpStatusCode().
- **R-ELF-003** MUST: All error responses MUST follow a standard schema (e.g., {error: {code, message, status, timestamp, context}}) and be documented in OpenAPI specifications.
- **R-ELF-004** MUST: Exception formatters MUST NOT inadvertently expose sensitive information; all contextual data must be sanitized according to security guidelines.

### Verify

```bash
# Verify all exception classes implement formatter interface
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
- No sensitive information is exposed in formatted exception responses, verified by security review

<enforcement>
Claude Code MUST verify compliance before completing any changes to exception classes, logging utilities, or API error handlers. Verification includes:

- Running automated CI pipeline tests that validate exception response formats against JSON schema
- Checking that static analysis tools (PHPStan/Psalm) require Formattable interface on exception classes
- Ensuring API contract tests validate error response structures
- Confirming code review checklist items for formatter implementation

Claude Code MUST NOT skip or defer verification of these requirements.
</enforcement>
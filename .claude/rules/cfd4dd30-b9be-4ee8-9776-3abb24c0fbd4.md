<rule_activation id="cfd4dd30-b9be-4ee8-9776-3abb24c0fbd4" title="Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Throw Domain" applies_to="**/*">
These rules are ALWAYS ACTIVE for all files matching public API endpoints, interfaces, DTOs, and exception handlers across the codebase.
</rule_activation>

### Rules

- **R-API-001** MUST: Public APIs MUST throw domain-specific exceptions (extending base exception classes) for all error conditions, with descriptive messages and appropriate HTTP status codes.
- **R-API-002** MUST: All public API endpoints MUST have corresponding interface definitions with explicit method signatures.
- **R-API-003** MUST: All API request/response payloads MUST use dedicated DTO classes rather than exposing domain models directly.
- **R-API-004** MUST: All public API methods MUST include PHP type hints and return type declarations on interface methods to enforce contract compliance at runtime.
- **R-API-005** SHOULD: Use naming conventions: interfaces prefixed with 'I' (IDAVBackend), DTOs suffixed with 'Dto', exceptions suffixed with 'Exception'.
- **R-API-006** SHOULD: Document all public interfaces and DTOs with PHPDoc annotations including @api tag to clearly mark public contracts.
- **R-API-007** SHOULD: Implement centralized exception handler that maps domain exceptions to appropriate HTTP status codes and error response formats.
- **R-API-008** MAY: Consider implementing OpenAPI/Swagger specifications generated from interface definitions for external documentation.

### Verify

```bash
# Count DTO classes in domains
grep -r "class.*Dto" app/Domains --include="*.php" | wc -l

# Count interface definitions
grep -r "interface I[A-Z]" app/Domains --include="*.php" | wc -l

# Count custom exception classes
grep -r "class.*Exception extends" app/Exceptions --include="*.php" | wc -l

# Count ViewHelper classes
find app/Domains -name "*ViewHelper.php" -type f | wc -l
```

**Accept when:**
- All public API endpoints have corresponding interface definitions with explicit method signatures
- All API request/response payloads use dedicated DTO classes rather than exposing domain models
- All public API error conditions throw domain-specific exceptions with clear messages
- Grep commands show consistent presence of DTOs, interfaces, custom exceptions, and ViewHelpers across API-related code
- No direct domain model exposure detected in API controllers via static analysis
- All new public API endpoints include interface definitions and type hints
- DTO serialization/deserialization contracts pass CI pipeline tests

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules in this activation are mandatory for public API design. Violations must be caught during code review and CI pipeline execution. Exceptions require explicit approval from the architecture review board with documented justification and migration plan.
</enforcement>
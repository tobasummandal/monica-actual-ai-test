<rule_activation id="cfd4dd30-b9be-4ee8-9776-3abb24c0fbd4" title="Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Throw Domain" applies_to="**/*">
These rules apply to all files that define or interact with public APIs, including REST endpoints, WebDAV/CardDAV integrations, DTOs, custom exceptions, ViewHelpers, and service layer interfaces.

**In scope:** REST API endpoints exposed to external consumers, WebDAV/CardDAV integration interfaces and backends, Data transfer objects used in API request/response payloads, Custom exception classes thrown by public API methods, ViewHelper classes that prepare data for API responses, Service layer interfaces that define public contracts.

**Out of scope:** Internal domain models and entities not exposed via APIs, Private service methods used only within domain boundaries, Database repositories and data access layers, Internal event handlers and message queue consumers, Administrative CLI commands and internal tools.

**Exceptions:** EXC-001 (Legacy API endpoints that predate this ADR and have established external consumers), EXC-002 (Prototype or experimental APIs explicitly marked as unstable/alpha).
</rule_activation>

### Rules

- **R-API-001** MUST: Public APIs MUST throw domain-specific exceptions (extending base exception classes) for all error conditions, with descriptive messages and appropriate HTTP status codes.
- **R-API-002** MUST: All public API endpoints MUST have corresponding interface definitions with explicit method signatures.
- **R-API-003** MUST: All API request/response payloads MUST use dedicated DTO classes rather than exposing domain models directly.

### Verify

```bash
# Count DTOs in domain layer
grep -r "class.*Dto" app/Domains --include="*.php" | wc -l

# Count interfaces with 'I' prefix
grep -r "interface I[A-Z]" app/Domains --include="*.php" | wc -l

# Count custom exceptions
grep -r "class.*Exception extends" app/Exceptions --include="*.php" | wc -l

# Count ViewHelper classes
find app/Domains -name "*ViewHelper.php" -type f | wc -l
```

**Accept when:**
- All public API endpoints have corresponding interface definitions with explicit method signatures
- All API request/response payloads use dedicated DTO classes rather than exposing domain models
- All public API error conditions throw domain-specific exceptions with clear messages
- Grep commands show consistent presence of DTOs, interfaces, custom exceptions, and ViewHelpers across API-related code

<enforcement>
Claude Code MUST NOT skip or defer verification. Automated static analysis tools check for direct domain model exposure in API controllers. Code review blocks merge if DTOs are not used for API boundaries or if public API methods lack interface definitions. CI pipeline tests validate DTO serialization/deserialization contracts.
</enforcement>
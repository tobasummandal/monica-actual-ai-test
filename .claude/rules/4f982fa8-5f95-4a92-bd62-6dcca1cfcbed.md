<rule_activation id="4f982fa8-5f95-4a92-bd62-6dcca1cfcbed" title="Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Import Operations Provide" applies_to="**/*">
These rules are ALWAYS ACTIVE for all external contact synchronization integrations and DAV protocol implementations within the Contact domain.
</rule_activation>

### Rules

- **R-CARDDAV-001** SHOULD: Import operations SHOULD provide separate resource handlers for generic DAV imports and vCard-specific imports.

### Scope

**In scope:**
- All contact synchronization with external CardDAV/WebDAV servers
- vCard import and export operations for contact data
- DAV backend interface implementations
- Contact DTO models for external API communication
- Error handling for non-compliant DAV servers

**Out of scope:**
- Internal contact storage and database operations
- REST API endpoints for web/mobile clients
- GraphQL APIs for internal services
- Non-DAV third-party integrations (OAuth-based APIs, webhooks)
- Real-time synchronization protocols (WebSocket, Server-Sent Events)

**Exceptions:**
- EX-001: Legacy contact import from proprietary formats (CSV, Excel) that cannot be converted to vCard
- EX-002: Emergency fallback to direct database operations when DAV server is persistently unavailable

### Verify

```bash
# Verify IDAVBackend interface implementation
grep -r "IDAVBackend" app/Domains/Contact/Dav/ --include="*.php" | wc -l

# Verify ContactDto and ContactDeleteDto usage
grep -r "ContactDto\|ContactDeleteDto" app/Domains/Contact/DavClient/ --include="*.php" | wc -l

# Verify DavServerNotCompliantException usage
grep -r "DavServerNotCompliantException" app/Domains/Contact/ --include="*.php" | wc -l

# Verify import resource handlers exist
find app/Domains/Contact/Dav* -name "*Import*Resource.php" -o -name "*VCard*.php" | wc -l
```

**Accept when:**
- All DAV backend implementations implement the IDAVBackend interface (verify command returns > 0)
- Contact DTO models are consistently used across DavClient services (verify command returns >= 2 for both DTOs)
- DavServerNotCompliantException is present and used for error handling (verify command returns > 0)
- Import resource handlers exist for DAV and vCard operations (verify command returns >= 2)

### Implementation Guidance

- Start by implementing the IDAVBackend interface for your target DAV server, ensuring all required CardDAV operations (PROPFIND, REPORT, GET, PUT, DELETE) are properly handled
- Use the ContactDto and ContactDeleteDto models consistently across all DAV client services to maintain type safety and enable easier testing with mock data
- Implement comprehensive error handling that distinguishes between network errors, authentication failures, and protocol compliance issues using DavServerNotCompliantException
- Create separate resource handlers (ImportResource, ImportVCardResource) to handle different import scenarios and maintain single responsibility principle
- Add integration tests that verify compatibility with major CardDAV implementations (Nextcloud, Radicale, Apple Calendar Server) to ensure broad compatibility

<enforcement>
Claude Code MUST verify all acceptance criteria before proceeding. Verification is mandatory and cannot be deferred. All DAV backend implementations MUST implement IDAVBackend interface, DTO models MUST be used consistently, exception handling MUST use DavServerNotCompliantException, and separate import resource handlers MUST exist for DAV and vCard operations.
</enforcement>
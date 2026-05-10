<rule_activation id="4f982fa8-5f95-4a92-bd62-6dcca1cfcbed" title="Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Import Operations Provide" applies_to="app/Domains/Contact/**/*">
These rules are ALWAYS ACTIVE for all external contact synchronization integrations and DAV protocol implementations within the Contact domain.
</rule_activation>

### Rules

- **R-DAV-001** SHOULD: Import operations SHOULD provide separate resource handlers for generic DAV imports and vCard-specific imports.
- **R-DAV-002** MUST: All DAV backend implementations MUST implement the IDAVBackend interface.
- **R-DAV-003** MUST: External API communication MUST use ContactDto and ContactDeleteDto models consistently across all DAV client services.
- **R-DAV-004** SHOULD: Error handling SHOULD use DavServerNotCompliantException to distinguish protocol compliance issues from other errors.

### Verify

```bash
# Verify IDAVBackend interface implementation
grep -r "IDAVBackend" app/Domains/Contact/Dav/ --include="*.php" | wc -l

# Verify ContactDto and ContactDeleteDto usage
grep -r "ContactDto\|ContactDeleteDto" app/Domains/Contact/DavClient/ --include="*.php" | wc -l

# Verify DavServerNotCompliantException usage
grep -r "DavServerNotCompliantException" app/Domains/Contact/ --include="*.php" | wc -l

# Verify Import resource handlers
find app/Domains/Contact/Dav* -name "*Import*Resource.php" -o -name "*VCard*.php" | wc -l
```

**Accept when:**
- All DAV backend implementations implement the IDAVBackend interface (verify command returns > 0)
- Contact DTO models are consistently used across DavClient services (verify command returns >= 2 for both DTOs)
- DavServerNotCompliantException is present and used for error handling (verify command returns > 0)
- Import resource handlers exist for DAV and vCard operations (verify command returns >= 2)

<enforcement>
Claude Code MUST verify these rules when working with CardDAV/WebDAV contact synchronization code. Verification is mandatory before completing changes to the Contact domain DAV implementations.
</enforcement>
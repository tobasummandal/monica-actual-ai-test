<rule_activation id="7fad0b4e-7d19-4c5d-b0ee-fd940e03ecb1" title="Adopt Domain-Driven Service Layer Pattern for Journal Management: Service Class Names" applies_to="app/Domains/**/Services/**/*.php">
These rules are ALWAYS ACTIVE for all service files in domain-driven architecture.

**In scope:**
- All journal management operations including posts, metrics, photos, tags, slices of life, and contacts
- Business logic that requires database transactions or multiple model interactions
- Operations that enforce domain-specific business rules and validation
- Functionality within the Vault domain's ManageJournals subdomain

**Out of scope:**
- Simple CRUD operations that only involve single-model persistence without business logic
- HTTP request/response handling and view rendering (belongs in controllers)
- Cross-domain operations that span multiple bounded contexts
- Infrastructure concerns like caching, logging, and external API integration
</rule_activation>

### Rules

- **R-SVC-001** SHOULD: Service class names SHOULD use verb-noun naming convention that clearly describes the operation (e.g., RemoveContactFromPost, IncrementPostReadCounter, CreatePost, UpdateMetric, RemoveTag).

### Implementation Notes

- Use verb-noun naming for service classes to clearly communicate intent
- Keep controllers thin - they should validate input, call services, and return responses without implementing business logic
- Services should accept primitive types or DTOs as parameters rather than HTTP request objects to maintain independence from web layer
- Consider using dependency injection for service dependencies to improve testability and enable mocking
- Group related services in subdirectories if a domain grows large (e.g., ManageJournals/Services/Posts, ManageJournals/Services/Metrics)

### Verify

```bash
# Count service classes in Services directories
find app/Domains/*/Services -type f -name '*.php' | wc -l

# Verify controllers exist and delegate to services
grep -r 'class.*Controller' app/Domains/Vault/ManageJournals/Web/Controllers | wc -l

# Check service namespace organization
grep -r 'namespace.*Services' app/Domains/Vault/ManageJournals/Services | head -5
```

**Accept when:**
- Service classes exist in dedicated Services directories within domain boundaries
- Controllers delegate to services rather than implementing business logic directly
- Service class names follow verb-noun convention and implement single-responsibility operations

<enforcement>
Claude Code MUST verify service class naming follows verb-noun convention during code review. Business logic MUST NOT be implemented directly in controllers - it MUST be delegated to service classes.
</enforcement>
<rule_activation id="7fad0b4e-7d19-4c5d-b0ee-fd940e03ecb1" title="Adopt Domain-Driven Service Layer Pattern for Journal Management: Service Class Names" applies_to="app/Domains/Vault/ManageJournals/**/*.php">
These rules are ALWAYS ACTIVE for all service layer classes within the Vault domain's ManageJournals subdomain.
</rule_activation>

### Rules

- **R-DDSVC-001** SHOULD: Service class names SHOULD use verb-noun naming convention that clearly describes the operation (e.g., RemoveContactFromPost, IncrementPostReadCounter).

### Verify

```bash
# Count service classes in ManageJournals domain
find app/Domains/Vault/ManageJournals/Services -type f -name '*.php' | wc -l

# Count controllers in ManageJournals domain
grep -r 'class.*Controller' app/Domains/Vault/ManageJournals/Web/Controllers | wc -l

# Verify service namespace structure
grep -r 'namespace.*Services' app/Domains/Vault/ManageJournals/Services | head -5

# Check for business logic in controllers (should be minimal)
grep -r 'DB::transaction\|Model::create\|->save()' app/Domains/Vault/ManageJournals/Web/Controllers | wc -l
```

**Accept when:**
- Service classes exist in dedicated Services directories within domain boundaries (app/Domains/Vault/ManageJournals/Services/)
- Controllers delegate to services rather than implementing business logic directly
- Service class names follow verb-noun convention (e.g., CreatePost, UpdateMetric, RemoveTag, IncrementPostReadCounter)
- Service classes implement single-responsibility operations
- Services accept primitive types or DTOs as parameters rather than HTTP request objects
- Related services are grouped in subdirectories when domain grows large (e.g., ManageJournals/Services/Posts, ManageJournals/Services/Metrics)

<enforcement>
Claude Code MUST verify service layer naming and structure during code review. Violations require refactoring of business logic into appropriately named service classes before acceptance. Architecture review is mandatory for new domains or subdomains.
</enforcement>
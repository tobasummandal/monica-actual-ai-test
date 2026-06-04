<rule_activation id="8edc9dab-8a23-4a8f-9dc7-c078feee8f99" title="Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Database Entities Represented" applies_to="**/*">
These rules are ALWAYS ACTIVE for all data modeling and database access patterns within the application codebase.
</rule_activation>

### Rules

- **R-EDL-001** MUST: All database entities MUST be represented by Eloquent Model classes extending Illuminate\Database\Eloquent\Model

### Scope

**In scope:**
- All persistent domain entities requiring database storage
- Data access operations for CRUD functionality
- Relationship definitions between domain entities
- Data validation and transformation at the model layer
- Query building and data retrieval patterns

**Out of scope:**
- Temporary data structures not persisted to database
- View models or DTOs used solely for presentation
- External API response objects
- Performance-critical bulk operations requiring raw SQL
- Database migrations and schema definitions

**Exceptions:**
- EXC-001: Performance profiling demonstrates that Eloquent overhead causes unacceptable latency (>100ms) for high-frequency queries
- EXC-002: Complex analytical queries requiring database-specific features not supported by Eloquent query builder

### Verify

```bash
# Count all model classes extending Eloquent Model
grep -r "class.*extends.*Model" app/Models/ | wc -l

# Check for syntax errors in model files
find app/Models -name '*.php' -exec php -l {} \; | grep -v 'No syntax errors'

# Count raw database queries outside models (should be minimal and documented)
grep -r "DB::raw\|DB::select\|DB::statement" app/ --exclude-dir=Models | wc -l
```

**Accept when:**
- All model classes in app/Models extend Illuminate\Database\Eloquent\Model
- No syntax errors in model files and all models are loadable by PHP parser
- Raw database queries outside models are documented with justification or count is below threshold (e.g., <5 instances)
- All public methods, relationships, and custom attributes are documented in PHPDoc blocks
- Model classes use $casts property for consistent type handling
- Query scopes encapsulate common filtering patterns

<enforcement>
Claude Code MUST NOT skip or defer verification. Automated static analysis in CI pipeline MUST check model inheritance. Code review MUST require justification for raw SQL queries. PHPStan or Psalm rules MUST enforce model conventions. Query monitoring in staging environment MUST detect N+1 problems. CI pipeline MUST fail if models do not extend base Eloquent Model class.
</enforcement>
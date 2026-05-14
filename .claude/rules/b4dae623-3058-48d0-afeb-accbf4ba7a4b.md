<rule_activation id="b4dae623-3058-48d0-afeb-accbf4ba7a4b" title="Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Include Accessor" applies_to="**/*">
These rules are ALWAYS ACTIVE for all data modeling implementations in the application layer. All domain entities requiring database persistence MUST be represented using Eloquent ORM models.
</rule_activation>

### Rules

- **R-ELQ-001** MAY: Models MAY include accessor and mutator methods for computed attributes or attribute transformation.
- **R-ELQ-002** MUST: All model classes in app/Models directory extend Illuminate\Database\Eloquent\Model.
- **R-ELQ-003** MUST: Place all model classes in app/Models directory with singular, PascalCase naming (e.g., User, PostTemplateSection, ContactInformationType).
- **R-ELQ-004** MUST: Define $fillable or $guarded properties in each model to control mass assignment. Prefer $fillable for explicit whitelisting.
- **R-ELQ-005** SHOULD: Use $casts property to define attribute type casting (e.g., 'is_active' => 'boolean', 'metadata' => 'array', 'published_at' => 'datetime').
- **R-ELQ-006** SHOULD: Define relationships using Eloquent methods (hasMany, belongsTo, belongsToMany, morphMany, etc.) with proper return type hints.
- **R-ELQ-007** SHOULD: Use query scopes (scopeActive, scopeRecent, etc.) for reusable query logic specific to the model.
- **R-ELQ-008** SHOULD: Leverage model events (creating, created, updating, updated, deleting, deleted) for cross-cutting concerns like logging or cache invalidation.
- **R-ELQ-009** SHOULD: Use eager loading (with() method) to prevent N+1 query problems when accessing relationships.
- **R-ELQ-010** SHOULD: Consider using API resources or transformers for serialization rather than exposing raw model attributes.
- **R-ELQ-011** MUST NOT: Place excessive business logic in model classes; business logic belongs in service classes or domain services.
- **R-ELQ-012** MUST NOT: Create model classes outside app/Models directory.

### Verify

```bash
# Count Eloquent models in app/Models
grep -r "extends Model" app/Models/ | wc -l

# Find model files missing Eloquent import
find app/Models -type f -name '*.php' -exec grep -L 'use Illuminate\\Database\\Eloquent\\Model' {} \;

# Display model structure summary
php artisan model:show --all 2>&1 | grep -E '(class|table)' | head -20
```

**Accept when:**
- All model files in app/Models directory extend Illuminate\Database\Eloquent\Model
- Each model class corresponds to a database table and follows Laravel naming conventions
- Models define appropriate fillable/guarded properties and casts for type safety
- Relationships between entities are defined using Eloquent relationship methods
- No raw SQL queries exist where Eloquent could reasonably be used instead
- Model classes do not contain excessive business logic (logic is in service classes)
- No models exist outside the app/Models directory

<enforcement>
Claude Code MUST verify all R-ELQ rules during code review. Violations of MUST-level rules (R-ELQ-002, R-ELQ-003, R-ELQ-004, R-ELQ-011, R-ELQ-012) block acceptance. SHOULD-level rules (R-ELQ-005 through R-ELQ-010) should be addressed unless technically justified. MAY-level rules (R-ELQ-001) are optional but recommended. Verification is mandatory before approving any model class implementations.
</enforcement>
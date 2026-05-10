<rule_activation id="fbd258be-d6a7-4afd-9a2f-02e6f41ab1e2" title="Adopt Eloquent ORM Models as Standard Data Modeling Pattern" applies_to="app/Models/**/*.php">
These rules are ALWAYS ACTIVE for all data modeling implementations in the application layer. All domain entities requiring database persistence MUST be represented using Eloquent ORM models.
</rule_activation>

### Rules

**Note:** The source ADR does not contain explicit R-PREFIX-### rule identifiers. The following rules are extracted from the Decision and Policy Block sections:

- **MUST**: All domain entities requiring database persistence MUST be represented using Eloquent ORM models.
- **SHOULD**: Models SHOULD define their fillable or guarded properties to control mass assignment protection.

**In scope:**
- All domain entities requiring database persistence (users, accounts, files, templates, etc.)
- Entities with relationships to other database-backed entities
- Data models requiring ORM features like eager loading, lazy loading, or relationship management
- Entities requiring attribute casting, accessors, mutators, or event handling

**Out of scope:**
- Value objects that do not require database persistence
- Data Transfer Objects (DTOs) used for API communication
- View models or presentation layer objects
- Temporary data structures used only in memory
- External API response models that don't map to local database tables

**Exceptions:**
- EXC-001: Legacy database schemas require custom query builder usage that Eloquent cannot efficiently handle
- EXC-002: Performance-critical operations require raw SQL queries or database-specific features

### Verify

```bash
grep -r "extends Model" app/Models/ | wc -l
find app/Models -type f -name '*.php' -exec grep -L 'use Illuminate\\Database\\Eloquent\\Model' {} \;
php artisan model:show --all 2>&1 | grep -E '(class|table)' | head -20
```

**Accept when:**
- All model files in app/Models directory extend Illuminate\Database\Eloquent\Model
- Each model class corresponds to a database table and follows Laravel naming conventions
- Models define appropriate fillable/guarded properties and casts for type safety
- Relationships between entities are defined using Eloquent relationship methods
- No raw SQL queries exist where Eloquent could reasonably be used instead

### Implementation Guidance

- Place all model classes in app/Models directory with singular, PascalCase naming (e.g., User, PostTemplateSection, ContactInformationType)
- Define $fillable or $guarded properties in each model to control mass assignment. Prefer $fillable for explicit whitelisting.
- Use $casts property to define attribute type casting (e.g., 'is_active' => 'boolean', 'metadata' => 'array', 'published_at' => 'datetime')
- Define relationships using Eloquent methods (hasMany, belongsTo, belongsToMany, morphMany, etc.) with proper return type hints
- Use query scopes (scopeActive, scopeRecent, etc.) for reusable query logic specific to the model
- Leverage model events (creating, created, updating, updated, deleting, deleted) for cross-cutting concerns like logging or cache invalidation
- Use eager loading (with() method) to prevent N+1 query problems when accessing relationships
- Consider using API resources or transformers for serialization rather than exposing raw model attributes

<enforcement>
Verification is MANDATORY. Claude Code MUST NOT skip or defer verification when working with model classes in app/Models directory.

**Enforcement mechanisms:**
- Automated code review checks in CI pipeline scanning for Model class structure
- PHPStan or Psalm static analysis rules enforcing Eloquent usage patterns
- Manual code review checklist items for new model classes
- Architecture decision review for any exceptions to the pattern

**Violation handling:**
- CI pipeline fails if model classes are created outside app/Models directory
- Code review blocks merge if models don't extend Eloquent Model base class
- Static analysis warnings for missing fillable/guarded properties
- Performance monitoring alerts for N+1 query patterns in production

**Exception process:**
1. Developer documents specific technical limitation requiring exception in code comments
2. Tech lead or architect reviews exception request with justification
3. Exception is documented in ADR exceptions log with approval date and reviewer
4. Exception includes plan for future refactoring if applicable
</enforcement>
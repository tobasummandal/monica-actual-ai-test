<rule_activation id="fbd258be-d6a7-4afd-9a2f-02e6f41ab1e2" title="Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Their" applies_to="app/Models/**/*.php">
These rules are ALWAYS ACTIVE for all data modeling implementations in the application layer. All domain entities requiring database persistence MUST be represented using Eloquent ORM models.
</rule_activation>

### Rules

- **R-ELQ-001** MUST: All domain entities requiring database persistence MUST be represented using Eloquent ORM models extending `Illuminate\Database\Eloquent\Model`.
- **R-ELQ-002** SHOULD: Models SHOULD define their `$fillable` or `$guarded` properties to control mass assignment protection. Prefer `$fillable` for explicit whitelisting.
- **R-ELQ-003** SHOULD: Models SHOULD use `$casts` property to define attribute type casting (e.g., `'is_active' => 'boolean'`, `'metadata' => 'array'`, `'published_at' => 'datetime'`).
- **R-ELQ-004** SHOULD: Models SHOULD define relationships using Eloquent methods (hasMany, belongsTo, belongsToMany, morphMany, etc.) with proper return type hints.
- **R-ELQ-005** SHOULD: Models SHOULD use query scopes (scopeActive, scopeRecent, etc.) for reusable query logic specific to the model.
- **R-ELQ-006** SHOULD: Models SHOULD leverage model events (creating, created, updating, updated, deleting, deleted) for cross-cutting concerns like logging or cache invalidation.
- **R-ELQ-007** MUST: Developers MUST use eager loading (with() method) to prevent N+1 query problems when accessing relationships.
- **R-ELQ-008** SHOULD: Models SHOULD use API resources or transformers for serialization rather than exposing raw model attributes.
- **R-ELQ-009** MUST: All model classes MUST be placed in `app/Models` directory with singular, PascalCase naming (e.g., User, PostTemplateSection, ContactInformationType).

### In Scope

- All domain entities requiring database persistence (users, accounts, files, templates, etc.)
- Entities with relationships to other database-backed entities
- Data models requiring ORM features like eager loading, lazy loading, or relationship management
- Entities requiring attribute casting, accessors, mutators, or event handling

### Out of Scope

- Value objects that do not require database persistence
- Data Transfer Objects (DTOs) used for API communication
- View models or presentation layer objects
- Temporary data structures used only in memory
- External API response models that don't map to local database tables

### Exceptions

- **EXC-001**: Legacy database schemas require custom query builder usage that Eloquent cannot efficiently handle
- **EXC-002**: Performance-critical operations require raw SQL queries or database-specific features

### Verify

```bash
# Count Eloquent models in app/Models directory
grep -r "extends Model" app/Models/ | wc -l

# Find model files missing Eloquent Model import
find app/Models -type f -name '*.php' -exec grep -L 'use Illuminate\\Database\\Eloquent\\Model' {} \;

# Display model structure summary
php artisan model:show --all 2>&1 | grep -E '(class|table)' | head -20
```

**Accept when:**
- All model files in `app/Models` directory extend `Illuminate\Database\Eloquent\Model`
- Each model class corresponds to a database table and follows Laravel naming conventions
- Models define appropriate `$fillable` or `$guarded` properties and `$casts` for type safety
- Relationships between entities are defined using Eloquent relationship methods
- No raw SQL queries exist where Eloquent could reasonably be used instead
- Query scopes are used for reusable query logic specific to models
- Eager loading is implemented to prevent N+1 query problems

<enforcement>
Claude Code MUST verify all rules in this activation block. Verification is mandatory before accepting model implementations. CI pipeline MUST fail if model classes are created outside `app/Models` directory or don't extend Eloquent Model base class. Static analysis warnings MUST be addressed for missing `$fillable`/`$guarded` properties.
</enforcement>
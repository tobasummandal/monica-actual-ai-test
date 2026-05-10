<rule_activation id="b4dae623-3058-48d0-afeb-accbf4ba7a4b" title="Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Include Accessor" applies_to="**/*">
These rules are ALWAYS ACTIVE for all data modeling implementations in the application layer. All domain entities requiring database persistence MUST be represented using Eloquent ORM models.
</rule_activation>

### Rules

**Note:** The source ADR does not include explicit R-PREFIX-### rule identifiers. The following rule is extracted from the Decision/Policy Block section:

- **MAY**: Models MAY include accessor and mutator methods for computed attributes or attribute transformation

### Scope

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
# Count model files extending Model class
grep -r "extends Model" app/Models/ | wc -l

# Find model files not using Eloquent Model
find app/Models -type f -name '*.php' -exec grep -L 'use Illuminate\\Database\\Eloquent\\Model' {} \;

# Show model structure and tables
php artisan model:show --all 2>&1 | grep -E '(class|table)' | head -20
```

**Accept when:**
- All model files in app/Models directory extend Illuminate\Database\Eloquent\Model
- Each model class corresponds to a database table and follows Laravel naming conventions
- Models define appropriate fillable/guarded properties and casts for type safety
- Relationships between entities are defined using Eloquent relationship methods
- No raw SQL queries exist where Eloquent could reasonably be used instead

<enforcement>
Claude Code MUST NOT skip or defer verification. Automated code review checks in CI pipeline MUST scan for Model class structure. PHPStan or Psalm static analysis rules MUST enforce Eloquent usage patterns. Manual code review checklist items MUST verify new model classes. Architecture decision review MUST evaluate any exceptions to the pattern.
</enforcement>
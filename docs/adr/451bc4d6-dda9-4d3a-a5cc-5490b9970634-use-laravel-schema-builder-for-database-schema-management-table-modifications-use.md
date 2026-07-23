# Use Laravel Schema Builder for Database Schema Management: Table Modifications Use

Status: proposed
Date: 2025-02-24
Deciders: Detection Pipeline (automated)

## Context

- The application uses Laravel's migration system to version-control database schema changes across environments
- Schema modifications are expressed through Blueprint objects using a fluent API rather than raw SQL DDL statements
- The codebase demonstrates schema evolution patterns including adding columns to existing tables and creating new tables with foreign key constraints
- Database operations combine schema management (Schema facade) with data manipulation (DB facade) within the same migration files

## Problem Statement

Database schema changes must be version-controlled, reversible, and portable across different database engines without requiring manual SQL script management or environment-specific DDL syntax.

## Decision

1. MUST: Table modifications MUST use Schema::table() with Blueprint closure specifying alterations

## Policy Block

- MUST Table modifications MUST use Schema::table() with Blueprint closure specifying alterations

In scope:
- All database table creation, modification, and deletion operations
- Column additions, removals, and type changes
- Index and constraint management
- Foreign key relationship definitions
- Reference data seeding that must be synchronized with schema versions

Out of scope:
- Application-level data access logic (handled by Eloquent models)
- Query optimization and performance tuning
- Database-specific stored procedures or triggers
- Runtime data manipulation outside of migrations
- Database connection configuration

Exceptions:
- EXC-001: Complex database-specific features require raw SQL that cannot be expressed through Blueprint API

## Rationale

- The evidence shows consistent use of Schema::create() and Schema::table() with Blueprint closures across migration files, demonstrating an established pattern for database-agnostic schema management
- Laravel's migration system provides version control for schema changes with automatic rollback capability through down() methods, as evidenced by the paired up/down implementations
- The pattern enables portability across database engines (MySQL, PostgreSQL, SQLite) by abstracting DDL syntax behind the Blueprint API
- Integration of DB facade for data operations within migrations allows atomic schema and data changes, as seen in the currencies table population

## Consequences

Positive:
- Database schema changes are version-controlled and tracked in source control alongside application code
- Schema modifications are reversible through migration rollback, reducing deployment risk
- Database engine portability is maintained without writing engine-specific SQL
- Team members can understand schema changes through readable PHP code rather than parsing SQL DDL

Negative:
- Complex database-specific features may require workarounds or raw SQL escapes from the Blueprint API
- Migration execution order dependencies can create coupling between migration files
- Large data migrations within schema migrations can cause extended deployment downtime
- Blueprint API learning curve for developers unfamiliar with Laravel conventions

## Alternatives

- Use raw SQL migration files managed by a database versioning tool like Flyway or Liquibase (rejected)
  Rejected because: Requires maintaining separate SQL dialects for each target database engine and loses integration with Laravel's ORM and model layer
  When valid: When working with legacy databases or complex stored procedures that cannot be expressed through an ORM abstraction
- Use Doctrine DBAL schema manager for database-agnostic schema operations (rejected)
  Rejected because: Adds additional dependency and diverges from Laravel ecosystem conventions, reducing team familiarity
  When valid: When requiring advanced schema introspection capabilities not available in Laravel's Schema builder
- Manual schema management through direct database administration (rejected)
  Rejected because: Eliminates version control, reproducibility, and automated deployment capabilities for schema changes
  When valid: Never appropriate for production applications requiring deployment automation

## Risks

- Migration execution failures in production can leave database in inconsistent state if down() method is incomplete or untested
  Mitigation: Require migration testing in staging environments and implement database backup procedures before production deployments
  Owner: Engineering team and DevOps
- Blueprint API limitations may force raw SQL usage for advanced database features, breaking portability guarantees
  Mitigation: Document database-specific requirements early in design phase and evaluate whether portability is a hard requirement
  Owner: Database architect
- Large data migrations within schema migrations can cause deployment timeouts or lock contention
  Mitigation: Separate large data migrations into dedicated background jobs or multi-phase deployments with feature flags
  Owner: Engineering team

## Implementation Notes

- Create migration files using php artisan make:migration command with descriptive names following Laravel naming conventions
- Always test both up() and down() methods in development environment before committing migrations
- Use Blueprint column modifiers (nullable(), after(), default()) to specify column attributes declaratively
- For foreign keys, prefer foreignIdFor() with constrained() over manual foreign() definitions for consistency with Eloquent models
- When combining schema and data operations, wrap operations in DB::transaction() if atomicity is required
- Document any raw SQL usage with comments explaining why Blueprint API was insufficient

## Continuation Context


Verify commands:
- grep -r "Schema::create\|Schema::table" database/migrations/ | wc -l
- grep -r "extends.*Migration" database/migrations/ | wc -l
- php artisan migrate:status | grep -c "Ran"

Accept when:
- All migration files extend Illuminate\Database\Migrations\Migration class
- Schema modifications use Schema facade with Blueprint closures rather than raw SQL DDL
- Migration status command shows all migrations have been executed successfully in test environment

## Enforcement

- Verified by: Code review process checking migration file structure and Blueprint API usage
- Verified by: CI pipeline running migration tests against multiple database engines
- Verified by: Static analysis tools scanning for raw SQL DDL statements outside approved patterns
- Violation handling: Pull requests containing raw SQL DDL without justification are rejected
- Violation handling: Migrations missing down() methods trigger automated review comments
- Violation handling: Database schema changes bypassing migration system require incident review and remediation
- Exception process: Developer documents database-specific requirement that cannot be expressed through Blueprint API
- Exception process: Database architect reviews and approves raw SQL usage with portability impact assessment
- Exception process: Exception is documented in migration file comments with rationale and database compatibility notes
# Adopt Laravel Migrations as Standard Database Schema Management: Migration Files Atomic

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all database schema changes across the application. All schema modifications MUST be implemented through Laravel migration files.

## Context

- The application requires a systematic approach to database schema evolution that supports version control, team collaboration, and deployment automation
- Laravel framework provides a migration system that allows database schema changes to be defined as code, enabling reproducible deployments across environments
- Pattern detected across 16 migration files covering diverse domain entities (calls, journals, posts, companies, addresses, religions, gifts, life events, etc.) indicating comprehensive adoption
- Migration files follow Laravel's timestamp-based naming convention (YYYY_MM_DD_HHMMSS_description.php) ensuring chronological ordering and preventing conflicts
- The facet 'data.schema_management' with 80% confidence indicates this is a deliberate architectural choice for managing database structure

## Problem Statement

Database schema changes need to be versioned, tracked, and deployed consistently across development, staging, and production environments. Manual SQL scripts are error-prone, difficult to rollback, and lack integration with application code. Teams need a standardized way to evolve database structure that integrates with version control systems and supports collaborative development.

## Decision

1. SHOULD: Migration files SHOULD be atomic, focusing on a single logical schema change to facilitate easier rollback and debugging

## Policy Block

- SHOULD Migration files SHOULD be atomic, focusing on a single logical schema change to facilitate easier rollback and debugging

In scope:
- All table creation, modification, and deletion operations
- Column additions, modifications, and removals
- Index creation and removal
- Foreign key constraint definitions
- Database-level configuration changes that affect schema structure

Out of scope:
- Application data seeding for testing purposes (use database/seeders instead)
- Data migration or transformation scripts that don't modify schema structure
- Database performance tuning that doesn't affect schema (query optimization, connection pooling)
- Backup and restore operations

Exceptions:
- EXC-001: Emergency production hotfix requiring immediate schema change to resolve critical outage
- EXC-002: Database-specific optimizations requiring raw SQL that cannot be expressed through Schema Builder

## Rationale

- Pattern detected across 16 files with 80% confidence indicates this is an established, consistent practice across the codebase
- Laravel migrations provide version control integration, allowing schema changes to be tracked alongside application code changes in Git
- The Schema Builder API provides database abstraction, enabling the application to support multiple database engines (MySQL, PostgreSQL, SQLite) without rewriting migrations
- Timestamp-based naming convention prevents migration conflicts in team environments where multiple developers create migrations simultaneously
- Built-in rollback capability through down() methods provides safety net for deployment issues and supports blue-green deployment strategies

## Consequences

Positive:
- Schema changes are versioned and tracked in source control, providing complete audit trail of database evolution
- Automated deployment pipelines can reliably apply schema changes across environments using 'php artisan migrate' command
- Team collaboration is improved as migration conflicts are detected early through version control merge conflicts
- Database schema becomes self-documenting through migration history, making it easier for new developers to understand system evolution
- Rollback capability provides safety mechanism for deployment issues, reducing risk of schema change deployments

Negative:
- Additional abstraction layer may obscure complex database-specific optimizations or features not supported by Schema Builder
- Migration history can grow large over time, requiring periodic squashing or cleanup strategies for long-lived projects
- Developers must learn Laravel migration syntax and conventions rather than working directly with familiar SQL
- Rollback operations may not always be safe for destructive changes (dropping columns with data), requiring careful planning

## Alternatives

- Use raw SQL migration scripts managed manually or through custom tooling (rejected)
  Rejected because: Raw SQL scripts lack framework integration, are database-specific, don't provide automatic rollback capability, and are harder to version control effectively. The detected pattern shows zero usage of this approach.
  When valid: May be considered for database-specific features that absolutely cannot be expressed through Laravel's Schema Builder
- Use third-party database migration tools like Flyway or Liquibase (rejected)
  Rejected because: Introduces additional tooling complexity and dependencies outside the Laravel ecosystem. Laravel migrations are already integrated with the framework and provide sufficient functionality for the application's needs.
  When valid: Could be considered for polyglot environments where multiple frameworks share the same database
- Use ORM-based automatic schema generation from model definitions (rejected)
  Rejected because: Automatic schema generation lacks explicit control over migration timing, doesn't provide clear audit trail, and makes it difficult to handle complex schema changes or data migrations. Explicit migrations provide better control and visibility.
  When valid: May be useful for rapid prototyping in early development stages, but should transition to explicit migrations before production

## Risks

- Migration execution failures in production could leave database in inconsistent state if not properly tested
  Mitigation: Implement comprehensive testing of migrations in staging environments that mirror production. Use database transactions where possible. Maintain rollback plans and database backups before major migrations.
  Owner: Engineering team and DevOps
- Long-running migrations on large tables could cause downtime or lock contention in production
  Mitigation: Analyze migration impact before deployment. Use online schema change tools for large tables. Consider blue-green deployment strategies. Test migrations against production-sized datasets in staging.
  Owner: Database Administrator and Engineering team
- Accumulation of many migration files over time could slow down fresh installations and complicate codebase navigation
  Mitigation: Periodically squash old migrations into consolidated schema files for projects with long history. Document migration squashing process. Consider using Laravel's schema dump feature for baseline schema.
  Owner: Engineering team

## Implementation Notes

- Use 'php artisan make:migration' command to generate new migration files with proper timestamp and structure
- Always test migrations locally with both 'migrate' and 'migrate:rollback' commands before committing to ensure down() method works correctly
- For complex data transformations, consider separating schema changes from data migrations into distinct migration files for clarity
- Document any database-specific SQL used in migrations with comments explaining compatibility implications
- Use Laravel's migration methods like 'foreignId()', 'timestamps()', 'softDeletes()' for consistency with framework conventions
- Review migration execution order carefully when multiple developers create migrations in parallel branches

## Continuation Context


Verify commands:
- find database/migrations -name '*.php' -type f | wc -l | grep -E '^[0-9]+$'
- grep -r 'Schema::create\|Schema::table\|Schema::drop' database/migrations/ | wc -l
- php artisan migrate:status 2>&1 | grep -E 'Ran|Pending'
- ls database/migrations/*.php 2>/dev/null | head -5 | xargs grep -l 'function up()' | xargs grep -l 'function down()'

Accept when:
- All migration files exist in database/migrations directory and follow Laravel naming convention with timestamps
- Each migration file contains both up() and down() methods using Schema Builder API
- Migration status command executes successfully showing tracked migrations
- No direct SQL schema modifications are found in application code outside migration files

## Enforcement

- Verified by: Automated CI pipeline checks verify migration file structure and naming conventions
- Verified by: Code review process ensures all schema changes are implemented through migrations
- Verified by: Pre-deployment checks run 'php artisan migrate:status' to verify migration state
- Verified by: Static analysis tools scan for direct SQL schema modification patterns outside migrations
- Violation handling: Pull requests containing direct SQL schema changes are automatically flagged and rejected by CI
- Violation handling: Production deployments are blocked if migration status shows inconsistencies
- Violation handling: Manual schema changes detected in production trigger alerts to DevOps team for remediation
- Violation handling: Violations require creation of corresponding migration file and documentation of incident
- Exception process: Exception requests must be submitted through architecture review board with detailed justification
- Exception process: Emergency exceptions require post-incident review and creation of compensating migration within 24 hours
- Exception process: All exceptions must be documented in ADR updates or exception log with rationale and approval chain
- Exception process: Temporary exceptions are reviewed quarterly to determine if they can be brought into compliance
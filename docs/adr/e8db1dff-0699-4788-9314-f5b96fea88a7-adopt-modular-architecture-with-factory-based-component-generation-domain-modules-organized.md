# Adopt Modular Architecture with Factory-Based Component Generation: Domain Modules Organized

Status: proposed
Date: 2024-01-20
Deciders: Detection Pipeline (automated)

## Context

- The codebase demonstrates a consistent pattern of modular component organization with factory-based data generation across 7 files with 77.83% confidence
- Console commands (SetupDocumentation.php, SetupApplication.php) and scheduling infrastructure (Schedule.php) indicate a need for structured initialization and lifecycle management
- Database factories (ModuleFactory, ModuleRowFactory, LifeEventCategoryFactory) reveal a domain-driven design approach with reusable component generation
- View helpers (ContactShowViewHelper) and domain-specific modules suggest a layered architecture with clear separation between presentation, business logic, and data layers
- The governance.docs facet indicates this pattern is part of documented architectural standards for managing libraries and modules

## Problem Statement

The application requires a standardized approach to organizing, initializing, and managing modular components across different domains (Contact, Console, Database) while maintaining consistency in component generation, lifecycle management, and inter-module dependencies. Without clear architectural guidance, teams may implement inconsistent module structures, leading to maintenance challenges and reduced code reusability.

## Decision

1. MUST: All domain modules MUST be organized under a clear namespace hierarchy following the pattern app/Domains/{Domain}/{Subdomain}/{Layer}

## Policy Block

- MUST All domain modules MUST be organized under a clear namespace hierarchy following the pattern app/Domains/{Domain}/{Subdomain}/{Layer}

In scope:
- All application modules and domain components
- Database factories for test data generation and seeding
- Console commands for setup, initialization, and maintenance
- View helpers and presentation layer components
- Scheduled task definitions and cron job management

Out of scope:
- Third-party vendor packages and external libraries
- Framework core files and base classes
- Configuration files and environment-specific settings
- Static assets and frontend build artifacts

Exceptions:
- EX-001: Legacy modules predating this ADR that require significant refactoring effort
- EX-002: Rapid prototyping or proof-of-concept code in designated experimental branches

## Rationale

- The pattern appears consistently across 7 files with 77.83% confidence, indicating this is an established architectural standard rather than an isolated implementation
- Factory-based component generation enables consistent test data creation, easier testing, and improved developer experience when working with complex domain entities
- Centralized setup commands and scheduling infrastructure reduce duplication and provide clear entry points for application initialization and maintenance tasks
- Domain-driven module organization with clear layer separation (Web, Console, Database) improves code discoverability and enforces architectural boundaries

## Consequences

Positive:
- Improved code organization and discoverability through consistent namespace hierarchy and file placement conventions
- Enhanced testability via factory-based data generation enabling easy creation of test fixtures and seed data
- Reduced cognitive load for developers through standardized patterns for common tasks (setup, scheduling, view helpers)
- Better maintainability as module boundaries are clearly defined and inter-module dependencies are explicit

Negative:
- Initial learning curve for developers unfamiliar with the domain-driven module structure and factory pattern
- Potential over-engineering for simple modules that don't require full factory infrastructure
- Additional boilerplate code required for each new module (factory classes, setup commands, view helpers)
- Risk of namespace conflicts if domain boundaries are not carefully planned and documented

## Alternatives

- Flat directory structure with all components in top-level directories organized by type (Controllers, Models, Views) (rejected)
  Rejected because: Flat structure doesn't scale well for large applications and makes domain boundaries unclear, leading to tight coupling between unrelated components
  When valid: May be acceptable for very small applications with fewer than 5 domain concepts
- Microservices architecture with each domain as a separate service with its own repository (rejected)
  Rejected because: Introduces significant operational complexity, deployment overhead, and inter-service communication challenges that outweigh benefits for current application scale
  When valid: Should be reconsidered if application grows beyond 50 domains or requires independent scaling of specific modules
- Package-based architecture using Composer packages for each reusable module (deferred)
  Rejected because: Adds complexity of package versioning and dependency management without clear immediate benefit
  When valid: Should be adopted for modules that need to be shared across multiple applications or open-sourced independently

## Risks

- Inconsistent adoption across teams leading to mixed architectural patterns within the same codebase
  Mitigation: Implement automated linting rules to enforce namespace conventions and directory structure; provide code generation templates for new modules
  Owner: Engineering Team Lead
- Factory classes becoming outdated as domain models evolve, leading to test failures or incorrect seed data
  Mitigation: Include factory updates in definition of done for model changes; add CI checks to verify factory-generated data passes model validation
  Owner: QA Team
- Over-abstraction leading to unnecessary complexity for simple CRUD modules
  Mitigation: Document clear guidelines for when full modular structure is required vs. simplified approach; conduct architecture reviews for new domains
  Owner: Architecture Review Board

## Implementation Notes

- Use code generation tools or IDE templates to scaffold new modules with correct directory structure, namespace, and boilerplate factory/command classes
- Establish naming conventions: Domain names should be singular nouns (Contact, not Contacts), subdomain names should describe the capability (ManageContact), layer names should be standard (Web, Console, Database)
- Document module dependencies in a central registry or dependency graph to prevent circular dependencies and clarify initialization order
- Create a module checklist for code reviews: correct namespace, factory present if needed, setup command if initialization required, view helpers in Web layer

## Continuation Context


Verify commands:
- find app/Domains -type f -name '*.php' | xargs grep -L 'namespace App\\Domains' | wc -l | grep -q '^0$'
- find database/factories -type f -name '*Factory.php' | xargs grep -c 'extends Factory' | grep -v ':0'
- find app/Console/Commands -type f -name 'Setup*.php' | xargs grep -c 'extends Command' | grep -v ':0'

Accept when:
- All PHP files in app/Domains directory use the correct App\Domains namespace hierarchy
- All factory classes in database/factories extend the framework's base Factory class
- All setup commands in app/Console/Commands extend the framework's Command class and follow naming conventions

## Enforcement

- Verified by: Automated CI pipeline checks using PHPStan or Psalm to verify namespace conventions
- Verified by: Code review checklist requiring verification of module structure compliance
- Verified by: Pre-commit hooks validating file placement and class naming patterns
- Violation handling: CI pipeline fails if namespace conventions are violated, blocking merge
- Violation handling: Code review approval withheld until module structure compliance is achieved
- Violation handling: Technical debt tickets created for legacy code violations with prioritized remediation plan
- Exception process: Developer submits exception request to Technical Lead with justification and impact analysis
- Exception process: Technical Lead reviews with Architecture Review Board if exception affects multiple modules
- Exception process: Approved exceptions documented in ADR exceptions log with expiration date and migration plan
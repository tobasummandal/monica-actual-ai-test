# Adopt Domain-Driven Controller Organization for Journal Management: Controllers Placed Within

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The application implements a domain-driven architecture with bounded contexts organized under app/Domains/Vault/ManageJournals
- Journal management functionality requires multiple specialized controllers handling different aspects: journals, posts, photos, metrics, and slices of life
- Controllers are organized within a Web/Controllers namespace following Laravel framework conventions
- The pattern appears consistently across 8 controller files with high significance (79-81%), indicating a deliberate architectural choice
- This organization separates journal management concerns from other vault-related domains while maintaining framework compatibility

## Problem Statement

How should web controllers be organized in a domain-driven Laravel application to maintain clear boundaries between business domains while adhering to framework conventions and supporting complex feature sets like journal management with multiple related entities?

## Decision

1. MUST: Controllers MUST be placed within the Web/Controllers subdirectory of their domain to separate web concerns from other layers

## Policy Block

- MUST Controllers MUST be placed within the Web/Controllers subdirectory of their domain to separate web concerns from other layers

In scope:
- All web controllers within the Vault domain
- Controllers handling journal, post, photo, metric, and slice of life entities
- New controllers added to the ManageJournals bounded context
- API and web interface controllers for journal management

Out of scope:
- Service classes and business logic layers
- Data transfer objects and view models
- Repository implementations
- Console commands and CLI controllers
- Background job handlers

Exceptions:
- EX-001: A controller handles cross-domain concerns that cannot be reasonably placed within a single domain boundary
- EX-002: Legacy controllers exist outside this structure and refactoring would introduce significant risk

## Rationale

- The pattern demonstrates consistent application across 8 files with 79.75% confidence, indicating this is an established architectural standard rather than an accident
- Domain-driven organization improves code discoverability by grouping related controllers together based on business capabilities rather than technical layers
- Separating controllers by entity and concern (journals, posts, photos, metrics) prevents controller bloat and maintains single responsibility principle
- The Web/Controllers subdirectory structure allows for future expansion to include API controllers, GraphQL resolvers, or other interface types within the same domain

## Consequences

Positive:
- Improved code organization with clear domain boundaries makes it easier for developers to locate and modify journal-related functionality
- Single responsibility controllers are easier to test, maintain, and reason about compared to monolithic controllers
- Domain-driven structure scales well as new features are added to the journal management capability
- Clear separation between web layer and business logic enables easier refactoring and testing

Negative:
- Increased number of controller files may feel overwhelming to developers unfamiliar with domain-driven design
- Requires discipline to maintain consistent naming and organization as the codebase grows
- May lead to code duplication if common controller concerns are not properly abstracted into base classes or traits
- Navigation between related controllers requires understanding the domain structure rather than simple alphabetical file listing

## Alternatives

- Organize all controllers in a flat app/Http/Controllers directory following standard Laravel structure (rejected)
  Rejected because: Flat structure does not scale well for large applications with multiple domains and leads to controller bloat and poor discoverability
  When valid: Appropriate for small applications with fewer than 20 controllers and no clear domain boundaries
- Use feature-based organization where each feature has its own directory containing controllers, services, and models (rejected)
  Rejected because: Feature-based organization can lead to code duplication when features share entities and makes it harder to maintain consistent domain models
  When valid: Suitable for microservices or modular monoliths where features are truly independent with minimal shared code
- Combine related controllers into fewer, larger controllers with multiple methods handling different concerns (rejected)
  Rejected because: Violates single responsibility principle and creates controllers that are difficult to test and maintain as they grow
  When valid: May be acceptable for very simple CRUD operations with minimal business logic

## Risks

- Developers may create inconsistent controller organization if the pattern is not well documented or enforced
  Mitigation: Implement automated checks in CI pipeline to verify controller placement and naming conventions, provide clear documentation and examples
  Owner: Engineering team
- Over-fragmentation of controllers could lead to excessive indirection and difficulty understanding request flows
  Mitigation: Establish guidelines for when to create new controllers vs. adding methods to existing ones, conduct regular architecture reviews
  Owner: Architecture team
- Tight coupling between controllers and domain structure makes it difficult to reorganize domains without breaking routes and references
  Mitigation: Use route naming and dependency injection to decouple route definitions from controller locations, maintain comprehensive test coverage
  Owner: Engineering team

## Implementation Notes

- Create a base controller class at app/Domains/Vault/ManageJournals/Web/Controllers/Controller.php to share common functionality
- Use Laravel's route grouping to organize routes by domain: Route::group(['namespace' => 'App\Domains\Vault\ManageJournals\Web\Controllers'], ...)
- Document the controller organization pattern in the project's architecture documentation with examples from the journal management domain
- Consider using PHP traits for cross-cutting concerns like authorization, validation, and response formatting to avoid duplication across controllers

## Continuation Context


Verify commands:
- find app/Domains/Vault/ManageJournals/Web/Controllers -name '*Controller.php' | wc -l
- grep -r 'namespace App\\Domains\\Vault\\ManageJournals\\Web\\Controllers' app/Domains/Vault/ManageJournals/Web/Controllers/*.php | wc -l
- php artisan route:list --path=journal --columns=Action | grep 'App\\Domains\\Vault\\ManageJournals\\Web\\Controllers'

Accept when:
- All controller files in the ManageJournals domain are located under app/Domains/Vault/ManageJournals/Web/Controllers
- Each controller has a single, clear responsibility corresponding to an entity or entity-concern combination
- Controller namespaces match their directory structure and follow the established pattern
- Route definitions correctly reference controllers using the domain-based namespace

## Enforcement

- Verified by: Automated CI checks using grep and find commands to verify controller placement
- Verified by: Code review checklist requiring verification of controller organization for new features
- Verified by: PHPStan or Psalm static analysis rules to enforce namespace conventions
- Violation handling: CI pipeline fails if controllers are placed outside the designated domain structure
- Violation handling: Pull requests are blocked until controllers are moved to correct locations
- Violation handling: Architecture team is notified of repeated violations for coaching and documentation improvements
- Exception process: Developer creates an exception request documenting the rationale for non-standard placement
- Exception process: Architecture team reviews the request within 2 business days
- Exception process: If approved, exception is documented in ADR exceptions log with expiration date or migration plan
- Exception process: Exceptions are reviewed quarterly to determine if they can be resolved
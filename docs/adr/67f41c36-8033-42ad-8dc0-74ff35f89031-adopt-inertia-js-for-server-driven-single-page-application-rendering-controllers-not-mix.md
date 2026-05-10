# Adopt Inertia.js for Server-Driven Single Page Application Rendering: Controllers Not Mix

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all web controllers in the ManageJournals domain and SHOULD be applied to new controller implementations across the application.

## Context

- The application requires a modern user interface with single-page application (SPA) characteristics while maintaining server-side routing and controller logic
- Traditional server-side rendering with full page reloads creates poor user experience, while full client-side SPAs require complex API layers and state management
- The ManageJournals domain contains multiple controllers (JournalPhotoController, JournalController, JournalMetricController, SliceOfLifeController, PostController) that consistently implement a server-driven UI rendering pattern
- The pattern signature 15e2acffe1709747010fbe5a730776c8 appears across 5 controller files with 79.52% consistency, indicating a deliberate architectural choice
- The ui.rendering_model facet suggests a unified approach to how views are rendered and data is passed from controllers to the frontend

## Problem Statement

Web applications need to balance the rich interactivity of single-page applications with the simplicity of server-side routing and controller logic. Traditional approaches force a choice between full page reloads (poor UX) or complex client-side state management with REST/GraphQL APIs (high complexity). A hybrid approach is needed that provides SPA-like navigation while keeping business logic on the server.

## Decision

1. MUST_NOT: Controllers MUST NOT mix Inertia responses with traditional view() responses in the same domain context

## Policy Block

- MUST_NOT Controllers MUST NOT mix Inertia responses with traditional view() responses in the same domain context

In scope:
- All web controllers in the Vault/ManageJournals domain
- New controller implementations that serve user-facing web interfaces
- Controllers that handle both GET and POST requests for interactive features
- View rendering logic in journal, photo, metric, slice-of-life, and post management

Out of scope:
- API controllers that serve mobile applications or third-party integrations
- Webhook endpoints that return JSON responses
- Administrative or internal tools that use traditional server-side rendering
- Legacy controllers outside the ManageJournals domain (until migrated)

Exceptions:
- EXC-001: A controller endpoint needs to return raw JSON for AJAX requests from non-Inertia components
- EXC-002: File downloads or binary responses are required

## Rationale

- Pattern detection shows 79.52% confidence across 5 controller files, indicating this is an established and consistent architectural pattern in the codebase
- Inertia.js provides the benefits of SPA navigation (no full page reloads, preserved scroll position, client-side routing) while keeping all business logic in Laravel controllers
- This approach eliminates the need for a separate API layer, reducing code duplication and complexity in authentication, authorization, and validation
- The server-driven model ensures that routing, middleware, and authorization remain in familiar Laravel territory, reducing the learning curve for backend developers

## Consequences

Positive:
- Improved user experience with instant page transitions and SPA-like navigation without full page reloads
- Simplified architecture by eliminating the need for a separate REST or GraphQL API layer for the web frontend
- Reduced frontend complexity as state management is handled server-side through standard controller logic
- Better developer experience with type-safe props and clear data flow from controller to component
- Easier testing as business logic remains in testable PHP controllers rather than distributed across frontend and backend

Negative:
- Introduces a dependency on Inertia.js library which must be maintained and updated
- Requires frontend developers to understand the Inertia protocol and how props are passed from server to client
- May create challenges when migrating to a fully decoupled architecture in the future
- Initial page load includes the Inertia JavaScript bundle, slightly increasing bundle size compared to traditional server rendering

## Alternatives

- Traditional server-side rendering with Blade templates and full page reloads (rejected)
  Rejected because: Provides poor user experience with full page reloads, loss of scroll position, and visible loading states between pages
  When valid: For simple administrative interfaces where interactivity is not a priority
- Full client-side SPA with React/Vue and REST API backend (rejected)
  Rejected because: Requires building and maintaining a complete API layer, duplicating validation and authorization logic, and managing complex client-side state
  When valid: For applications that need mobile apps or third-party API access as primary use cases
- Livewire for reactive components with server-side rendering (rejected)
  Rejected because: While Livewire is excellent for reactive components, it uses a different paradigm (server-driven components) that may not provide the same SPA navigation experience
  When valid: For highly interactive forms and components that need real-time server validation without full page transitions

## Risks

- Inertia.js library becomes unmaintained or deprecated, requiring migration to another solution
  Mitigation: Monitor Inertia.js community health and GitHub activity. Maintain abstraction layer in controllers to ease potential migration. Consider contributing to the project to ensure longevity.
  Owner: Engineering team lead
- Performance degradation with large prop payloads sent on every request
  Mitigation: Use Inertia's lazy loading and partial reloads features. Monitor response sizes and implement caching strategies. Profile and optimize expensive data queries.
  Owner: Backend development team
- Inconsistent implementation across controllers leading to maintenance issues
  Mitigation: Establish clear patterns and base controller classes. Implement automated verification commands. Conduct code reviews focused on Inertia usage patterns.
  Owner: Architecture review team

## Implementation Notes

- Create a base controller class that provides helper methods for common Inertia response patterns
- Use Laravel's resource classes to transform models into consistent prop structures
- Implement shared props (user data, flash messages, etc.) using Inertia middleware rather than repeating in each controller
- Document the component naming convention (e.g., 'Journals/Index' maps to resources/js/Pages/Journals/Index.vue)
- Use TypeScript interfaces to define prop shapes for better type safety between backend and frontend

## Continuation Context


Verify commands:
- grep -r "Inertia::render" app/Domains/Vault/ManageJournals/Web/Controllers/ | wc -l
- grep -r "return view(" app/Domains/Vault/ManageJournals/Web/Controllers/ | wc -l
- php artisan route:list --path=journals --json | jq '[.[] | select(.action | contains("Controller"))] | length'

Accept when:
- All controllers in ManageJournals domain use Inertia::render() for view responses (verify command 1 shows expected count)
- No traditional view() calls exist in ManageJournals controllers (verify command 2 returns 0)
- All journal-related routes are handled by controllers using Inertia responses
- Code review confirms props are properly structured and lazy loading is used for expensive data

## Enforcement

- Verified by: Automated CI pipeline checks using grep patterns to detect non-Inertia responses in ManageJournals controllers
- Verified by: Code review checklist includes verification of Inertia usage patterns
- Verified by: PHPStan custom rules to detect view() calls in controllers within policy scope
- Verified by: Integration tests verify that responses include Inertia headers and proper component names
- Violation handling: CI pipeline fails if traditional view() calls are detected in ManageJournals controllers
- Violation handling: Pull requests are blocked until Inertia patterns are correctly implemented
- Violation handling: Violations in existing code trigger technical debt tickets for refactoring
- Violation handling: Architecture review team provides guidance on proper Inertia implementation patterns
- Exception process: Developer documents the exception reason in controller comments with reference to EXC-001 or EXC-002
- Exception process: Tech lead reviews and approves exception requests via pull request comments
- Exception process: Approved exceptions are logged in architecture decision log with justification
- Exception process: Exceptions are reviewed quarterly to determine if they can be eliminated through refactoring
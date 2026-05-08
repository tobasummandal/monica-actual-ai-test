# Adopt Inertia.js with SSR for Frontend-Backend Integration: Applications Implement Custom

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ALWAYS ACTIVE for all frontend-backend integration patterns in the application.

## Context

- The application requires seamless integration between Laravel backend and modern JavaScript frontend frameworks without building a full REST or GraphQL API
- Server-side rendering (SSR) capabilities are needed to improve initial page load performance and SEO while maintaining SPA-like user experience
- Custom middleware patterns have emerged to handle stateful DAV requests and signup flow control, indicating complex request lifecycle management requirements
- The codebase shows evidence of dual entry points (app.js and ssr.js) suggesting a hybrid client-side and server-side rendering architecture
- Pattern detected across 4 files with 85% confidence, indicating consistent adoption of Inertia.js middleware and rendering patterns

## Problem Statement

Traditional SPA architectures require building and maintaining separate API layers, handling CORS, managing authentication tokens, and implementing complex state synchronization between frontend and backend. This increases development complexity, maintenance burden, and potential security vulnerabilities. The application needs a solution that provides SPA-like user experience while leveraging Laravel's existing session-based authentication and routing without the overhead of a separate API layer.

## Decision

1. MAY: Applications MAY implement custom stateful request handling (e.g., EnsureDavRequestsAreStateful) to support specialized protocols while maintaining Inertia compatibility

## Policy Block

- MAY Applications MAY implement custom stateful request handling (e.g., EnsureDavRequestsAreStateful) to support specialized protocols while maintaining Inertia compatibility

In scope:
- All Laravel controller responses intended for frontend consumption
- All JavaScript-based page components and views
- Custom middleware that affects Inertia request/response lifecycle
- Server-side rendering configuration and entry points
- Frontend routing and navigation patterns

Out of scope:
- Pure API endpoints intended for mobile apps or third-party integrations
- Webhook handlers and background job processing
- Administrative CLI commands and artisan console operations
- Static asset serving and file downloads
- WebSocket or real-time communication channels

Exceptions:
- EXC-001: Legacy API endpoints that predate Inertia adoption and are still actively used by external clients
- EXC-002: Specialized protocols (WebDAV, CalDAV) that require custom request/response handling incompatible with Inertia's JSON response format

## Rationale

- Pattern detected with 85% confidence across 4 files including both entry points (app.js, ssr.js) and custom middleware implementations, indicating mature and consistent adoption
- Inertia.js eliminates the need for a separate API layer while providing modern SPA experience, reducing architectural complexity and maintenance overhead
- SSR support addresses performance and SEO requirements without sacrificing the benefits of client-side rendering for subsequent navigation
- Custom middleware patterns (EnsureDavRequestsAreStateful, EnsureSignupIsEnabled) demonstrate the framework's extensibility for application-specific requirements while maintaining architectural consistency

## Consequences

Positive:
- Reduced development complexity by eliminating the need to build and maintain separate REST or GraphQL API layers
- Improved developer experience with seamless data flow from Laravel controllers to JavaScript components without manual serialization
- Better performance through SSR for initial page loads while maintaining SPA-like navigation for subsequent interactions
- Simplified authentication and authorization by leveraging Laravel's existing session-based mechanisms without token management
- Consistent middleware patterns enable feature-gating and request lifecycle customization without breaking frontend integration

Negative:
- Increased coupling between frontend and backend, making it harder to completely decouple or replace either layer independently
- SSR infrastructure requires additional server resources and Node.js runtime alongside PHP, increasing deployment complexity
- Learning curve for developers unfamiliar with Inertia.js paradigm, which differs from traditional API-based architectures
- Limited flexibility for mobile app development or third-party integrations that require pure API access
- Potential performance bottlenecks if SSR is not properly optimized or cached, as each request may trigger full component rendering

## Alternatives

- Traditional REST API with separate frontend SPA using Vue Router or React Router (rejected)
  Rejected because: Requires building and maintaining separate API layer, handling CORS, managing authentication tokens, and implementing complex state synchronization. Increases development time and maintenance burden without providing significant architectural benefits for this application's requirements.
  When valid: When building mobile apps or enabling third-party integrations that require pure API access, or when frontend and backend teams are completely separate organizations
- Server-side rendering only with Laravel Blade templates and progressive enhancement (rejected)
  Rejected because: Lacks the smooth SPA-like user experience for navigation and interactions. Would require full page reloads and make it difficult to build modern, interactive UI components. Does not meet the application's UX requirements.
  When valid: For content-heavy websites with minimal interactivity, or when JavaScript should be optional for accessibility reasons
- GraphQL API with Apollo Client for frontend data management (rejected)
  Rejected because: Adds significant complexity with GraphQL schema definition, resolver implementation, and client-side cache management. Overkill for the application's data fetching patterns which are primarily page-based rather than requiring complex, nested data queries.
  When valid: When building complex applications with highly interconnected data models and multiple client types requiring flexible query capabilities

## Risks

- SSR server failures could cause complete application unavailability if not properly handled with fallback mechanisms
  Mitigation: Implement health checks for SSR server, configure automatic restarts, and consider client-side-only fallback mode for degraded operation. Monitor SSR performance and error rates.
  Owner: DevOps and Engineering Team
- Custom middleware modifications could break Inertia's request/response cycle, causing subtle bugs in SPA navigation or data flow
  Mitigation: Establish middleware testing standards, document middleware execution order, and implement integration tests that verify Inertia responses are properly formatted. Code review required for all middleware changes.
  Owner: Engineering Team
- Tight coupling between frontend and backend could make future architectural changes (e.g., microservices migration) more difficult and costly
  Mitigation: Document clear boundaries between presentation logic and business logic. Consider implementing a service layer that could be extracted to APIs if needed. Regularly review architectural decisions and maintain flexibility in critical business logic.
  Owner: Architecture Team

## Implementation Notes

- Ensure all new Laravel controllers return Inertia responses using Inertia::render() instead of traditional view() or JSON responses for frontend-facing routes
- Configure SSR server with appropriate memory limits and process management (PM2 or similar) to handle rendering load and automatic recovery from crashes
- When creating custom middleware that affects Inertia requests, extend the HandleInertiaRequests base class or carefully test integration with Inertia's middleware stack
- Organize JavaScript components in resources/js/Pages/ directory following Inertia conventions, with each component corresponding to a controller action
- Use Inertia's shared data mechanism for global props (user, flash messages, etc.) rather than passing them individually to each page component

## Continuation Context


Verify commands:
- grep -r "Inertia::render" app/Http/Controllers/ | wc -l
- test -f resources/js/app.js && test -f resources/js/ssr.js && echo 'Entry points exist'
- find app/Http/Middleware -name 'Ensure*.php' -type f | xargs grep -l 'Middleware'
- grep -r "@inertiajs" package.json

Accept when:
- All frontend-facing controller actions use Inertia::render() for responses, verified by grep showing multiple occurrences in controllers
- Both app.js and ssr.js entry points exist in resources/js/ directory
- Custom middleware files following Ensure[Feature][Condition].php naming pattern exist in app/Http/Middleware/
- Package.json contains @inertiajs dependencies indicating proper installation

## Enforcement

- Verified by: Automated CI checks scanning for Inertia::render() usage in new controller methods
- Verified by: Code review checklist requiring verification of Inertia response format for frontend routes
- Verified by: Integration tests validating Inertia response structure and SSR functionality
- Verified by: Static analysis tools checking middleware registration and execution order
- Violation handling: CI pipeline fails if new frontend-facing controllers do not use Inertia responses
- Violation handling: Pull requests blocked until code review confirms compliance with Inertia patterns
- Violation handling: Runtime monitoring alerts on non-Inertia responses for routes expected to use Inertia
- Violation handling: Quarterly architecture reviews identify and remediate non-compliant patterns
- Exception process: Developer submits exception request documenting the specific use case and why Inertia is not suitable
- Exception process: Technical lead reviews request and validates that the use case falls under documented policy exceptions (API endpoints, webhooks, etc.)
- Exception process: If approved, exception is documented in ADR addendum with justification and any required compensating controls
- Exception process: Exception is time-bound with review date if it represents technical debt rather than permanent architectural decision
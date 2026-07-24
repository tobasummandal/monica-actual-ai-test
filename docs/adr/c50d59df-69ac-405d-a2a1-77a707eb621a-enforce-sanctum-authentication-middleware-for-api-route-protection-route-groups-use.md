# Enforce Sanctum Authentication Middleware for API Route Protection: Route Groups Use

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all API route definitions in Laravel applications using Sanctum authentication. It governs how authentication middleware is applied to API endpoints.

## Context

- The application uses Laravel's Sanctum package for API authentication, requiring explicit middleware declarations to protect API endpoints from unauthorized access
- API routes are defined in routes/api.php using Laravel's Route facade, with authentication boundaries established through middleware groups
- The codebase separates API controllers into domain-specific namespaces (App\Domains\Settings\ManageUsers\Api\Controllers, App\Domains\Vault\ManageVault\Api\Controllers), requiring consistent authentication enforcement across domain boundaries
- The ApiController base class implements request validation middleware that enforces pagination limits and handles common exceptions (ModelNotFoundException, QueryException, ValidationException)
- Web routes in routes/web.php demonstrate multiple middleware patterns including throttling (throttle:oauth2-socialite), session authentication (auth:sanctum), and authorization policies (can:vault-viewer,vault)

## Problem Statement

API endpoints exposed without authentication middleware create security vulnerabilities where unauthorized clients can access protected resources. The application requires a consistent pattern for applying Sanctum authentication middleware to API routes while maintaining flexibility for public endpoints and supporting additional authorization layers through Laravel policies.

## Decision

1. SHOULD: API route groups SHOULD use named routes with the 'api.' prefix to distinguish API endpoints from web routes

## Policy Block

- SHOULD API route groups SHOULD use named routes with the 'api.' prefix to distinguish API endpoints from web routes

In scope:
- All routes defined in routes/api.php serving protected user or vault data
- API controllers in App\Domains\*\Api\Controllers namespaces
- RESTful resource routes created with Route::apiResource()
- Custom API endpoints returning authenticated user data or domain resources

Out of scope:
- Web routes defined in routes/web.php using session-based authentication
- Webhook endpoints designed for external service callbacks (e.g., Telegram webhooks)
- Public API endpoints explicitly designed for unauthenticated access (e.g., health checks, public documentation)
- OAuth callback routes that handle authentication flow establishment

Exceptions:
- EXC-001: Public API endpoints that serve non-sensitive data or handle authentication establishment (OAuth callbacks, login endpoints)

## Rationale

- The evidence shows consistent use of Route::middleware('auth:sanctum') in routes/api.php protecting user and vault resources, establishing this as the standard authentication boundary pattern
- The ApiController base class centralizes middleware logic for pagination validation and exception handling, reducing code duplication across 3+ API controller implementations
- Domain-driven controller organization (App\Domains\Settings\ManageUsers\Api\Controllers, App\Domains\Vault\ManageVault\Api\Controllers) demonstrates architectural intent to maintain clear service boundaries with consistent authentication enforcement
- The pattern supports layered authorization through Laravel policies (can:vault-viewer, can:contact-owner) applied after authentication, enabling fine-grained access control while maintaining authentication as the primary boundary

## Consequences

Positive:
- Centralized authentication enforcement through middleware groups prevents accidental exposure of protected API endpoints
- Base ApiController reduces boilerplate by providing common exception handling and pagination validation across all API controllers
- Token-based authentication via Sanctum enables stateless API access suitable for SPA and mobile clients
- Named route groups ('api.') provide clear namespace separation between API and web endpoints, improving route organization and testing

Negative:
- Middleware-based authentication adds latency to every API request through token validation and database lookups
- Developers must remember to wrap new API routes in the auth:sanctum middleware group or risk exposing unprotected endpoints
- The base ApiController couples all API controllers to specific exception handling behavior, reducing flexibility for controllers with unique error handling needs
- Pagination limit enforcement in middleware creates implicit coupling between request validation and configuration (api.max_limit_per_page)

## Alternatives

- Apply authentication globally to all /api/* routes through route service provider configuration instead of explicit middleware groups (rejected)
  Rejected because: Global authentication prevents intentional public API endpoints and reduces flexibility for OAuth callbacks and webhook endpoints that require different authentication mechanisms
  When valid: Valid for applications with no public API endpoints and uniform authentication requirements across all API routes
- Use session-based authentication (web middleware) for API routes instead of token-based Sanctum authentication (rejected)
  Rejected because: Session-based authentication requires CSRF protection and cookie management, making it unsuitable for stateless API clients, mobile applications, and third-party integrations
  When valid: Valid for API endpoints consumed exclusively by first-party web applications using the same session store
- Implement authentication checks directly in controller constructors or methods instead of using middleware (rejected)
  Rejected because: Controller-level authentication scatters security logic across multiple files, increases code duplication, and makes it difficult to audit authentication coverage across the application
  When valid: Valid for legacy applications or frameworks without middleware support, though not recommended for Laravel applications

## Risks

- Developers may forget to apply auth:sanctum middleware to new API routes, creating security vulnerabilities where protected resources are accessible without authentication
  Mitigation: Implement automated testing that verifies all routes in routes/api.php (except explicitly documented public endpoints) return 401 Unauthorized when accessed without valid tokens. Add pre-commit hooks or CI checks that scan for Route definitions outside middleware groups.
  Owner: Security team and API development team
- The base ApiController exception handling may mask important errors or create inconsistent API responses if exceptions are not properly categorized
  Mitigation: Maintain comprehensive exception handling tests for ApiController. Document expected error codes and HTTP status codes. Implement logging for all caught exceptions to ensure visibility into error patterns.
  Owner: API development team
- Sanctum token validation adds database queries to every API request, potentially creating performance bottlenecks under high load
  Mitigation: Implement token caching strategies using Redis or Memcached. Monitor API response times and database query counts. Consider rate limiting to prevent abuse. Profile authentication middleware performance under load testing.
  Owner: Infrastructure team and API development team

## Implementation Notes

- When creating new API routes, always define them within Route::middleware('auth:sanctum')->group() blocks in routes/api.php unless the endpoint is explicitly designed for public access
- New API controllers should extend App\Http\Controllers\ApiController to inherit pagination validation and exception handling. Override callAction() only when custom exception handling is required.
- Use Route::apiResource() for RESTful endpoints to automatically generate standard CRUD routes with consistent naming. Apply ->only() or ->except() to limit exposed methods.
- For endpoints requiring authorization beyond authentication, chain Laravel policy middleware after auth:sanctum using ->middleware('can:policy-name,parameter')
- Configure api.max_limit_per_page in config/api.php to set application-wide pagination limits. The ApiController will automatically enforce this limit and return error code 30 for violations.
- Document public API endpoints with comments explaining why they are excluded from authentication and what security measures are in place

## Continuation Context


Verify commands:
- grep -r "Route::middleware('auth:sanctum')" routes/api.php
- grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php
- php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'
- grep -r "max_limit_per_page" config/api.php

Accept when:
- All API routes in routes/api.php serving protected resources are wrapped in Route::middleware('auth:sanctum') groups
- All API controllers in App\Domains\*\Api\Controllers extend ApiController and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file config/api.php defines max_limit_per_page and ApiController enforces this limit in middleware

## Enforcement

- Verified by: Automated tests verify that protected API endpoints return 401 Unauthorized without valid Sanctum tokens
- Verified by: CI pipeline runs php artisan route:list and validates that all /api/* routes (except documented exceptions) include auth:sanctum middleware
- Verified by: Code review checklist requires verification that new API controllers extend ApiController and new routes are within authenticated middleware groups
- Verified by: Static analysis tools scan for Route definitions in routes/api.php outside middleware groups
- Violation handling: CI pipeline fails if unprotected API routes are detected without explicit @public documentation
- Violation handling: Security team is notified of any API endpoints merged without authentication middleware
- Violation handling: Quarterly security audits review all API routes and verify authentication coverage
- Violation handling: Penetration testing includes attempts to access API endpoints without authentication tokens
- Exception process: Developer documents the public endpoint requirement with @public annotation and security justification in route file comments
- Exception process: Security team reviews the exception request and validates that the endpoint does not expose sensitive data
- Exception process: Approved public endpoints are added to an allowlist in CI configuration to prevent false positives
- Exception process: Exception approvals are reviewed quarterly to ensure public endpoints remain appropriate
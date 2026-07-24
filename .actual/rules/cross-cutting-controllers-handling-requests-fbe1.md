# Enforce Sanctum Authentication Middleware for API Route Protection: Controllers Handling Requests

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, API controllers in domain-specific namespaces, and RESTful resource routes that serve protected user or vault data.

### Rules

- **R-SANCTUM-001** MUST: All API routes in `routes/api.php` serving protected resources be wrapped in `Route::middleware('auth:sanctum')` groups unless explicitly documented as public endpoints with security justification.
- **R-SANCTUM-002** MUST: All API controllers in `App\Domains\*\Api\Controllers` namespaces extend `ApiController` to inherit centralized exception handling and pagination validation.
- **R-SANCTUM-003** SHOULD: Controllers handling API requests be organized in domain-specific `Api\Controllers` namespaces to maintain clear service boundaries.
- **R-SANCTUM-004** SHOULD: RESTful endpoints use `Route::apiResource()` with `.only()` or `.except()` to limit exposed methods and maintain consistent naming.
- **R-SANCTUM-005** SHOULD: Endpoints requiring authorization beyond authentication chain Laravel policy middleware after `auth:sanctum` using `.middleware('can:policy-name,parameter')`.
- **R-SANCTUM-006** MUST: Public API endpoints be explicitly documented with `@public` annotation and security justification explaining why they are excluded from authentication.
- **R-SANCTUM-007** MUST: Configuration file `config/api.php` define `max_limit_per_page` and `ApiController` enforce this limit in middleware, returning error code 30 for violations.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify all API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API endpoints (should be empty or documented as public)
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php
```

**Accept when:**
- All API routes in `routes/api.php` serving protected resources are wrapped in `Route::middleware('auth:sanctum')` groups
- All API controllers in `App\Domains\*\Api\Controllers` extend `ApiController` and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file `config/api.php` defines `max_limit_per_page` and `ApiController` enforces this limit in middleware
- Protected API endpoints return 401 Unauthorized without valid Sanctum tokens (verified by automated tests)
- CI pipeline validates that all `/api/*` routes (except documented exceptions) include `auth:sanctum` middleware
- New API controllers extend `ApiController` and new routes are within authenticated middleware groups (verified by code review)

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules must be checked before accepting changes to API routes, controllers, or authentication configuration. Violations must be caught by CI pipeline and security team notification.
</enforcement>
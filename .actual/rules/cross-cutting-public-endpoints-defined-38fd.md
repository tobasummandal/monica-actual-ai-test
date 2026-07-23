# Enforce Sanctum Authentication Middleware for API Route Protection: Public Endpoints Defined

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, particularly routes defined in `routes/api.php`, API controllers in `App\Domains\*\Api\Controllers` namespaces, and RESTful resource routes created with `Route::apiResource()`.

### Rules

- **R-SANCTUM-001** MUST: Wrap all API routes serving protected user or vault data in `Route::middleware('auth:sanctum')` groups in `routes/api.php`.
- **R-SANCTUM-002** MUST: Ensure all API controllers in `App\Domains\*\Api\Controllers` extend `ApiController` to inherit centralized exception handling and pagination validation.
- **R-SANCTUM-003** MUST: Use `Route::apiResource()` for RESTful endpoints to automatically generate standard CRUD routes with consistent naming and apply `.only()` or `.except()` to limit exposed methods.
- **R-SANCTUM-004** MUST: Chain Laravel policy middleware after `auth:sanctum` using `->middleware('can:policy-name,parameter')` for endpoints requiring authorization beyond authentication.
- **R-SANCTUM-005** MUST: Configure `api.max_limit_per_page` in `config/api.php` and ensure `ApiController` automatically enforces this limit, returning error code 30 for violations.
- **R-SANCTUM-006** MAY: Define public API endpoints outside the `auth:sanctum` middleware group when explicitly designed for unauthenticated access (e.g., health checks, OAuth callbacks, login endpoints).
- **R-SANCTUM-007** MUST: Document all public API endpoints with comments explaining why they are excluded from authentication and what security measures are in place.
- **R-SANCTUM-008** MUST: Override `callAction()` in API controllers only when custom exception handling is required; otherwise rely on `ApiController` base implementation.

### Verify

```bash
# Verify all protected API routes use auth:sanctum middleware
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify all API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API endpoints (should be empty or documented as public)
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php

# Verify no Route definitions exist outside middleware groups in routes/api.php
grep -E "^\s*Route::(get|post|put|patch|delete|apiResource)" routes/api.php | grep -v "middleware"
```

**Accept when:**
- All API routes in `routes/api.php` serving protected resources are wrapped in `Route::middleware('auth:sanctum')` groups
- All API controllers in `App\Domains\*\Api\Controllers` extend `ApiController` and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file `config/api.php` defines `max_limit_per_page` and `ApiController` enforces this limit in middleware
- Protected API endpoints return 401 Unauthorized without valid Sanctum tokens
- CI pipeline validates that all `/api/*` routes (except documented exceptions) include `auth:sanctum` middleware
- New API controllers extend `ApiController` and new routes are within authenticated middleware groups
- Public endpoints are annotated with `@public` documentation and security justification

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules in this file are mandatory for API route protection. Violations must be caught during code review and CI pipeline checks before merge.
</enforcement>
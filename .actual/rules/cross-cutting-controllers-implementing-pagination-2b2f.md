# Enforce Sanctum Authentication Middleware for API Route Protection: Controllers Implementing Pagination

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, API controllers in domain-specific namespaces, and RESTful resource routes that serve protected user or vault data.

### Rules

- **R-SANCTUM-001** MUST: API controllers implementing pagination MUST respect the max_limit_per_page configuration value and return HTTP 400 with error code 30 when exceeded.
- **R-SANCTUM-002** MUST: All API routes in routes/api.php serving protected resources MUST be wrapped in Route::middleware('auth:sanctum') groups.
- **R-SANCTUM-003** MUST: All API controllers in App\Domains\*\Api\Controllers MUST extend ApiController to inherit centralized exception handling and pagination validation.
- **R-SANCTUM-004** MUST: New API routes MUST be defined within Route::middleware('auth:sanctum')->group() blocks unless explicitly designed for public access with documented security justification.
- **R-SANCTUM-005** SHOULD: Use Route::apiResource() for RESTful endpoints to automatically generate standard CRUD routes with consistent naming and apply ->only() or ->except() to limit exposed methods.
- **R-SANCTUM-006** SHOULD: For endpoints requiring authorization beyond authentication, chain Laravel policy middleware after auth:sanctum using ->middleware('can:policy-name,parameter').
- **R-SANCTUM-007** MAY: Public API endpoints explicitly designed for unauthenticated access (OAuth callbacks, login endpoints, health checks) may be excluded from auth:sanctum middleware with @public documentation and security justification.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API routes (should be empty or only documented public endpoints)
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify max_limit_per_page configuration exists
grep -r "max_limit_per_page" config/api.php

# Verify no Route definitions exist outside middleware groups in routes/api.php
grep -E "^\s*Route::" routes/api.php | grep -v "middleware" | grep -v "^\s*//"
```

**Accept when:**
- All API routes in routes/api.php serving protected resources are wrapped in Route::middleware('auth:sanctum') groups
- All API controllers in App\Domains\*\Api\Controllers extend ApiController and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file config/api.php defines max_limit_per_page and ApiController enforces this limit in middleware
- Automated tests verify that protected API endpoints return 401 Unauthorized without valid Sanctum tokens
- CI pipeline validates that all /api/* routes (except documented exceptions) include auth:sanctum middleware
- Code review checklist confirms new API controllers extend ApiController and new routes are within authenticated middleware groups

<enforcement>
Claude Code MUST NOT skip or defer verification. All API routes must be verified to include auth:sanctum middleware before accepting changes. Pagination limit enforcement must be confirmed in ApiController implementation.
</enforcement>
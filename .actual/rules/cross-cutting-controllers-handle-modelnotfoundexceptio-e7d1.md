# Enforce Sanctum Authentication Middleware for API Route Protection: Controllers Handle Modelnotfoundexception

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, API controllers in domain-specific namespaces, and RESTful resource routes serving protected user or vault data.

### Rules

- **R-SANCTUM-001** MUST: API controllers MUST handle ModelNotFoundException, QueryException, and ValidationException through centralized exception handling in the base controller.
- **R-SANCTUM-002** MUST: All API routes in routes/api.php serving protected resources MUST be wrapped in Route::middleware('auth:sanctum') groups.
- **R-SANCTUM-003** MUST: All API controllers in App\Domains\*\Api\Controllers MUST extend ApiController to inherit centralized exception handling.
- **R-SANCTUM-004** MUST: New API routes MUST be defined within Route::middleware('auth:sanctum')->group() blocks unless explicitly designed for public access.
- **R-SANCTUM-005** SHOULD: Use Route::apiResource() for RESTful endpoints to automatically generate standard CRUD routes with consistent naming.
- **R-SANCTUM-006** SHOULD: For endpoints requiring authorization beyond authentication, chain Laravel policy middleware after auth:sanctum using ->middleware('can:policy-name,parameter').
- **R-SANCTUM-007** MUST: Public API endpoints MUST be explicitly documented with @public annotation and security justification in route file comments.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify all API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API routes (should be empty or only documented public endpoints)
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php

# Verify no Route definitions exist outside middleware groups in api.php
grep -E "Route::(get|post|put|patch|delete|apiResource)\(" routes/api.php | grep -v "middleware"
```

**Accept when:**
- All API routes in routes/api.php serving protected resources are wrapped in Route::middleware('auth:sanctum') groups
- All API controllers in App\Domains\*\Api\Controllers extend ApiController and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file config/api.php defines max_limit_per_page and ApiController enforces this limit in middleware
- All public API endpoints are annotated with @public comments explaining why they are excluded from authentication
- Automated tests verify that protected API endpoints return 401 Unauthorized without valid Sanctum tokens
- CI pipeline validates that all /api/* routes (except documented exceptions) include auth:sanctum middleware

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules in this file are mandatory for API route protection and exception handling compliance.
</enforcement>
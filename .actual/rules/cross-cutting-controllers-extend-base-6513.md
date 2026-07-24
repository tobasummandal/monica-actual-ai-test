# Enforce Sanctum Authentication Middleware for API Route Protection: Controllers Extend Base

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, API controllers in domain-specific namespaces, and RESTful resource routes that serve protected user or vault data.

### Rules

- **R-SANCTUM-001** MUST: API controllers MUST extend a base ApiController that implements common middleware for request validation, pagination limits, and exception handling.
- **R-SANCTUM-002** MUST: All API routes in routes/api.php serving protected resources MUST be wrapped in Route::middleware('auth:sanctum') groups.
- **R-SANCTUM-003** MUST: New API controllers in App\Domains\*\Api\Controllers namespaces MUST extend ApiController to inherit centralized exception handling.
- **R-SANCTUM-004** SHOULD: Use Route::apiResource() for RESTful endpoints to automatically generate standard CRUD routes with consistent naming and apply ->only() or ->except() to limit exposed methods.
- **R-SANCTUM-005** SHOULD: For endpoints requiring authorization beyond authentication, chain Laravel policy middleware after auth:sanctum using ->middleware('can:policy-name,parameter').
- **R-SANCTUM-006** SHOULD: Configure api.max_limit_per_page in config/api.php to set application-wide pagination limits and ensure ApiController enforces this limit.
- **R-SANCTUM-007** SHOULD: Document public API endpoints with comments explaining why they are excluded from authentication and what security measures are in place.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify all API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# Identify any unprotected API routes
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php
```

**Accept when:**
- All API routes in routes/api.php serving protected resources are wrapped in Route::middleware('auth:sanctum') groups
- All API controllers in App\Domains\*\Api\Controllers extend ApiController and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file config/api.php defines max_limit_per_page and ApiController enforces this limit in middleware
- Protected API endpoints return 401 Unauthorized without valid Sanctum tokens (verified by automated tests)
- CI pipeline validates that all /api/* routes (except documented exceptions) include auth:sanctum middleware

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules in this file are mandatory for API route protection and must be verified before accepting code changes.
</enforcement>
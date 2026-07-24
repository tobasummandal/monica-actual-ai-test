# Enforce Sanctum Authentication Middleware for API Route Protection: Routes Serving Protected

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, particularly routes defined in `routes/api.php` and API controllers in `App\Domains\*\Api\Controllers` namespaces.

### Rules

- **R-SANCTUM-001** MUST: All API routes serving protected resources MUST be wrapped in `Route::middleware('auth:sanctum')` to enforce token-based authentication.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected API routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify all API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API routes (should be empty or only documented public endpoints)
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php
```

**Accept when:**
- All API routes in `routes/api.php` serving protected resources are wrapped in `Route::middleware('auth:sanctum')` groups
- All API controllers in `App\Domains\*\Api\Controllers` extend `ApiController` and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file `config/api.php` defines `max_limit_per_page` and `ApiController` enforces this limit in middleware
- Automated tests verify that protected API endpoints return 401 Unauthorized without valid Sanctum tokens
- CI pipeline validates that all `/api/*` routes (except documented exceptions) include `auth:sanctum` middleware

<enforcement>
Claude Code MUST NOT skip or defer verification of R-SANCTUM-001. All API routes must be audited for authentication middleware presence before accepting changes to `routes/api.php` or API controller definitions.
</enforcement>
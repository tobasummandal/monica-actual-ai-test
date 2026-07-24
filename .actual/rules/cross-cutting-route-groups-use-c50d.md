# Enforce Sanctum Authentication Middleware for API Route Protection: Route Groups Use

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, specifically routes defined in `routes/api.php` and API controllers in `App\Domains\*\Api\Controllers` namespaces.

### Rules

- **R-SANCTUM-001** SHOULD: API route groups SHOULD use named routes with the 'api.' prefix to distinguish API endpoints from web routes.
- **R-SANCTUM-002** MUST: All API routes in routes/api.php serving protected resources MUST be wrapped in `Route::middleware('auth:sanctum')` groups unless explicitly documented as public endpoints.
- **R-SANCTUM-003** SHOULD: New API controllers SHOULD extend `App\Http\Controllers\ApiController` to inherit centralized pagination validation and exception handling.
- **R-SANCTUM-004** SHOULD: RESTful endpoints SHOULD use `Route::apiResource()` for automatic generation of standard CRUD routes with consistent naming.
- **R-SANCTUM-005** SHOULD: Endpoints requiring authorization beyond authentication SHOULD chain Laravel policy middleware after auth:sanctum using `->middleware('can:policy-name,parameter')`.
- **R-SANCTUM-006** MUST: Public API endpoints MUST be explicitly documented with comments explaining why they are excluded from authentication and what security measures are in place.
- **R-SANCTUM-007** SHOULD: Application-wide pagination limits SHOULD be configured in `config/api.php` as `api.max_limit_per_page` and enforced by ApiController.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify API controllers extend ApiController
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API endpoints
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php
```

**Accept when:**
- All API routes in routes/api.php serving protected resources are wrapped in `Route::middleware('auth:sanctum')` groups
- All API controllers in `App\Domains\*\Api\Controllers` extend `ApiController` and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file `config/api.php` defines `max_limit_per_page` and `ApiController` enforces this limit in middleware
- Protected API endpoints return 401 Unauthorized without valid Sanctum tokens
- CI pipeline validates that all `/api/*` routes (except documented exceptions) include `auth:sanctum` middleware

<enforcement>
Claude Code MUST NOT skip or defer verification. All rules MUST be checked before accepting changes to API route definitions or controllers. Violations MUST be flagged for security team review.
</enforcement>
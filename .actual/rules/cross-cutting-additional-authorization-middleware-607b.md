# Enforce Sanctum Authentication Middleware for API Route Protection: Additional Authorization Middleware

These rules are ALWAYS ACTIVE for all API route definitions in Laravel applications using Sanctum authentication, API controllers in domain-specific namespaces, and RESTful resource routes that serve protected user or vault data.

### Rules

- **R-AUTH-001** SHOULD: Additional authorization middleware using Laravel policies (can:policy-name) SHOULD be applied after authentication middleware for fine-grained access control.

### Verify

```bash
# Verify auth:sanctum middleware is applied to protected API routes
grep -r "Route::middleware('auth:sanctum')" routes/api.php

# Verify API controllers extend ApiController base class
grep -r "extends ApiController" app/Domains/*/Api/Controllers/*.php

# List any unprotected API routes (should be empty or documented as public)
php artisan route:list --path=api --json | jq '.[] | select(.middleware | contains(["auth:sanctum"]) | not) | .uri'

# Verify pagination configuration exists
grep -r "max_limit_per_page" config/api.php
```

**Accept when:**
- All API routes in routes/api.php serving protected resources are wrapped in Route::middleware('auth:sanctum') groups
- All API controllers in App\Domains\*\Api\Controllers extend ApiController and inherit centralized exception handling
- Route listing shows no unprotected API endpoints except those explicitly documented as public with security justification
- Configuration file config/api.php defines max_limit_per_page and ApiController enforces this limit in middleware
- Additional authorization middleware using Laravel policies is chained after auth:sanctum for fine-grained access control

<enforcement>
Claude Code MUST NOT skip or defer verification. All API routes must be verified to include auth:sanctum middleware and policy-based authorization where applicable. CI pipeline MUST fail if unprotected API routes are detected without explicit @public documentation.
</enforcement>
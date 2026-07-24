# Adopt Action-Based Middleware Pattern for Authentication Flow Control: Authentication Actions Inject

These rules are ALWAYS ACTIVE for all authentication action classes in `app/Actions/` that implement OAuth-based social authentication, two-factor authentication, WebAuthn support, or stateful user token persistence flows.

### Rules

- **R-AUTH-001** MUST: Authentication actions MUST inject `StatefulGuard` and `LoginRateLimiter` dependencies via constructor to coordinate authentication state and rate limiting.
- **R-AUTH-002** MUST: Authentication actions MUST implement a `handle(Request $request, callable $next)` method signature to enable composition in middleware pipelines.
- **R-AUTH-003** MUST: User token persistence for OAuth providers MUST use the `UserToken` Eloquent model with `create()` or `firstWhere()` methods to maintain consistent data access patterns.
- **R-AUTH-004** MUST: Session-based authentication state management MUST use `$request->session()->put()` for storing authentication context across multi-step flows (e.g., credential validation → 2FA challenge → final login).
- **R-AUTH-005** SHOULD: Authentication action classes SHOULD extend a base action class or implement a shared interface to enforce consistent `handle()` method signatures and dependency injection patterns.
- **R-AUTH-006** SHOULD: Session key constants (e.g., `LOGIN_ID_KEY`, `LOGIN_REMEMBER_KEY`) SHOULD be extracted to a shared configuration class to prevent key collisions and enable centralized session state management.
- **R-AUTH-007** SHOULD: Authentication sub-concerns (credential validation, user authentication, token creation) SHOULD be implemented as separate private methods to improve testability and enable mocking of individual steps.
- **R-AUTH-008** SHOULD: All method parameters and return types in authentication actions SHOULD include explicit type hints, especially for nullable `User` returns, to leverage static analysis tools.

### Verify

```bash
# Count authentication action classes implementing handle(Request, callable) signature
grep -r "public function handle(Request \$request, callable \$next)" app/Actions/ | wc -l

# Count authentication actions injecting StatefulGuard via constructor
grep -r "protected StatefulGuard \$guard" app/Actions/ | wc -l

# Count UserToken model usage for OAuth provider persistence
grep -r "UserToken::create\|UserToken::firstWhere" app/Actions/ | wc -l

# Count session state management using $request->session()->put()
grep -r "\$request->session()->put" app/Actions/ | wc -l
```

**Accept when:**
- All authentication action classes in `app/Actions/` implement `handle(Request $request, callable $next)` method signature (verify command returns count ≥ 2)
- Authentication actions inject `StatefulGuard` via constructor (verify command returns count ≥ 2)
- `UserToken` model is used for OAuth provider persistence with `create()` or `firstWhere()` methods (verify command returns count ≥ 2)
- Session state management uses `$request->session()->put()` for storing authentication context (verify command returns count ≥ 2)

<enforcement>
Claude Code MUST NOT skip or defer verification. All four verify commands MUST return counts ≥ 2 before accepting authentication action implementations. Static analysis via PHPStan or Psalm with custom rules checking for `StatefulGuard` and `LoginRateLimiter` injection in authentication action constructors is mandatory. Integration tests validating complete authentication flows including OAuth provider callbacks, 2FA challenges, and session state management are required. Pull requests introducing authentication actions without proper `handle()` signature or dependency injection MUST be blocked until corrected.
</enforcement>
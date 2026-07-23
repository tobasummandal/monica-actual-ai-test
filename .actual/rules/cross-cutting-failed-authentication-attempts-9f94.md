# Adopt Action-Based Middleware Pattern for Authentication Flow Control: Failed Authentication Attempts

These rules are ALWAYS ACTIVE for all authentication action classes, middleware handlers, and authentication flow control logic in the application.

### Rules

- **R-AUTH-001** SHOULD: Failed authentication attempts SHOULD dispatch `Illuminate\Auth\Events\Failed` events and increment rate limiters before throwing `ValidationException`.
- **R-AUTH-002** MUST: Authentication action classes MUST implement the `handle(Request $request, callable $next)` method signature for middleware-style composition.
- **R-AUTH-003** MUST: Authentication actions MUST inject `StatefulGuard` and `LoginRateLimiter` via constructor to establish explicit dependencies for authentication state management.
- **R-AUTH-004** MUST: OAuth provider token persistence MUST use the `UserToken` Eloquent model with `create()` or `firstWhere()` methods for consistent data access.
- **R-AUTH-005** MUST: Multi-step authentication flows MUST use session state management via `$request->session()->put()` with reserved keys (e.g., `login.id`, `login.remember`) for storing authentication context.
- **R-AUTH-006** SHOULD: Authentication action classes SHOULD extend a base action class or implement a shared interface to enforce consistent `handle()` method signatures across all authentication flows.
- **R-AUTH-007** SHOULD: Session key constants (e.g., `LOGIN_ID_KEY`, `LOGIN_REMEMBER_KEY`) SHOULD be extracted to a shared configuration class to prevent key collisions.
- **R-AUTH-008** MUST: All method parameters and return types in authentication actions MUST include explicit type hints, especially for nullable `User` returns.

### Verify

```bash
# Verify authentication action classes implement handle() method signature
grep -r "public function handle(Request \$request, callable \$next)" app/Actions/ | wc -l

# Verify authentication actions inject StatefulGuard via constructor
grep -r "protected StatefulGuard \$guard" app/Actions/ | wc -l

# Verify UserToken model is used for OAuth provider persistence
grep -r "UserToken::create\|UserToken::firstWhere" app/Actions/ | wc -l

# Verify session state management uses $request->session()->put()
grep -r "\$request->session()->put" app/Actions/ | wc -l
```

**Accept when:**
- All authentication action classes in `app/Actions/` implement `handle(Request $request, callable $next)` method signature (verify command returns count >= 2)
- Authentication actions inject `StatefulGuard` via constructor (verify command returns count >= 2)
- `UserToken` model is used for OAuth provider persistence with `create()` or `firstWhere()` methods (verify command returns count >= 2)
- Session state management uses `$request->session()->put()` for storing authentication context (verify command returns count >= 2)
- Failed authentication attempts dispatch `Illuminate\Auth\Events\Failed` events before throwing `ValidationException`
- Rate limiters are incremented in authentication action handle methods

<enforcement>
Claude Code MUST NOT skip or defer verification. All authentication action classes MUST conform to the handle() signature and dependency injection patterns. Static analysis via PHPStan or Psalm with custom rules checking for StatefulGuard and LoginRateLimiter injection is mandatory. Integration tests validating complete authentication flows including OAuth callbacks, 2FA challenges, and session state management are required. Pull requests introducing authentication actions without proper handle() signature or dependency injection MUST be blocked until corrected.
</enforcement>
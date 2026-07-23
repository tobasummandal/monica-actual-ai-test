# Adopt Action-Based Middleware Pattern for Authentication Flow Control: Authentication Actions Return

These rules are ALWAYS ACTIVE for all authentication action classes in `app/Actions/` that implement OAuth-based social authentication, two-factor authentication, WebAuthn support, user token persistence, and stateful session management across multi-step authentication flows.

### Rules

- **R-AUTH-001** MUST: All authentication action classes implement `handle(Request $request, callable $next)` method signature to enable middleware-style composition and flow control.
- **R-AUTH-002** MUST: Authentication actions inject `StatefulGuard` via constructor to establish explicit dependencies for authentication state management.
- **R-AUTH-003** MUST: Authentication actions inject `LoginRateLimiter` via constructor to coordinate rate limiting with authentication flow control.
- **R-AUTH-004** MUST: UserToken model is used for OAuth provider persistence with `create()` or `firstWhere()` methods supporting both OAuth1 (token/tokenSecret) and OAuth2 (token/refreshToken/expiresIn) formats.
- **R-AUTH-005** MUST: Session state management uses `$request->session()->put()` for storing authentication context across multi-step flows using reserved session keys (login.id, login.remember).
- **R-AUTH-006** MAY: Authentication actions MAY return early responses (redirects, JSON) for 2FA challenges instead of calling `$next($request)` to short-circuit the middleware pipeline.
- **R-AUTH-007** SHOULD: Separate private methods for each authentication sub-concern (validateCredentials, authenticateUser, createUserToken) to improve testability and enable mocking of individual steps.
- **R-AUTH-008** SHOULD: Extract session key constants (LOGIN_ID_KEY, LOGIN_REMEMBER_KEY) to a shared configuration class to prevent key collisions and enable centralized session state management.
- **R-AUTH-009** SHOULD: Add explicit type hints for all method parameters and return types, especially for nullable User returns, to leverage static analysis tools.

### Verify

```bash
# Verify all authentication action classes implement handle(Request $request, callable $next) signature
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
- UserToken model is used for OAuth provider persistence with `create()` or `firstWhere()` methods (verify command returns count >= 2)
- Session state management uses `$request->session()->put()` for storing authentication context (verify command returns count >= 2)

<enforcement>
Claude Code MUST NOT skip or defer verification. All four verify commands must return counts >= 2 before accepting authentication action implementations. Static analysis via PHPStan or Psalm with custom rules checking for StatefulGuard and LoginRateLimiter injection is mandatory. Integration tests validating complete authentication flows including OAuth provider callbacks, 2FA challenges, and session state management are required. Pull requests introducing authentication actions without proper handle() signature or dependency injection must be blocked until corrected.
</enforcement>
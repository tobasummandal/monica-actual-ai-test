# Adopt Action-Based Middleware Pattern for Authentication Flow Control: User Creation Via

These rules are ALWAYS ACTIVE for all authentication action classes, middleware handlers, and user creation flows that integrate OAuth providers, 2FA, WebAuthn, or stateful session management.

### Rules

- **R-AUTH-001** SHOULD: User creation via social providers SHOULD delegate to dedicated action classes (CreateNewUser) and dispatch Registered events using tap() for side effects.
- **R-AUTH-002** MUST: All authentication action classes MUST implement handle(Request $request, callable $next) method signature for middleware-style composition.
- **R-AUTH-003** MUST: Authentication actions MUST inject StatefulGuard and LoginRateLimiter via constructor to establish explicit dependencies for authentication state management.
- **R-AUTH-004** MUST: UserToken model MUST be used for OAuth provider persistence with create() or firstWhere() methods supporting both OAuth1 and OAuth2 token formats.
- **R-AUTH-005** MUST: Session-based authentication state MUST use $request->session()->put() for storing login context (login.id, login.remember keys) across multi-step flows.
- **R-AUTH-006** SHOULD: Authentication action classes SHOULD extract session key constants (LOGIN_ID_KEY, LOGIN_REMEMBER_KEY) to a shared configuration class to prevent key collisions.
- **R-AUTH-007** SHOULD: Private methods SHOULD be implemented for each authentication sub-concern (validateCredentials, authenticateUser, createUserToken) to improve testability.
- **R-AUTH-008** MUST: All method parameters and return types MUST include explicit type hints, especially for nullable User returns, to leverage static analysis.

### Verify

```bash
# Verify authentication action classes implement handle() signature
grep -r "public function handle(Request \$request, callable \$next)" app/Actions/ | wc -l

# Verify StatefulGuard injection in authentication actions
grep -r "protected StatefulGuard \$guard" app/Actions/ | wc -l

# Verify UserToken model usage for OAuth persistence
grep -r "UserToken::create\|UserToken::firstWhere" app/Actions/ | wc -l

# Verify session state management with put() method
grep -r "\$request->session()->put" app/Actions/ | wc -l
```

**Accept when:**
- All authentication action classes in app/Actions/ implement handle(Request $request, callable $next) method signature (verify command returns count >= 2)
- Authentication actions inject StatefulGuard via constructor (verify command returns count >= 2)
- UserToken model is used for OAuth provider persistence with create or firstWhere methods (verify command returns count >= 2)
- Session state management uses $request->session()->put() for storing authentication context (verify command returns count >= 2)

<enforcement>
Clause Code MUST NOT skip or defer verification. All four verify commands MUST return counts >= 2 before accepting authentication action implementations. Static analysis via PHPStan or Psalm with custom rules checking for StatefulGuard and LoginRateLimiter injection is mandatory. Integration tests validating complete authentication flows including OAuth callbacks, 2FA challenges, and session state isolation are required. Pull requests introducing authentication actions without proper handle() signature or dependency injection MUST be blocked.
</enforcement>
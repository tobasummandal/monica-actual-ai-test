# Adopt Action-Based Middleware Pattern for Authentication Flow Control: User Token Persistence

These rules are ALWAYS ACTIVE for all authentication action classes, middleware, and user token persistence logic in the application.

### Rules

- **R-AUTH-001** MUST: User token persistence MUST use Eloquent model methods (create, firstWhere) to store and retrieve OAuth provider associations with driver, driver_id, and user_id fields.
- **R-AUTH-002** MUST: All authentication action classes MUST implement handle(Request $request, callable $next) method signature.
- **R-AUTH-003** MUST: Authentication actions MUST inject StatefulGuard via constructor for authentication state management.
- **R-AUTH-004** MUST: Authentication actions MUST inject LoginRateLimiter via constructor for rate-limited authentication attempts.
- **R-AUTH-005** MUST: Session-based authentication state management MUST use $request->session()->put() for storing authentication context across multi-step flows.
- **R-AUTH-006** SHOULD: Extract session key constants (LOGIN_ID_KEY, LOGIN_REMEMBER_KEY) to a shared configuration class to prevent key collisions.
- **R-AUTH-007** SHOULD: Implement separate private methods for each authentication sub-concern (validateCredentials, authenticateUser, createUserToken) to improve testability.
- **R-AUTH-008** SHOULD: Add explicit type hints for all method parameters and return types, especially for nullable User returns.
- **R-AUTH-009** SHOULD: Use Laravel's tap() helper when creating users or tokens to chain side effects while maintaining readable code.

### Verify

```bash
# Verify all authentication action classes implement handle(Request $request, callable $next)
grep -r "public function handle(Request \$request, callable \$next)" app/Actions/ | wc -l

# Verify authentication actions inject StatefulGuard via constructor
grep -r "protected StatefulGuard \$guard" app/Actions/ | wc -l

# Verify UserToken model is used for OAuth provider persistence
grep -r "UserToken::create\|UserToken::firstWhere" app/Actions/ | wc -l

# Verify session state management uses $request->session()->put()
grep -r "\$request->session()->put" app/Actions/ | wc -l
```

**Accept when:**
- All authentication action classes in app/Actions/ implement handle(Request $request, callable $next) method signature (verify command returns count >= 2)
- Authentication actions inject StatefulGuard via constructor (verify command returns count >= 2)
- UserToken model is used for OAuth provider persistence with create or firstWhere methods (verify command returns count >= 2)
- Session state management uses $request->session()->put() for storing authentication context (verify command returns count >= 2)

<enforcement>
Claude Code MUST NOT skip or defer verification. All four verify commands must return counts >= 2 before accepting authentication action implementations.
</enforcement>
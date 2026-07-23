# Adopt Action-Based Middleware Pattern for Authentication Flow Control: Session State 2fa

These rules are ALWAYS ACTIVE for all authentication action classes, middleware handlers, and session state management code within the authentication flow control system.

### Rules

- **R-AUTH-2FA-001** MUST: Session state for 2FA challenges MUST be stored using `$request->session()->put()` with `login.id` and `login.remember` keys before redirecting to challenge routes.

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
- `UserToken` model is used for OAuth provider persistence with `create` or `firstWhere` methods (verify command returns count >= 2)
- Session state management uses `$request->session()->put()` for storing authentication context (verify command returns count >= 2)

<enforcement>
Claude Code MUST NOT skip or defer verification. All four verify commands must return counts >= 2 before accepting authentication flow changes.
</enforcement>
# Use Laravel Hash Facade for Password Hashing and Verification: Password Values Not

These rules are ALWAYS ACTIVE for all Laravel Fortify authentication action classes, user model password attribute updates, password reset and password change workflows, and any custom authentication logic that handles user credentials.

### Rules

- **R-HASH-001** MUST_NOT: Password values MUST_NOT be stored in plaintext or using reversible encryption in the database.
- **R-HASH-002** MUST: Always use Hash::make($password) when assigning to the user password field, never assign plaintext values.
- **R-HASH-003** MUST: Use Hash::check($plaintext, $hash) for password verification in authentication flows, never use direct string comparison.
- **R-HASH-004** MUST: Leverage forceFill() when updating password fields to bypass mass assignment protection: $user->forceFill(['password' => Hash::make($input['password'])])->save().
- **R-HASH-005** SHOULD: Configure bcrypt work factor in config/hashing.php based on acceptable authentication latency (default is 10 rounds).

### Verify

```bash
# Verify Hash::make() usage for password storage
grep -r "Hash::make" app/Actions/Fortify/ | grep -c password

# Verify Hash::check() usage for password verification
grep -r "Hash::check" app/Actions/Fortify/ | grep -c password

# Detect plaintext password assignments without Hash::make()
grep -r "'password'\s*=>\s*\$" app/ | grep -v Hash::make || echo 'No plaintext password assignments found'
```

**Accept when:**
- All password storage operations in Fortify action classes use Hash::make()
- All password verification operations use Hash::check() with constant-time comparison
- No plaintext password assignments exist in authentication code paths
- Password field updates use forceFill() with Hash::make() wrapper

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis scanning for password field assignments without Hash::make() is mandatory. Code review checklist for authentication-related pull requests is mandatory. Automated grep-based verification in CI pipeline is mandatory. Violations require immediate remediation and security team review.
</enforcement>
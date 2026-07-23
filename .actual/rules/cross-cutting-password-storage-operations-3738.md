# Use Laravel Hash Facade for Password Hashing and Verification: Password Storage Operations

These rules are ALWAYS ACTIVE for all Laravel Fortify authentication action classes, user model password attribute updates, password reset and password change workflows, and any custom authentication logic that handles user credentials.

### Rules

- **R-HASH-001** MUST: All password storage operations MUST use Hash::make() to generate bcrypt hashes before persisting to the database.
- **R-HASH-002** MUST: All password verification operations MUST use Hash::check() for constant-time comparison, never use direct string comparison.
- **R-HASH-003** MUST: Never assign plaintext password values directly to the user password field.
- **R-HASH-004** SHOULD: Use forceFill() when updating password fields to bypass mass assignment protection: `$user->forceFill(['password' => Hash::make($input['password'])])->save()`
- **R-HASH-005** SHOULD: Configure bcrypt work factor in config/hashing.php based on acceptable authentication latency (default is 10 rounds).

### Verify

```bash
# Verify Hash::make() usage in password storage
grep -r "Hash::make" app/Actions/Fortify/ | grep -c password

# Verify Hash::check() usage in password verification
grep -r "Hash::check" app/Actions/Fortify/ | grep -c password

# Detect plaintext password assignments without Hash::make()
grep -r "'password'\s*=>\s*\$" app/ | grep -v Hash::make || echo 'No plaintext password assignments found'
```

**Accept when:**
- All password storage operations in Fortify action classes use Hash::make()
- All password verification operations use Hash::check() with constant-time comparison
- No plaintext password assignments exist in authentication code paths
- Password field updates use forceFill() or equivalent mass assignment bypass when appropriate

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis scanning for password field assignments without Hash::make() is mandatory. Code review checklist for authentication-related pull requests is mandatory. Automated grep-based verification in CI pipeline is mandatory. Violations require immediate remediation.
</enforcement>
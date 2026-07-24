# Use Laravel Hash Facade for Password Hashing and Verification: Password Update Operations

These rules are ALWAYS ACTIVE for all Laravel Fortify authentication action classes, user model password attribute updates, password reset and password change workflows, and any custom authentication logic that handles user credentials.

### Rules

- **R-HASH-001** MUST: Password update operations MUST validate the current password using Hash::check() before allowing password changes.
- **R-HASH-002** MUST: Always use Hash::make($password) when assigning to the user password field, never assign plaintext values.
- **R-HASH-003** MUST: Use Hash::check($plaintext, $hash) for password verification in authentication flows, never use direct string comparison.
- **R-HASH-004** MUST: No plaintext password assignments exist in authentication code paths.

### Verify

```bash
# Verify Hash::make usage in Fortify action classes
grep -r "Hash::make" app/Actions/Fortify/ | grep -c password

# Verify Hash::check usage in Fortify action classes
grep -r "Hash::check" app/Actions/Fortify/ | grep -c password

# Verify no plaintext password assignments exist
grep -r "'password'\s*=>\s*\$" app/ | grep -v Hash::make || echo 'No plaintext password assignments found'
```

**Accept when:**
- All password storage operations in Fortify action classes use Hash::make()
- All password verification operations use Hash::check() with constant-time comparison
- No plaintext password assignments exist in authentication code paths
- Password update operations validate current password before allowing changes

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis scanning for password field assignments without Hash::make() is mandatory. Code review checklist for authentication-related pull requests is mandatory. Automated grep-based verification in CI pipeline is mandatory. Violations require immediate remediation.
</enforcement>
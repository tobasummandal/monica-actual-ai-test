# Use Laravel Hash Facade for Password Hashing and Verification: Password Fields Assigned

These rules are ALWAYS ACTIVE for all Laravel Fortify authentication action classes and user model password attribute updates within authentication workflows.

### Rules

- **R-HASH-001** MUST: Password fields MUST be assigned using forceFill() to bypass mass assignment protection when updating hashed values.
- **R-HASH-002** MUST: Always use Hash::make($password) when assigning to the user password field, never assign plaintext values.
- **R-HASH-003** MUST: Use Hash::check($plaintext, $hash) for password verification in authentication flows, never use direct string comparison.
- **R-HASH-004** MUST: No plaintext password assignments exist in authentication code paths.

### Verify

```bash
# Verify Hash::make() usage in Fortify actions
grep -r "Hash::make" app/Actions/Fortify/ | grep -c password

# Verify Hash::check() usage in Fortify actions
grep -r "Hash::check" app/Actions/Fortify/ | grep -c password

# Verify no plaintext password assignments exist
grep -r "'password'\s*=>\s*\$" app/ | grep -v Hash::make || echo 'No plaintext password assignments found'

# Verify forceFill() usage for password updates
grep -r "forceFill" app/Actions/Fortify/ | grep password
```

**Accept when:**
- All password storage operations in Fortify action classes use Hash::make()
- All password verification operations use Hash::check() with constant-time comparison
- No plaintext password assignments exist in authentication code paths
- Password field updates use forceFill() to bypass mass assignment protection

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis scanning for password field assignments without Hash::make() is mandatory. Code review checklist for authentication-related pull requests is required. Automated grep-based verification in CI pipeline must pass. Violation handling requires CI pipeline failure and security team review.
</enforcement>
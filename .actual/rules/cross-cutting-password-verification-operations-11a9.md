# Use Laravel Hash Facade for Password Hashing and Verification: Password Verification Operations

These rules are ALWAYS ACTIVE for all Laravel Fortify authentication action classes and any custom authentication logic that handles user credentials and password verification operations.

### Rules

- **R-HASH-001** MUST: All password verification operations MUST use Hash::check() to perform constant-time comparison between plaintext input and stored hash.

### Verify

```bash
# Verify Hash::check() is used for password verification
grep -r "Hash::check" app/Actions/Fortify/ | grep -c password

# Verify Hash::make() is used for password storage
grep -r "Hash::make" app/Actions/Fortify/ | grep -c password

# Verify no plaintext password assignments exist
grep -r "'password'\s*=>\s*\$" app/ | grep -v Hash::make || echo 'No plaintext password assignments found'
```

**Accept when:**
- All password verification operations in Fortify action classes use Hash::check() with constant-time comparison
- All password storage operations use Hash::make()
- No plaintext password assignments exist in authentication code paths
- Password update and reset workflows validate current credentials using Hash::check() before allowing changes

<enforcement>
Claude Code MUST NOT skip or defer verification. Static analysis scanning for password field assignments without Hash::make() is mandatory. Code review checklist for authentication-related pull requests is required. CI pipeline MUST fail if plaintext password assignments are detected.
</enforcement>
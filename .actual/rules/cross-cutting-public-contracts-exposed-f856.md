# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Public Contracts Exposed

These rules are ALWAYS ACTIVE for all Vue frontend components and shared modules in `resources/js/` that require cross-component communication, flash notifications, or UI state management.

### Rules

- **R-EMITTER-001** SHOULD: Public API contracts exposed in methods.js SHOULD include flash, isDark, and webAuthnNotSupportedMessage for consistent cross-component interfaces.
- **R-EMITTER-002** MUST: Import the tiny-emitter instance from a shared module (e.g., resources/js/methods.js) to ensure all components use the same event bus instance.
- **R-EMITTER-003** MUST: Define event names as constants (e.g., const FLASH_EVENT = 'flash') to prevent typos and enable IDE autocomplete.
- **R-EMITTER-004** MUST: Always clean up event listeners in component lifecycle hooks by storing listener references and calling emitter.off() in beforeUnmount/unmounted.
- **R-EMITTER-005** SHOULD: Document event contracts including event names, payload structures, and expected handler behavior in component documentation or JSDoc comments.
- **R-EMITTER-006** SHOULD: Implement event logging middleware for development to aid debugging and tracing of event flow across multiple components.

### Verify

```bash
# Detect event emission patterns
grep -r "emitter\.emit" resources/js/ --include="*.js" --include="*.vue"

# Detect event subscription patterns
grep -r "emitter\.on" resources/js/ --include="*.js" --include="*.vue"

# Verify tiny-emitter library integration
grep -r "tiny-emitter" resources/js/methods.js
```

**Accept when:**
- Event emission using emitter.emit() is detected in resources/js/ for cross-component communication
- Event subscription using emitter.on() is detected in resources/js/ for event handling
- The tiny-emitter library is imported and instantiated in resources/js/methods.js
- Event listeners are properly cleaned up in component beforeUnmount/unmounted lifecycle hooks
- Event names are defined as constants to prevent typos
- Public API contracts in methods.js include flash, isDark, and webAuthnNotSupportedMessage

<enforcement>
Claude Code MUST NOT skip or defer verification. All grep-based verification commands MUST be executed to confirm event emitter patterns are present and properly implemented. Code review MUST check for proper event listener cleanup and event naming conventions before accepting changes.
</enforcement>
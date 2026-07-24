# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Components Subscribe Multiple

These rules are ALWAYS ACTIVE for all Vue frontend components in `resources/js/` that require cross-component communication, particularly for flash notifications, UI state management, and event-driven boundaries.

### Rules

- **R-EMITTER-001** MAY: Components MAY subscribe to multiple events using separate emitter.on() registrations for different event types.
- **R-EMITTER-002** MUST: Always clean up event listeners in component lifecycle hooks (beforeUnmount/unmounted) by storing listener references and calling emitter.off().
- **R-EMITTER-003** SHOULD: Define event names as constants (e.g., const FLASH_EVENT = 'flash') to prevent typos and enable IDE autocomplete.
- **R-EMITTER-004** MUST: Import the tiny-emitter instance from a shared module (e.g., resources/js/methods.js) to ensure all components use the same event bus instance.
- **R-EMITTER-005** SHOULD: Document event contracts including event names, payload structures, and expected handler behavior in component documentation or JSDoc comments.

### Verify

```bash
# Detect event emission patterns
grep -r "emitter\.emit" resources/js/ --include="*.js" --include="*.vue"

# Detect event subscription patterns
grep -r "emitter\.on" resources/js/ --include="*.js" --include="*.vue"

# Verify tiny-emitter is imported in shared module
grep -r "tiny-emitter" resources/js/methods.js
```

**Accept when:**
- Event emission using emitter.emit() is detected in resources/js/ for cross-component communication
- Event subscription using emitter.on() is detected in resources/js/ for event handling
- The tiny-emitter library is imported and instantiated in resources/js/methods.js
- Event listeners are properly cleaned up in component unmount lifecycle hooks
- Event names are defined as constants in shared modules

<enforcement>
Claude Code MUST NOT skip or defer verification of event emitter patterns, listener cleanup, and tiny-emitter integration in the Vue frontend codebase.
</enforcement>
# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Event Subscription Use

These rules are ALWAYS ACTIVE for all Vue frontend components in `resources/js/` requiring cross-component communication, particularly for flash notifications and UI state management.

### Rules

- **R-EMITTER-001** MUST: Event subscription MUST use the `emitter.on()` method to register event handlers for cross-component communication.

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
- Event emission using `emitter.emit()` is detected in `resources/js/` for cross-component communication
- Event subscription using `emitter.on()` is detected in `resources/js/` for event handling
- The tiny-emitter library is imported and instantiated in `resources/js/methods.js`
- Event listeners are properly cleaned up in component `beforeUnmount`/`unmounted` lifecycle hooks
- Event names are defined as constants to prevent typos and enable IDE autocomplete

<enforcement>
Claude Code MUST NOT skip or defer verification. All event subscription patterns detected in the codebase MUST conform to the `emitter.on()` method requirement. Code review and CI pipeline verification are mandatory before acceptance.
</enforcement>
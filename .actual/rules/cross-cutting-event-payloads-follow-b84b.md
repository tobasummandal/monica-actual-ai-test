# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Event Payloads Follow

These rules are ALWAYS ACTIVE for all Vue frontend components and JavaScript modules in `resources/js/` that require cross-component communication, particularly for flash notifications and UI state management.

### Rules

- **R-EVT-001** SHOULD: Event payloads SHOULD follow a consistent structure with `message` and `level` properties to maintain predictable event handling across all event emitter usage.

### Verify

```bash
# Detect event emission patterns using tiny-emitter
grep -r "emitter\.emit" resources/js/ --include="*.js" --include="*.vue"

# Detect event subscription patterns
grep -r "emitter\.on" resources/js/ --include="*.js" --include="*.vue"

# Verify tiny-emitter is imported in the shared methods module
grep -r "tiny-emitter" resources/js/methods.js
```

**Accept when:**
- Event emission using `emitter.emit()` is detected in `resources/js/` for cross-component communication
- Event subscription using `emitter.on()` is detected in `resources/js/` for event handling
- The tiny-emitter library is imported and instantiated in `resources/js/methods.js`
- Event payloads for flash notifications include both `message` and `level` properties
- Event listeners are cleaned up in component `beforeUnmount` or `unmounted` lifecycle hooks

<enforcement>
Claude Code MUST NOT skip or defer verification of event emitter patterns and payload structure consistency. All detected event emissions MUST be reviewed for compliance with the message/level payload structure.
</enforcement>
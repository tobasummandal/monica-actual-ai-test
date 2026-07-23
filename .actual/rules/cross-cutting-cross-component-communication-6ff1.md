# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Cross Component Communication

These rules are ALWAYS ACTIVE for all Vue frontend components and JavaScript modules in `resources/js/` that require cross-component communication for UI notifications and state changes.

### Rules

- **R-EMITTER-001** MUST: Cross-component communication for UI notifications and state changes MUST use the event emitter pattern via tiny-emitter instance.

### Verify

```bash
# Detect event emission usage
grep -r "emitter\.emit" resources/js/ --include="*.js" --include="*.vue"

# Detect event subscription usage
grep -r "emitter\.on" resources/js/ --include="*.js" --include="*.vue"

# Verify tiny-emitter is imported in shared module
grep -r "tiny-emitter" resources/js/methods.js
```

**Accept when:**
- Event emission using `emitter.emit()` is detected in `resources/js/` for cross-component communication
- Event subscription using `emitter.on()` is detected in `resources/js/` for event handling
- The tiny-emitter library is imported and instantiated in `resources/js/methods.js`
- Event listeners are cleaned up in component `beforeUnmount` or `unmounted` lifecycle hooks
- Event names are defined as constants to prevent typos

<enforcement>
Claude Code MUST NOT skip or defer verification. All cross-component communication patterns detected in code review MUST conform to the event emitter pattern via tiny-emitter, with proper listener cleanup and event name constants.
</enforcement>
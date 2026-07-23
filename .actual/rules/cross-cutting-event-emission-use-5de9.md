# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Event Emission Use

These rules are ALWAYS ACTIVE for all Vue frontend components and JavaScript modules in `resources/js/` that require cross-component communication, flash notifications, or UI state management.

### Rules

- **R-EMIT-001** MUST: Event emission MUST use the emitter.emit() method with structured event payloads containing message and level properties for flash notifications.

### Verify

```bash
# Detect event emission usage
grep -r "emitter\.emit" resources/js/ --include="*.js" --include="*.vue"

# Detect event subscription usage
grep -r "emitter\.on" resources/js/ --include="*.js" --include="*.vue"

# Verify tiny-emitter is imported in methods.js
grep -r "tiny-emitter" resources/js/methods.js
```

**Accept when:**
- Event emission using emitter.emit() is detected in resources/js/ for cross-component communication
- Event subscription using emitter.on() is detected in resources/js/ for event handling
- The tiny-emitter library is imported and instantiated in resources/js/methods.js
- Event listeners are cleaned up in component beforeUnmount/unmounted lifecycle hooks
- Event names are defined as constants to prevent typos

<enforcement>
Claude Code MUST NOT skip or defer verification. All event emission patterns detected in resources/js/ MUST comply with R-EMIT-001. Code review MUST verify proper listener cleanup and event naming conventions before acceptance.
</enforcement>
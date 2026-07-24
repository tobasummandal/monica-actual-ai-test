# Adopt Event Emitter Pattern for Cross-Component Communication in Vue Frontend: Event Emission Use

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase uses Vue as the frontend framework with Laravel backend integration, requiring coordination between components without tight coupling
- The application needs to communicate transient UI state changes (such as flash messages) across component boundaries without direct parent-child relationships
- The tiny-emitter library is integrated to provide a lightweight event bus implementation for publish-subscribe communication patterns
- The methods.js file exposes public contracts including flash messaging and theme state, indicating shared UI concerns across multiple components
- Event-driven boundaries are established through emitter.emit and emitter.on patterns to decouple event producers from consumers

## Problem Statement

Components in the Vue frontend need to communicate state changes and trigger actions across component boundaries without creating tight coupling through props drilling or direct component references, particularly for cross-cutting concerns like flash notifications and UI state management.

## Decision

1. MUST: Event emission MUST use the emitter.emit() method with structured event payloads containing message and level properties for flash notifications

## Policy Block

- MUST Event emission MUST use the emitter.emit() method with structured event payloads containing message and level properties for flash notifications

In scope:
- Vue frontend components requiring cross-component communication
- Flash notification system for user feedback
- UI state management for theme and authentication features
- Event-driven boundaries within the resources/js module

Out of scope:
- Backend Laravel API communication (uses HTTP/REST patterns)
- Direct parent-child component prop passing for hierarchical data
- Vuex or Pinia state management for application-wide state
- WebSocket or real-time communication channels

## Rationale

- The tiny-emitter library provides a lightweight (< 1KB) event bus implementation suitable for decoupled component communication without the overhead of full state management solutions
- The detected pattern shows explicit usage of emitter.emit('flash', { message, level }) and emitter.on(...args) establishing clear event-driven boundaries
- This pattern enables loose coupling between components while maintaining clear contracts through the public API surface in methods.js
- The evidence shows integration with Vue and Laravel ecosystem, indicating a hybrid architecture where event-driven patterns complement the framework's reactive data flow

## Consequences

Positive:
- Components remain loosely coupled and can be developed, tested, and modified independently without breaking dependent components
- Flash notifications and UI state changes can be triggered from any component without requiring direct references or prop drilling through component hierarchies
- The lightweight tiny-emitter library adds minimal bundle size overhead compared to full state management solutions
- Event-driven boundaries create clear separation of concerns between event producers and consumers

Negative:
- Event-driven communication can make data flow harder to trace compared to explicit prop passing, reducing code transparency
- No compile-time type safety for event names and payloads, increasing risk of runtime errors from typos or payload mismatches
- Potential for memory leaks if event listeners are not properly cleaned up when components are destroyed
- Debugging event chains can be more difficult without proper tooling or logging infrastructure

## Alternatives

- Use Vuex or Pinia for centralized state management (rejected)
  Rejected because: Adds significant complexity and bundle size overhead for simple cross-component notifications; overkill for transient UI events like flash messages
  When valid: When application requires complex state management with time-travel debugging, persistence, or extensive shared state across many components
- Use Vue's provide/inject API for dependency injection (rejected)
  Rejected because: Requires explicit injection in every consuming component and creates tighter coupling through dependency injection hierarchy
  When valid: When components need access to stable services or configuration rather than transient event notifications
- Use custom events with $emit and $on on root Vue instance (rejected)
  Rejected because: Vue 3 removed $on, $off, and $once instance methods, making this pattern deprecated and non-portable
  When valid: Only in legacy Vue 2 applications that have not migrated to Vue 3

## Risks

- Memory leaks from event listeners not being cleaned up when components unmount
  Mitigation: Implement cleanup in component beforeUnmount/unmounted lifecycle hooks; document listener cleanup patterns in component guidelines
  Owner: Frontend engineering team
- Runtime errors from event name typos or payload structure mismatches without type safety
  Mitigation: Define event contracts as constants in shared module; consider TypeScript integration for type-safe event definitions
  Owner: Frontend engineering team
- Difficult debugging and tracing of event flow across multiple components
  Mitigation: Implement event logging middleware for development; document event flow diagrams for critical user journeys
  Owner: Frontend engineering team

## Implementation Notes

- Import the tiny-emitter instance from a shared module (e.g., resources/js/methods.js) to ensure all components use the same event bus instance
- Define event names as constants (e.g., const FLASH_EVENT = 'flash') to prevent typos and enable IDE autocomplete
- Always clean up event listeners in component lifecycle hooks: store listener references and call emitter.off() in beforeUnmount/unmounted
- Document event contracts including event names, payload structures, and expected handler behavior in component documentation or JSDoc comments

## Continuation Context


Verify commands:
- grep -r "emitter\.emit" resources/js/ --include="*.js" --include="*.vue"
- grep -r "emitter\.on" resources/js/ --include="*.js" --include="*.vue"
- grep -r "tiny-emitter" resources/js/methods.js

Accept when:
- Event emission using emitter.emit() is detected in resources/js/ for cross-component communication
- Event subscription using emitter.on() is detected in resources/js/ for event handling
- The tiny-emitter library is imported and instantiated in resources/js/methods.js

## Enforcement

- Verified by: Code review checking for proper event emitter usage and listener cleanup
- Verified by: Grep-based verification commands in CI pipeline to detect event emitter patterns
- Verified by: Frontend linting rules to enforce event naming conventions and cleanup patterns
- Violation handling: Code review feedback requesting refactoring to use event emitter pattern for cross-component communication
- Violation handling: CI pipeline warnings when direct component coupling is detected for notification or state broadcasting
- Violation handling: Technical debt tickets created for components using deprecated communication patterns
- Exception process: Document exception rationale in component comments explaining why alternative pattern is necessary
- Exception process: Obtain approval from frontend tech lead for exceptions to event emitter pattern
- Exception process: Review exceptions quarterly to assess if architectural constraints have changed
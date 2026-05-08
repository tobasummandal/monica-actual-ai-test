# Standardize Authentication Middleware for Journal Management Controllers: Authentication Middleware Configured

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all controllers within the app/Domains/Vault/ManageJournals/Web/Controllers namespace and applies to authentication method selection for journal-related HTTP endpoints.

## Context

- The ManageJournals domain contains 8 controllers handling journal, post, photo, metric, and slice-of-life operations, all requiring consistent authentication patterns
- Controllers in the Vault domain manage sensitive personal data (journals, posts, photos) requiring authenticated access to prevent unauthorized data exposure
- A consistent authentication method pattern (authn.methods facet) was detected across all 8 controllers with 79.75% confidence, indicating deliberate architectural standardization
- The application uses Laravel framework conventions where authentication middleware is applied at the controller level to protect routes
- Domain-driven design principles require consistent security boundaries within bounded contexts like ManageJournals

## Problem Statement

Without standardized authentication middleware configuration across journal management controllers, the application risks inconsistent security enforcement, potential unauthorized access to personal journal data, and increased maintenance burden when security requirements change. The pattern detection reveals a consistent approach that needs formal documentation to ensure future controllers maintain the same security posture.

## Decision

1. MUST: Authentication middleware MUST be configured using the same authentication method pattern detected across JournalController, PostController, JournalPhotoController, PostPhotoController, JournalMetricController, PostMetricController, SliceOfLifeController, and PostSliceOfLifeController

## Policy Block

- MUST Authentication middleware MUST be configured using the same authentication method pattern detected across JournalController, PostController, JournalPhotoController, PostPhotoController, JournalMetricController, PostMetricController, SliceOfLifeController, and PostSliceOfLifeController

In scope:
- All HTTP controllers in app/Domains/Vault/ManageJournals/Web/Controllers
- Journal, Post, Photo, Metric, and SliceOfLife resource controllers
- Any new controllers added to the ManageJournals domain
- Authentication middleware configuration and method selection

Out of scope:
- Controllers outside the ManageJournals domain
- API controllers with different authentication schemes (e.g., token-based)
- Public-facing controllers that intentionally allow unauthenticated access
- Authorization logic beyond authentication (handled separately)
- Service layer authentication (handled at controller boundary)

Exceptions:
- EXC-001: A controller method explicitly requires public access for specific business requirements (e.g., public journal sharing)

## Rationale

- Pattern detection identified consistent authentication middleware usage across 8 controllers with 79.75% confidence, indicating this is an established architectural standard rather than coincidental similarity
- Standardizing authentication at the controller level provides a clear security boundary for the ManageJournals bounded context, making security audits and compliance verification straightforward
- Consistent authentication patterns reduce cognitive load for developers working across multiple controllers in the domain and prevent security configuration drift
- The high significance score (79.75%) and complete coverage across all controller types (journals, posts, photos, metrics, slices) demonstrates this pattern is fundamental to the domain's security architecture

## Consequences

Positive:
- Consistent security posture across all journal management endpoints reduces risk of unauthorized access
- New developers can quickly understand and replicate authentication patterns when adding controllers
- Centralized authentication configuration enables easier security audits and compliance verification
- Reduced likelihood of security vulnerabilities from inconsistent or missing authentication middleware

Negative:
- Rigid authentication requirements may complicate future features requiring different authentication schemes
- Additional boilerplate code required in every controller constructor
- Changes to authentication method require updates across all 8+ controllers in the domain
- May create false sense of security if developers assume authentication alone is sufficient without proper authorization checks

## Alternatives

- Apply authentication middleware at the route definition level in web.php rather than in individual controllers (rejected)
  Rejected because: Route-level middleware makes it harder to see security configuration when reading controller code, and the detected pattern shows controller-level configuration is already established across 8 files
  When valid: For applications with simpler domain structures or when route grouping naturally aligns with authentication boundaries
- Create a base JournalController class with authentication middleware that all controllers extend (deferred)
  Rejected because: Not rejected, but deferred pending analysis of controller inheritance patterns; could reduce duplication if inheritance is already used
  When valid: If controllers already share significant common functionality beyond authentication, or if the domain grows to 15+ controllers
- Use attribute-based authentication configuration (PHP 8 attributes) instead of middleware method calls (rejected)
  Rejected because: Would require refactoring all 8 existing controllers and the detected pattern shows constructor-based middleware is the established convention
  When valid: For greenfield projects on PHP 8.1+ or during a major framework upgrade that standardizes on attributes

## Risks

- Developers may forget to apply authentication middleware when creating new controllers in the ManageJournals domain
  Mitigation: Create controller template/generator that includes authentication middleware by default; add automated verification in CI pipeline
  Owner: Engineering team
- Authentication middleware configuration may diverge over time as different developers make modifications
  Mitigation: Implement automated static analysis to detect authentication pattern deviations; include authentication consistency checks in code review checklist
  Owner: Security team and engineering leads
- Future authentication method changes may require coordinated updates across all controllers simultaneously
  Mitigation: Document authentication method dependencies; use feature flags for authentication method transitions; consider base controller pattern for easier centralized updates
  Owner: Architecture team

## Implementation Notes

- Review all 8 existing controllers to document the exact authentication middleware configuration pattern (method name, parameters, placement)
- Create a controller template or artisan command for generating new ManageJournals controllers with authentication pre-configured
- Add authentication pattern documentation to the ManageJournals domain README with code examples from existing controllers
- Consider extracting authentication configuration to a trait or base controller if duplication becomes problematic as the domain grows

## Continuation Context


Verify commands:
- grep -r "__construct" app/Domains/Vault/ManageJournals/Web/Controllers/*.php | wc -l
- grep -r "middleware" app/Domains/Vault/ManageJournals/Web/Controllers/*.php | grep -v "//" | wc -l
- find app/Domains/Vault/ManageJournals/Web/Controllers -name "*Controller.php" -exec grep -L "middleware" {} \;

Accept when:
- All controller files in app/Domains/Vault/ManageJournals/Web/Controllers contain authentication middleware configuration
- The grep command for middleware references returns a count equal to or greater than the number of controller files
- The find command searching for controllers without middleware returns no results (empty output)

## Enforcement

- Verified by: Automated static analysis in CI pipeline checking for middleware presence in ManageJournals controllers
- Verified by: Code review checklist item requiring verification of authentication middleware in new controllers
- Verified by: Quarterly security audit reviewing authentication configuration across all Vault domain controllers
- Violation handling: CI pipeline fails if new controller in ManageJournals domain lacks authentication middleware
- Violation handling: Pull requests adding controllers without proper authentication are blocked until corrected
- Violation handling: Security team is notified of authentication pattern violations detected in production code
- Exception process: Developer submits exception request to security team with business justification for deviation
- Exception process: Security team and domain architect review exception request and assess risk
- Exception process: Approved exceptions must be documented in controller docblock and tracked in security exception register
- Exception process: Exceptions are reviewed quarterly and must be re-approved or remediated
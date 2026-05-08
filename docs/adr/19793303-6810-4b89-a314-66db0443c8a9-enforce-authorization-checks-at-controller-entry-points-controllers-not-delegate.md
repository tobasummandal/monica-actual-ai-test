# Enforce Authorization Checks at Controller Entry Points: Controllers Not Delegate

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ACTIVE for all controller implementations and service layer authorization enforcement points within the application codebase.

## Context

- The application implements a domain-driven architecture with multiple bounded contexts (Vault, Contact, etc.) that require consistent authorization enforcement
- Controllers serve as the primary entry points for user requests and must validate permissions before executing business logic
- The codebase demonstrates a pattern of authorization checks at controller and service boundaries, particularly in JournalController, GroupController, and ImportVCalendar service
- Without standardized authorization enforcement points, security vulnerabilities can arise from inconsistent or missing permission checks across different domains

## Problem Statement

The application needs a consistent, reliable mechanism to enforce authorization checks at system boundaries to prevent unauthorized access to domain resources. Without standardized enforcement points in controllers and services, developers may inadvertently expose sensitive operations or data, leading to security vulnerabilities and inconsistent access control across different application domains.

## Decision

1. MUST_NOT: Controllers MUST NOT delegate authorization responsibility solely to the frontend or client-side validation

## Policy Block

- MUST_NOT Controllers MUST NOT delegate authorization responsibility solely to the frontend or client-side validation

In scope:
- All HTTP controller methods in web and API layers
- Service layer methods that perform privileged operations or access sensitive data
- Domain service classes that can be invoked from multiple contexts (e.g., ImportVCalendar)
- RESTful API endpoints and GraphQL resolvers

Out of scope:
- Internal helper methods that are only called after authorization has been verified
- Read-only public data endpoints that do not require authentication
- System-level background jobs running with elevated privileges
- Database query builders and repository methods (authorization should occur at higher layers)

Exceptions:
- EXC-001: Public API endpoints explicitly designed for unauthenticated access (e.g., health checks, public documentation)
- EXC-002: Administrative CLI commands that run with system-level privileges outside the web request cycle

## Rationale

- Pattern detected across 3 files with 79.27% confidence indicates a consistent architectural approach to authorization enforcement in the codebase
- Enforcement at controller and service boundaries provides defense-in-depth, ensuring authorization checks occur even if one layer is bypassed
- Early authorization checks (fail-fast principle) prevent unnecessary processing of unauthorized requests and reduce attack surface
- Standardizing enforcement points across domains (Vault, Contact, etc.) ensures consistent security posture and reduces cognitive load for developers

## Consequences

Positive:
- Consistent authorization enforcement across all application domains reduces security vulnerabilities
- Fail-fast approach prevents unauthorized operations from consuming resources or exposing sensitive data
- Clear enforcement points make security audits and code reviews more efficient
- Defense-in-depth strategy provides multiple layers of protection against authorization bypass attempts

Negative:
- Additional authorization checks at multiple layers may introduce performance overhead for legitimate requests
- Developers must remember to implement authorization checks for every new controller method, increasing development effort
- Overly restrictive authorization at service layer may reduce reusability of services in trusted contexts
- Maintaining consistency across multiple enforcement points requires ongoing vigilance and code review discipline

## Alternatives

- Implement authorization exclusively through framework middleware applied globally to all routes (rejected)
  Rejected because: Global middleware cannot provide resource-specific authorization checks and lacks the context needed for fine-grained access control
  When valid: Suitable only for coarse-grained authentication checks (e.g., verifying user is logged in) but insufficient for resource-level authorization
- Rely on database-level row security policies (RLS) for all authorization enforcement (rejected)
  Rejected because: Database-level enforcement occurs too late in the request cycle, after application logic has executed, and provides poor error messaging to users
  When valid: Can be used as an additional defense layer but should not replace application-level authorization
- Implement authorization checks only at the service layer, removing controller-level checks (deferred)
  Rejected because: While this reduces duplication, it delays authorization until after request parsing and validation, potentially exposing more attack surface
  When valid: May be acceptable for internal services with trusted callers, but requires careful analysis of trust boundaries

## Risks

- Developers may forget to add authorization checks to new controller methods, creating security gaps
  Mitigation: Implement automated static analysis tools to detect controller methods lacking authorization checks; require security-focused code review for all controller changes
  Owner: Security team and engineering team
- Performance degradation from multiple authorization checks in the request path
  Mitigation: Implement caching for authorization decisions within a request context; profile authorization overhead and optimize hot paths
  Owner: Engineering team
- Inconsistent authorization logic across different domains leading to security vulnerabilities
  Mitigation: Create shared authorization service abstractions and reusable policy classes; establish coding standards and provide authorization helper libraries
  Owner: Architecture team and security team

## Implementation Notes

- Use Laravel's built-in authorization features (policies and gates) to standardize authorization checks across controllers
- Create base controller classes that enforce authorization check patterns and provide helper methods for common authorization scenarios
- Document authorization requirements in controller method docblocks to make security expectations explicit
- Implement request-scoped caching for authorization decisions to minimize performance impact of multiple checks
- Consider using aspect-oriented programming or decorators to apply authorization checks declaratively rather than imperatively

## Continuation Context


Verify commands:
- grep -r "public function" app/Domains/*/Web/Controllers/ | grep -v "authorize\|policy\|gate" | head -20
- find app/Domains -name "*Controller.php" -exec grep -L "authorize\|policy\|can(" {} \;
- phpstan analyse --level=5 app/Domains/*/Web/Controllers/ --error-format=table

Accept when:
- All controller methods that access or modify resources include explicit authorization checks before business logic execution
- Static analysis tools report zero violations of authorization enforcement patterns in controller classes
- Code review checklist includes verification of authorization checks for all new controller methods

## Enforcement

- Verified by: Automated static analysis in CI pipeline scanning for controller methods without authorization checks
- Verified by: Security-focused code review requiring explicit authorization verification for all controller changes
- Verified by: Periodic security audits examining authorization enforcement patterns across domains
- Violation handling: CI pipeline fails if static analysis detects controller methods lacking authorization checks
- Violation handling: Code review process blocks merge requests that introduce controller methods without proper authorization
- Violation handling: Security team conducts remediation review for any violations discovered in production code
- Exception process: Developer submits exception request with justification to security team via documented process
- Exception process: Security team reviews request and assesses risk, requiring alternative controls if authorization is waived
- Exception process: Approved exceptions must be documented in code with inline comments referencing security team approval ticket
- Exception process: Exception registry maintained by security team with periodic review of all active exceptions
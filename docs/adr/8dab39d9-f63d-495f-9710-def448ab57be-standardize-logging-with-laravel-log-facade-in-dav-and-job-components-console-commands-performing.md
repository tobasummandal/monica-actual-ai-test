# Standardize Logging with Laravel Log Facade in DAV and Job Components: Console Commands Performing

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The application implements CardDAV/CalDAV synchronization features requiring detailed observability of distributed operations across multiple services and background jobs
- Laravel's Log facade provides a standardized PSR-3 compliant logging interface with channel support, contextual data, and configurable handlers suitable for debugging complex synchronization workflows
- The DAV client components and job processors handle external API interactions where request/response logging is critical for troubleshooting integration failures
- Console commands for address book subscription and application setup require operational visibility during long-running processes
- The pattern appears consistently across 11 files in the Contact domain's DAV-related components with 78.73% confidence, indicating an established architectural convention

## Problem Statement

Without a standardized logging approach in DAV synchronization components and background jobs, debugging distributed operations becomes inconsistent, troubleshooting integration failures lacks sufficient context, and operational visibility into long-running processes is fragmented across different logging mechanisms.

## Decision

1. SHOULD: Console commands performing setup or subscription operations SHOULD log progress milestones and completion status for operational visibility

## Policy Block

- SHOULD Console commands performing setup or subscription operations SHOULD log progress milestones and completion status for operational visibility

In scope:
- DAV backend implementations (CalDAV/CardDAV)
- Background jobs in Contact/Dav and Contact/DavClient domains
- DavClient service utilities and synchronization services
- Console commands for address book and application setup
- Any component performing external DAV server communication

Out of scope:
- Frontend JavaScript logging
- Database query logging (handled by Laravel's query log)
- HTTP middleware logging (handled by web server/framework)
- Third-party package internal logging
- Unit test execution logging

Exceptions:
- EXC-001: Performance-critical hot paths where logging overhead is measured and documented as unacceptable
- EXC-002: Temporary debugging code using dd(), dump(), or var_dump() during active development

## Rationale

- The pattern detection identified consistent usage of Laravel's Log facade across 11 files in the DAV synchronization domain with 78.73% confidence, indicating this is an established architectural convention rather than ad-hoc implementation
- Laravel's Log facade provides PSR-3 compliance, multiple channel support, and integration with modern logging infrastructure (Monolog), making it suitable for distributed system observability
- DAV synchronization involves complex multi-step operations with external dependencies where detailed logging is essential for debugging integration failures and understanding system behavior
- Standardizing on a single logging approach reduces cognitive load for developers and enables consistent log aggregation, monitoring, and alerting across the application

## Consequences

Positive:
- Consistent logging patterns across DAV components improve developer productivity when debugging synchronization issues
- Structured contextual logging enables effective log aggregation and filtering in production monitoring tools
- PSR-3 compliance ensures compatibility with standard logging infrastructure and third-party integrations
- Centralized log configuration through Laravel's logging.php allows environment-specific routing without code changes

Negative:
- Dependency on Laravel's Log facade creates framework coupling that may complicate future framework migrations
- Excessive logging in high-throughput synchronization operations could impact performance and storage costs
- Developers must learn and follow log level conventions to maintain consistent log quality
- Sensitive data (authentication tokens, personal information) requires careful filtering to avoid logging security violations

## Alternatives

- Use Monolog directly without Laravel's Log facade abstraction (rejected)
  Rejected because: Bypassing Laravel's facade loses framework integration benefits (configuration management, service container resolution, testing helpers) and creates inconsistency with the rest of the Laravel application
  When valid: Valid for standalone PHP libraries that must remain framework-agnostic
- Implement custom logging service with domain-specific methods (rejected)
  Rejected because: Adds unnecessary abstraction layer and maintenance burden when Laravel's Log facade already provides sufficient functionality with PSR-3 compliance
  When valid: Valid if domain requires specialized logging features not available in PSR-3 (e.g., structured event sourcing, audit trails with cryptographic signatures)
- Use event-driven observability with Laravel Events instead of direct logging (deferred)
  Rejected because: Not rejected - this is complementary. Events can be used for business-significant occurrences while Log facade handles technical/debugging information
  When valid: Valid for business events that require multiple listeners (notifications, analytics, audit) beyond simple logging

## Risks

- Sensitive data (authentication tokens, personal contact information) may be inadvertently logged, creating security and privacy compliance violations
  Mitigation: Implement log scrubbing middleware, conduct code reviews focused on logged context data, and configure log processors to redact sensitive patterns. Document sensitive data handling in logging guidelines.
  Owner: Security team with engineering team support
- Excessive debug logging in production could degrade performance and increase infrastructure costs for log storage and processing
  Mitigation: Use environment-based log level configuration, implement sampling for high-frequency operations, and establish log retention policies. Monitor log volume metrics and set up alerts for anomalies.
  Owner: DevOps team with engineering team
- Inconsistent log level usage across developers could reduce log quality and make filtering ineffective
  Mitigation: Document clear log level guidelines with examples, include logging standards in code review checklist, and provide team training on effective logging practices
  Owner: Engineering team lead

## Implementation Notes

- Import the Log facade at the top of each class: `use Illuminate\Support\Facades\Log;`
- Use appropriate log levels: `Log::debug()` for detailed tracing, `Log::info()` for significant events, `Log::warning()` for recoverable issues, `Log::error()` for failures requiring attention
- Include structured context as second parameter: `Log::info('VCard synchronized', ['contact_id' => $id, 'addressbook_id' => $addressbookId])`
- For DAV operations, consider using a dedicated channel configured in config/logging.php: `Log::channel('dav')->info('Sync started')`
- In job classes, log at the beginning and end of handle() method with job-specific context to enable job execution tracking
- Avoid logging in tight loops - consider sampling or aggregating log messages for bulk operations

## Continuation Context


Verify commands:
- grep -r "use Illuminate\\\\Support\\\\Facades\\\\Log" app/Domains/Contact/Dav* app/Console/Commands/ | wc -l
- grep -r "Log::" app/Domains/Contact/Dav* app/Console/Commands/ | grep -E "(debug|info|warning|error)" | wc -l
- php artisan tinker --execute="echo class_exists('Illuminate\\\\Support\\\\Facades\\\\Log') ? 'PASS' : 'FAIL';"

Accept when:
- Log facade import statements are present in all DAV backend classes, DavClient services, and relevant console commands
- Log method calls (debug/info/warning/error) are present in job handle() methods and synchronization service methods
- Laravel's Log facade class is available and properly configured in the application

## Enforcement

- Verified by: Code review checklist requiring Log facade usage in DAV and job components
- Verified by: Static analysis with custom PHPStan/Psalm rules detecting missing logging in job handle() methods
- Verified by: Automated grep-based verification in CI pipeline checking for Log facade imports in target directories
- Violation handling: PR comments requesting addition of appropriate logging statements with context
- Violation handling: Failed CI checks for missing Log facade imports in new DAV/job files
- Violation handling: Architecture review escalation for systematic violations or proposed alternatives
- Exception process: Developer documents performance impact with profiling data and proposes alternative observability approach
- Exception process: Tech lead reviews exception request and approves/rejects with written justification
- Exception process: Approved exceptions are documented in code comments with ADR reference and expiration date for review
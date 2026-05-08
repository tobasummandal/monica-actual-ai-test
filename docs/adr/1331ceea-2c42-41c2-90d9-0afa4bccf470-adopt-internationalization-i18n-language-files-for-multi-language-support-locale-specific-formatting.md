# Adopt Internationalization (i18n) Language Files for Multi-Language Support: Locale Specific Formatting

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase contains 20 language files across multiple locales (Hindi, Hebrew, Japanese, Italian) organized in a lang/ directory structure
- Language files follow a consistent PHP-based pattern for translations covering auth, validation, passwords, actions, pagination, HTTP statuses, and formatting
- The pattern indicates a deliberate architectural choice to support internationalization (i18n) through language-specific resource files
- Multiple language files share identical structural patterns suggesting a framework-driven approach to localization
- The presence of specialized translation files (http-statuses, format, pagination) indicates comprehensive i18n coverage beyond basic UI strings

## Problem Statement

Applications serving global audiences require a systematic approach to manage translations and locale-specific content. Without a standardized internationalization strategy, translation strings become scattered throughout the codebase, making maintenance difficult, introducing inconsistencies, and creating barriers to adding new language support. The system needs a scalable, maintainable approach to handle multiple languages while keeping translation logic separate from business logic.

## Decision

1. MAY: Locale-specific formatting rules (dates, numbers, currency) MAY be defined in dedicated format.php files per locale

## Policy Block

- MAY Locale-specific formatting rules (dates, numbers, currency) MAY be defined in dedicated format.php files per locale

In scope:
- All user-facing text strings in web interfaces, APIs, and command-line tools
- Error messages, validation feedback, and system notifications
- HTTP status messages and standard framework responses
- Authentication and authorization messages
- Pagination controls and navigation elements

Out of scope:
- Internal logging messages not visible to end users
- Developer documentation and code comments
- Configuration file keys and technical identifiers
- Database schema names and internal system identifiers
- Third-party library messages that cannot be intercepted

Exceptions:
- EXC-001: Emergency hotfixes where translation infrastructure is unavailable
- EXC-002: Prototype or proof-of-concept code not intended for production

## Rationale

- The detection of 20 language files across 4 different locales (Hindi, Hebrew, Japanese, Italian) with 70% significance demonstrates a mature, established internationalization pattern
- Consistent file structure across locales (auth.php, validation.php, passwords.php, etc.) indicates a framework-driven approach that reduces implementation complexity
- Separating translations from code improves maintainability by allowing translators to work independently from developers and enabling easier updates
- The pattern's 70% confidence score based on 20 files suggests this is a core architectural decision rather than an experimental feature

## Consequences

Positive:
- Enables rapid expansion to new markets by adding locale directories without modifying application code
- Improves collaboration between developers and translators through clear separation of concerns
- Reduces bugs related to string concatenation and locale-specific formatting issues
- Facilitates automated translation workflows and integration with translation management systems
- Enhances code maintainability by eliminating scattered hardcoded strings throughout the codebase

Negative:
- Adds complexity to the build and deployment process requiring language file compilation or loading
- Increases initial development time as developers must reference translation keys instead of inline strings
- Creates potential for missing translations if new keys are added without updating all locale files
- May impact performance if translation loading is not properly cached or optimized
- Requires additional tooling and processes to manage translation completeness across locales

## Alternatives

- Inline hardcoded strings with no internationalization support (rejected)
  Rejected because: Does not support multi-language requirements and creates maintenance burden when localization is eventually needed
  When valid: Only appropriate for internal tools with a single-language user base and no plans for expansion
- Database-driven translation storage with dynamic key lookup (rejected)
  Rejected because: Adds database dependency and latency for every string lookup; increases operational complexity without significant benefit for static translations
  When valid: Useful for user-generated content that requires translation or when translations need to be updated without deployments
- JSON-based language files instead of PHP arrays (deferred)
  Rejected because: PHP arrays provide better performance in PHP applications through opcode caching; JSON requires parsing overhead
  When valid: Consider for polyglot architectures where multiple services in different languages need to share translation files

## Risks

- Translation drift where some locales become outdated as new features are added without updating all language files
  Mitigation: Implement automated checks in CI pipeline to detect missing translation keys across locales; use fallback locale (English) for missing keys
  Owner: Engineering team with localization lead oversight
- Performance degradation if language files are loaded inefficiently or not cached properly
  Mitigation: Implement opcode caching for PHP files; lazy-load only required translation categories; monitor translation loading performance metrics
  Owner: Platform engineering team
- Translation quality issues if non-native speakers provide translations without proper review
  Mitigation: Establish translation review process with native speakers; consider professional translation services for critical user-facing content
  Owner: Product team with localization vendors

## Implementation Notes

- Use a localization framework (e.g., Laravel's localization, Symfony Translation) that provides helper functions for translation key lookup and parameter substitution
- Establish naming conventions for translation keys that reflect their context (e.g., auth.failed, validation.required, pagination.next)
- Create a base English locale as the source of truth and use it as the fallback when translations are missing in other locales
- Implement automated tooling to extract translatable strings from code and generate skeleton translation files for new locales
- Document the translation workflow including how to add new keys, request new locales, and submit translation updates

## Continuation Context


Verify commands:
- find lang/ -type f -name '*.php' | wc -l | grep -E '[0-9]+'
- grep -r "echo\|print" app/ | grep -v "trans(\|__('\|@lang" || echo 'No hardcoded strings found'
- php artisan lang:check --missing || composer run check-translations

Accept when:
- Language directory structure exists with at least one locale containing all required translation categories (auth, validation, passwords, actions, pagination, http-statuses, format)
- No hardcoded user-facing strings are found in application code outside of language files
- Translation loading mechanism is implemented and functional with fallback to default locale for missing keys

## Enforcement

- Verified by: Automated CI pipeline checks for missing translation keys across supported locales
- Verified by: Code review process verifying new user-facing strings are added to language files
- Verified by: Static analysis tools scanning for hardcoded strings in application code
- Verified by: Periodic translation completeness audits comparing key counts across locales
- Violation handling: CI pipeline fails if hardcoded user-facing strings are detected in pull requests
- Violation handling: Code review blocks merge if translation keys are missing from language files
- Violation handling: Warning notifications sent to development team when translation drift exceeds 5% between locales
- Violation handling: Quarterly reports on translation completeness shared with product and engineering leadership
- Exception process: Developer submits exception request via issue tracker with justification and remediation timeline
- Exception process: Technical lead reviews and approves/rejects based on business impact and technical constraints
- Exception process: Approved exceptions are documented with follow-up tickets created for proper implementation
- Exception process: Exception metrics are tracked and reviewed monthly to identify systemic issues
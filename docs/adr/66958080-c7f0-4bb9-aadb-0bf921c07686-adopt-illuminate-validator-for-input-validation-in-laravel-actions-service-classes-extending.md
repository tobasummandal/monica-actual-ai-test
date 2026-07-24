# Adopt Illuminate Validator for Input Validation in Laravel Actions: Service Classes Extending

Status: proposed
Date: 2024-01-09
Deciders: Detection Pipeline (automated)

## Context

- The codebase uses Laravel Fortify for authentication and user management operations, requiring consistent input validation across user-facing actions
- User profile updates, password changes, and account creation involve sensitive operations that must validate input before persistence
- The application implements service-oriented architecture with dedicated action classes (App\Actions\Fortify) and domain services (App\Domains) that process user input
- Laravel's Illuminate\Support\Facades\Validator provides declarative validation rules with RFC-style constraints (required, string, max, email, unique)
- Five files demonstrate consistent use of Validator::make() with array-based rule definitions before any data persistence or business logic execution

## Problem Statement

User input in authentication and profile management flows must be validated against business rules and data constraints before persistence to prevent invalid data, security vulnerabilities, and data integrity violations. Without standardized validation, each action class would implement ad-hoc validation logic, leading to inconsistent error handling, duplicated code, and potential security gaps.

## Decision

1. SHOULD: Service classes extending BaseService SHOULD implement rules() method returning validation rule arrays and call validateRules() or validate() methods

## Policy Block

- SHOULD Service classes extending BaseService SHOULD implement rules() method returning validation rule arrays and call validateRules() or validate() methods

In scope:
- Action classes in App\Actions\Fortify namespace implementing Laravel Fortify contracts
- Service classes in App\Domains namespace extending BaseService
- Any class method accepting array $input or array $data parameters from user requests
- User profile operations (create, update, password reset)
- Authentication and authorization flows

Out of scope:
- Internal service-to-service communication where input is already validated
- Data transformations on trusted internal data structures
- Read-only query operations that do not modify state
- Background jobs processing pre-validated data from queues

Exceptions:
- EXC-001: Input originates from trusted internal services with guaranteed data contracts
- EXC-002: Performance-critical paths where validation overhead is measured as unacceptable

## Rationale

- The evidence shows consistent use of Validator::make() across 5 files with 81.78% confidence, indicating an established pattern rather than isolated usage
- Laravel's Illuminate Validator provides declarative, testable validation with built-in rules that reduce boilerplate and improve maintainability
- Fortify contract implementations (UpdatesUserProfileInformation, UpdatesUserPasswords, CreatesNewUsers, ResetsUserPasswords) all follow the same validation-before-persistence pattern
- BaseService subclasses demonstrate a rules() method pattern that centralizes validation logic and enables reuse across service boundaries

## Consequences

Positive:
- Consistent validation behavior across all user-facing actions reduces security vulnerabilities and data integrity issues
- Declarative validation rules are self-documenting and easier to audit than imperative validation code
- Laravel's validation error messages and error bags provide standardized user feedback without custom error handling
- Validation rules can be tested independently of business logic, improving test coverage and maintainability

Negative:
- Tight coupling to Laravel's Illuminate\Support\Facades\Validator makes the codebase framework-dependent
- Complex cross-field validation requires after() callbacks, mixing declarative and imperative styles
- Validation rule arrays can become verbose for complex input structures with many fields
- Performance overhead of validation may be unnecessary for trusted internal service calls

## Alternatives

- Use PHP 8+ attributes for validation rules on DTO classes (rejected)
  Rejected because: No evidence of DTO classes or attribute-based validation in the codebase; would require significant refactoring of existing action classes
  When valid: When migrating to a more type-safe architecture with explicit data transfer objects
- Implement custom validation classes with validate() methods per action (rejected)
  Rejected because: Increases code duplication and maintenance burden; Laravel's Validator provides sufficient functionality with less boilerplate
  When valid: When validation logic becomes too complex for declarative rules and requires extensive custom logic
- Use Laravel Form Request classes for validation (deferred)
  Rejected because: Form Requests are HTTP-layer concerns; action classes operate at service layer and may be invoked outside HTTP context
  When valid: For controller-level validation before delegating to action classes, creating a two-layer validation strategy

## Risks

- Validation rules may drift from actual database constraints, allowing invalid data to pass validation but fail at persistence
  Mitigation: Implement automated tests that verify validation rules match database schema constraints; use database-level constraints as source of truth
  Owner: Engineering team
- Custom after() callbacks can hide complex validation logic that is difficult to test and maintain
  Mitigation: Limit after() callback usage to cross-field validation only; extract complex logic to dedicated validator classes; document callback behavior in method docblocks
  Owner: Engineering team
- Framework upgrade to future Laravel versions may introduce breaking changes to Validator API
  Mitigation: Maintain comprehensive test coverage of validation behavior; monitor Laravel upgrade guides; consider abstracting validation behind internal interfaces
  Owner: Platform team

## Implementation Notes

- Import Illuminate\Support\Facades\Validator at the top of action and service classes that accept user input
- Call Validator::make($input, $rules) before any business logic, passing input array and rules array
- For Fortify actions, chain ->validateWithBag('bagName') to namespace errors; for services, chain ->validate() or use validateRules()
- Define validation rules using array syntax: ['field' => ['required', 'string', 'max:255']]
- Use Illuminate\Validation\Rule class for complex rules like Rule::unique('table')->ignore($id)
- For cross-field validation, add ->after(function($validator) { ... }) callback after Validator::make()
- Ensure validation occurs in the same method that performs persistence to maintain clear control flow

## Continuation Context


Verify commands:
- grep -r "Validator::make" app/Actions app/Domains --include="*.php" | wc -l
- grep -r "public function.*array \$input" app/Actions --include="*.php" -A 10 | grep -c "Validator::make"
- php artisan test --filter=Validation

Accept when:
- All action classes in App\Actions\Fortify contain Validator::make() calls before persistence operations
- Service classes extending BaseService implement rules() method and call validation methods
- Validation tests pass for all user input scenarios including edge cases and invalid input

## Enforcement

- Verified by: Code review checklist verifying Validator::make() presence in action classes accepting user input
- Verified by: Static analysis tool scanning for array $input parameters without subsequent Validator::make() calls
- Verified by: CI pipeline running validation test suite on every pull request
- Violation handling: Pull requests without validation in user-facing actions are blocked until validation is added
- Violation handling: Security review triggered for any action class that persists user input without validation
- Violation handling: Post-merge violations generate technical debt tickets assigned to the committing team
- Exception process: Submit exception request to lead engineer with justification and alternative security controls
- Exception process: Document exception in code comments with reference to approval and rationale
- Exception process: Review exceptions quarterly to determine if they can be eliminated
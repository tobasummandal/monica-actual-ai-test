# Architecture Decision Records for tobasummandal/monica-actual-ai-test

## ADR 1: Adopt Domain-Driven Service Layer Architecture for Business Operations: Domain Services Reused

**Policies**:
1. Domain services MAY be reused across multiple controllers or other services when appropriate

---

## ADR 2: Adopt Domain-Driven Service Layer Architecture for Business Operations: Controllers Placed Web

**Policies**:
1. Controllers SHOULD be placed in Web/Controllers subdirectories within their respective domain feature folders

---

## ADR 3: Adopt Domain-Driven Service Layer Architecture for Business Operations: Service Classes Encapsulate

**Policies**:
1. Service classes SHOULD encapsulate a single business operation or use case to maintain single responsibility principle

---

## ADR 4: Adopt Domain-Driven Service Layer Architecture for Business Operations: Domain Services Organized

**Policies**:
1. Domain services MUST be organized by feature area (e.g., CreateAccount, CancelAccount, ManageUsers) to maintain clear boundaries

---

## ADR 5: Adopt Domain-Driven Service Layer Architecture for Business Operations: Web Controllers Delegate

**Policies**:
1. Web controllers MUST delegate business logic execution to domain service classes rather than implementing logic directly

---

## ADR 6: Adopt Domain-Driven Service Layer Architecture for Business Operations: Business Operations Implemented

**Policies**:
1. Business operations MUST be implemented as dedicated service classes within domain-specific namespaces (e.g., app/Domains/{Domain}/{Feature}/Services/)

---

## ADR 7: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Pipelines Run Unit

**Policies**:
1. CI/CD pipelines MAY run unit and feature tests in parallel to optimize build time

---

## ADR 8: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Domain Specific Tests

**Policies**:
1. Domain-specific tests SHOULD be organized in subdirectories reflecting the application's domain structure

---

## ADR 9: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Test Files Follow

**Policies**:
1. Test files SHOULD follow the naming convention *Test.php to ensure automatic discovery

---

## ADR 10: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Unit Tests Run

**Policies**:
1. Unit tests MUST run before feature tests in the CI/CD pipeline to provide fast feedback

---

## ADR 11: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Pipelines Execute Both

**Policies**:
1. CI/CD pipelines MUST execute both unit and feature test suites on every commit

---

## ADR 12: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Feature Tests Placed

**Policies**:
1. All feature tests MUST be placed in the tests/Feature directory for end-to-end scenario validation

---

## ADR 13: Standardize Unit and Feature Test Organization in CI/CD Pipeline: Unit Tests Placed

**Policies**:
1. All unit tests MUST be placed in the tests/Unit directory and organized by domain boundaries

---

## ADR 14: Adopt Domain-Driven Resource Modeling for Data Access Layer: Models Implement Additional

**Policies**:
1. Models MAY implement additional interfaces or traits to support cross-cutting concerns like auditing, soft deletes, or timestamps

---

## ADR 15: Adopt Domain-Driven Resource Modeling for Data Access Layer: Resource Transformation Logic

**Policies**:
1. Resource transformation logic (converting between domain models and external formats) SHOULD be encapsulated within dedicated resource classes

---

## ADR 16: Adopt Domain-Driven Resource Modeling for Data Access Layer: Data Models Follow

**Policies**:
1. Data models MUST follow a consistent naming convention that reflects their domain purpose (e.g., File.php for file entities, VCardResource.php for vCard protocol resources)

---

## ADR 17: Adopt Domain-Driven Resource Modeling for Data Access Layer: Model Classes Organized

**Policies**:
1. Model classes SHOULD be organized by domain context (e.g., Contact, File) to maintain clear bounded contexts

---

## ADR 18: Adopt Domain-Driven Resource Modeling for Data Access Layer: Resource Classes External

**Policies**:
1. Resource classes for external protocol integration (e.g., VCard, VCalendar) MUST be separated from core domain models

---

## ADR 19: Adopt Domain-Driven Resource Modeling for Data Access Layer: Domain Entities Represented

**Policies**:
1. All domain entities MUST be represented by dedicated model classes that encapsulate data structure and basic persistence logic

---

## ADR 20: Adopt Encrypted Secrets Management in CI/CD Pipeline: Teams Use Environment

**Policies**:
1. Teams MAY use environment-specific secret namespaces to isolate development, staging, and production credentials

---

## ADR 21: Adopt Encrypted Secrets Management in CI/CD Pipeline: Pipeline Logs Not

**Policies**:
1. Pipeline logs MUST NOT expose secret values in output, error messages, or debug information

---

## ADR 22: Adopt Encrypted Secrets Management in CI/CD Pipeline: Secrets Rotation Policies

**Policies**:
1. Secrets rotation policies SHOULD be implemented with automated expiration and renewal mechanisms

---

## ADR 23: Adopt Encrypted Secrets Management in CI/CD Pipeline: Secrets Scoped Minimum

**Policies**:
1. Secrets SHOULD be scoped to the minimum required access level (environment, project, or organization)

---

## ADR 24: Adopt Encrypted Secrets Management in CI/CD Pipeline: Pipeline Configurations Reference

**Policies**:
1. CI/CD pipeline configurations MUST reference secrets by identifier or variable name, not by value

---

## ADR 25: Adopt Encrypted Secrets Management in CI/CD Pipeline: Plaintext Secrets Not

**Policies**:
1. Plaintext secrets MUST NOT be committed to version control repositories or stored in pipeline configuration files

---

## ADR 26: Adopt Encrypted Secrets Management in CI/CD Pipeline: Secrets Credentials Encryption

**Policies**:
1. All secrets, credentials, and encryption keys used in CI/CD pipelines MUST be stored in encrypted form using a dedicated secrets management system

---

## ADR 27: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Teams Use Contract

**Policies**:
1. Teams MAY use contract testing or recorded fixtures to validate mock behavior against real service responses

---

## ADR 28: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Integration Tests That

**Policies**:
1. Integration tests that verify real external service interactions SHOULD be separated from unit tests and run in dedicated CI/CD stages

---

## ADR 29: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Mock Expectations Verify

**Policies**:
1. Mock expectations SHOULD verify that external service methods are called with correct parameters and in the expected order

---

## ADR 30: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Test Doubles Created

**Policies**:
1. Test doubles SHOULD be created using the testing framework's built-in mocking capabilities (e.g., PHPUnit mocks, Mockery) for consistency

---

## ADR 31: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Unit Tests Not

**Policies**:
1. Unit tests MUST NOT require network connectivity, external service availability, or real credentials to execute successfully

---

## ADR 32: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Mock Objects Simulate

**Policies**:
1. Mock objects MUST simulate both success and failure scenarios for external service calls to ensure comprehensive error handling coverage

---

## ADR 33: Adopt Mock-Based Unit Testing for External Service Dependencies in CI/CD Pipeline: Unit Tests Services

**Policies**:
1. Unit tests for services that interact with external APIs or network resources MUST use mocks, stubs, or fakes instead of real connections

---

## ADR 34: Adopt Laravel Fortify for Authentication Action Standardization: Controllers Delegate Domain

**Policies**:
1. Controllers MAY delegate to domain services or Fortify actions based on the complexity and domain-specificity of the operation

---

## ADR 35: Adopt Laravel Fortify for Authentication Action Standardization: Authentication Action Classes

**Policies**:
1. Authentication action classes MUST NOT contain presentation logic (views, redirects, session management) to maintain separation between authentication logic and deployment target concerns

---

## ADR 36: Adopt Laravel Fortify for Authentication Action Standardization: Feature Tests Authentication

**Policies**:
1. Feature tests for authentication operations SHOULD verify behavior independently of presentation layer to ensure deployment target flexibility

---

## ADR 37: Adopt Laravel Fortify for Authentication Action Standardization: Authentication Actions Stateless

**Policies**:
1. Authentication actions SHOULD be stateless and idempotent where possible to support horizontal scaling and API-first deployment patterns

---

## ADR 38: Adopt Laravel Fortify for Authentication Action Standardization: Password Validation Hashing

**Policies**:
1. Password validation and hashing operations MUST use Laravel's Hash facade and validation rules to ensure consistent security standards across all deployment targets

---

## ADR 39: Adopt Laravel Fortify for Authentication Action Standardization: Domain Specific User

**Policies**:
1. Domain-specific user management services (CreateAccount, AcceptInvitation, CancelAccount) MUST be implemented as dedicated service classes within their respective domain boundaries

---

## ADR 40: Adopt Laravel Fortify for Authentication Action Standardization: Authentication Actions Password

**Policies**:
1. All authentication actions (password reset, password update, user creation) MUST be implemented as Laravel Fortify action classes in the app/Actions/Fortify namespace

---

## ADR 41: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Deployment Targets Include

**Policies**:
1. Deployment targets MAY include containerized environments (Docker) or traditional LAMP/LEMP stacks as long as PHP runtime requirements are satisfied

---

## ADR 42: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Authentication Security Critical

**Policies**:
1. Authentication and security-critical operations (password reset, user management) MUST execute within the PHP runtime using Laravel's built-in security features

---

## ADR 43: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Development Production Environments

**Policies**:
1. Development and production environments SHOULD maintain PHP version parity to minimize deployment-related issues

---

## ADR 44: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Application Servers Use

**Policies**:
1. Application servers SHOULD use PHP-FPM or similar process managers for optimal performance and resource management

---

## ADR 45: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Php Extensions Required

**Policies**:
1. PHP extensions required by Laravel (OpenSSL, PDO, Mbstring, Tokenizer, XML, Ctype, JSON, BCMath) MUST be available in the deployment target

---

## ADR 46: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Deployment Environment Provide

**Policies**:
1. The deployment environment MUST provide PHP runtime version compatible with Laravel framework requirements (PHP 8.0 or higher recommended)

---

## ADR 47: Adopt PHP as Primary Backend Language for Laravel-Based Web Applications: Backend Application Code

**Policies**:
1. All backend application code MUST be written in PHP to ensure consistent runtime environment and deployment target compatibility

---

## ADR 48: Standardize Laravel Fortify for Authentication Runtime: Domain Services Not

**Policies**:
1. Domain services MUST NOT implement custom password hashing, validation, or authentication logic that bypasses Fortify

---

## ADR 49: Standardize Laravel Fortify for Authentication Runtime: Account Lifecycle Operations

**Policies**:
1. Account lifecycle operations (creation, cancellation, invitation acceptance) SHOULD integrate with Fortify's authentication context when user credentials are involved

---

## ADR 50: Standardize Laravel Fortify for Authentication Runtime: Password Validation Hashing

**Policies**:
1. Password validation and hashing MUST be handled exclusively by Fortify's built-in mechanisms

---

## ADR 51: Standardize Laravel Fortify for Authentication Runtime: Feature Tests Authentication

**Policies**:
1. Feature tests for authentication flows SHOULD verify Fortify integration behavior to ensure runtime compatibility

---

## ADR 52: Standardize Laravel Fortify for Authentication Runtime: Domain Services That

**Policies**:
1. Domain services that require authentication operations MUST delegate to Fortify actions rather than implementing authentication logic directly

---

## ADR 53: Standardize Laravel Fortify for Authentication Runtime: Authentication Actions Implemented

**Policies**:
1. Authentication actions MUST be implemented in the app/Actions/Fortify namespace following Fortify's action contract pattern

---

## ADR 54: Standardize Laravel Fortify for Authentication Runtime: Authentication Operations Password

**Policies**:
1. All authentication operations (password reset, password update, account creation) MUST use Laravel Fortify as the core authentication runtime library

---

## ADR 55: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Integration Modules Include

**Policies**:
1. Integration modules MAY include utility classes for protocol-specific operations (e.g., Services/Utils/Dav) when needed for complex transformations

---

## ADR 56: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Core Domain Entities

**Policies**:
1. Core domain entities and business logic MUST NOT directly depend on external protocol implementation classes or libraries

---

## ADR 57: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Viewhelper Classes Providing

**Policies**:
1. ViewHelper classes providing external API functionality MUST reside in Web/ViewHelpers directories within their respective domain modules

---

## ADR 58: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Resource Handler Classes

**Policies**:
1. Resource handler classes (e.g., ImportResource, ImportVCardResource) SHOULD be used to manage external data import/export operations with clear single responsibilities

---

## ADR 59: Adopt Domain-Driven Module Boundaries with External API Integration Layers: External Specific Exceptions

**Policies**:
1. External API-specific exceptions SHOULD be defined within the integration module (e.g., DavServerNotCompliantException) to provide clear error boundaries

---

## ADR 60: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Backend Interfaces External

**Policies**:
1. Backend interfaces for external protocols MUST be defined as contracts (e.g., IDAVBackend) to enable multiple implementations and testing

---

## ADR 61: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Data Transfer Between

**Policies**:
1. Data transfer between external APIs and domain logic MUST use dedicated DTO (Data Transfer Object) classes located in Services/Utils/Model directories

---

## ADR 62: Adopt Domain-Driven Module Boundaries with External API Integration Layers: Each External Integration

**Policies**:
1. Each external API integration MUST provide a dedicated client service layer (e.g., DavClient/Services) that encapsulates all protocol-specific communication logic

---

## ADR 63: Adopt Domain-Driven Module Boundaries with External API Integration Layers: External Integrations Organized

**Policies**:
1. External API integrations MUST be organized within domain-specific modules following the pattern: app/Domains/{DomainName}/{IntegrationName}/

---

## ADR 64: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Applications Customize Fortify

**Policies**:
1. Applications MAY customize Fortify's default behavior by providing custom Action implementations

---

## ADR 65: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Authentication Logic Not

**Policies**:
1. Authentication logic MUST NOT be duplicated outside of Fortify Actions

---

## ADR 66: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Services That Handle

**Policies**:
1. Services that handle user data SHOULD leverage validated data from Fortify Actions rather than implementing separate validation logic

---

## ADR 67: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Input Validation Rules

**Policies**:
1. Input validation rules for user data MUST be centralized within their respective Fortify Action classes

---

## ADR 68: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Custom Fortify Actions

**Policies**:
1. Custom Fortify Actions SHOULD extend or implement Fortify's action contracts to maintain consistency with the framework

---

## ADR 69: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Fortify Actions Registered

**Policies**:
1. Fortify Actions MUST be registered and configured in FortifyServiceProvider

---

## ADR 70: Adopt Laravel Fortify for Authentication with Centralized Input Validation: User Input Authentication

**Policies**:
1. All user input in authentication flows MUST be validated using Laravel's validation rules before processing

---

## ADR 71: Adopt Laravel Fortify for Authentication with Centralized Input Validation: Authentication Operations Registration

**Policies**:
1. All authentication operations (registration, login, password reset, profile updates) MUST be implemented using Laravel Fortify Actions

---

## ADR 72: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Viewhelpers Integrate Dav

**Policies**:
1. ViewHelpers MAY integrate DAV synchronization status and controls into user interface components for vault and personalization features

---

## ADR 73: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Import Operations Provide

**Policies**:
1. Import operations SHOULD provide separate resource handlers for generic DAV imports and vCard-specific imports

---

## ADR 74: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Dav Client Services

**Policies**:
1. DAV client services SHOULD be organized under dedicated DavClient namespace to separate external integration concerns from core domain logic

---

## ADR 75: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Non Compliant Dav

**Policies**:
1. Non-compliant DAV servers MUST be handled with specific exceptions (DavServerNotCompliantException) to provide clear error diagnostics

---

## ADR 76: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Contact Operations Create

**Policies**:
1. Contact operations (create, update, delete) with external systems MUST use structured DTOs (ContactDto, ContactDeleteDto) to encapsulate data transfer

---

## ADR 77: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Dav Backend Implementations

**Policies**:
1. DAV backend implementations MUST implement the IDAVBackend interface to ensure consistent protocol handling

---

## ADR 78: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: Contact Data Interchange

**Policies**:
1. Contact data interchange with external systems MUST use vCard format for import and export operations

---

## ADR 79: Adopt CardDAV/WebDAV Protocol for External Contact Synchronization: External Contact Synchronization

**Policies**:
1. All external contact synchronization MUST use CardDAV/WebDAV protocols as the standard integration mechanism

---

## ADR 80: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Domain Services Implement

**Policies**:
1. Domain services MAY implement additional validation layers for VCard data to ensure compliance with RFC 6350 specifications

---

## ADR 81: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Viewhelper Classes Used

**Policies**:
1. ViewHelper classes SHOULD be used to prepare domain data for presentation layers without exposing internal domain logic

---

## ADR 82: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Import Export Operations

**Policies**:
1. Import and export operations SHOULD be separated into distinct resource classes (ImportResource, ImportVCardResource) following single responsibility principle

---

## ADR 83: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Non Compliant Dav

**Policies**:
1. Non-compliant DAV server behaviors MUST be handled through explicit exception types (e.g., DavServerNotCompliantException) with clear error messaging

---

## ADR 84: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Dav Backend Implementations

**Policies**:
1. DAV backend implementations MUST implement defined interface contracts (e.g., IDAVBackend) to enable testability and substitutability

---

## ADR 85: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: Data Transfer Between

**Policies**:
1. Data transfer between external DAV systems and internal domains MUST use dedicated DTO objects (ContactDto, ContactDeleteDto) to enforce boundary isolation

---

## ADR 86: Adopt Domain-Driven DAV/CardDAV Integration Pattern for External Contact Synchronization: External Dav Carddav

**Policies**:
1. External DAV/CardDAV integrations MUST be encapsulated within domain-specific service layers (e.g., Contact domain DavClient services)

---

## ADR 87: Standardize Password Hashing for Authentication Operations: Test Suites Verify

**Policies**:
1. Test suites SHOULD verify password hashing behavior in authentication feature tests

---

## ADR 88: Standardize Password Hashing for Authentication Operations: Password Validation Rules

**Policies**:
1. Password validation rules MUST be enforced before hashing (minimum length, complexity requirements)

---

## ADR 89: Standardize Password Hashing for Authentication Operations: Password Hashing Logic

**Policies**:
1. Password hashing logic SHOULD be centralized in dedicated service methods or use framework-provided mechanisms rather than inline implementations

---

## ADR 90: Standardize Password Hashing for Authentication Operations: Password Update Operations

**Policies**:
1. Password update operations (reset, change, initial creation) MUST apply the same hashing strategy consistently

---

## ADR 91: Standardize Password Hashing for Authentication Operations: Plain Text Passwords

**Policies**:
1. Plain-text passwords MUST NOT be stored in the database or logged in any application logs

---

## ADR 92: Standardize Password Hashing for Authentication Operations: Password Hashing Occur

**Policies**:
1. Password hashing MUST occur before persisting user credentials to the database in all authentication workflows

---

## ADR 93: Standardize Password Hashing for Authentication Operations: Password Storage Operations

**Policies**:
1. All password storage operations MUST use Laravel's Hash facade or bcrypt hashing algorithm with appropriate cost factors

---

## ADR 94: Standardize External API Integration with DAV Protocol and DTO Pattern: External Integrations Implement

**Policies**:
1. External API integrations SHOULD implement logging capabilities using traits (e.g., Loggable) for consistent observability across API interactions

---

## ADR 95: Standardize External API Integration with DAV Protocol and DTO Pattern: Permission Validation External

**Policies**:
1. Permission validation for external API operations MUST throw specific permission exceptions (NotEnoughPermissionException) rather than generic authorization errors

---

## ADR 96: Standardize External API Integration with DAV Protocol and DTO Pattern: Viewhelper Classes Used

**Policies**:
1. ViewHelper classes SHOULD be used to prepare data for external API responses, separating presentation logic from business logic

---

## ADR 97: Standardize External API Integration with DAV Protocol and DTO Pattern: External Clients Implement

**Policies**:
1. External API clients SHOULD implement compliance validation to detect and handle non-compliant external servers gracefully

---

## ADR 98: Standardize External API Integration with DAV Protocol and DTO Pattern: Resource Import Operations

**Policies**:
1. Resource import operations from external APIs MUST implement dedicated resource classes (e.g., ImportResource, ImportVCardResource) that handle protocol-specific data transformation

---

## ADR 99: Standardize External API Integration with DAV Protocol and DTO Pattern: External Integrations Define

**Policies**:
1. External API integrations MUST define domain-specific exception types that extend base exception classes and provide meaningful error context for API-specific failures

---

## ADR 100: Standardize External API Integration with DAV Protocol and DTO Pattern: Protocol Specific Operations

**Policies**:
1. Protocol-specific operations MUST be abstracted behind interface contracts (e.g., IDAVBackend) to enable multiple implementations and improve testability

---

## ADR 101: Standardize External API Integration with DAV Protocol and DTO Pattern: External Integrations Use

**Policies**:
1. External API integrations MUST use Data Transfer Objects (DTOs) to represent external data structures and maintain clear boundaries between external formats and internal domain models

---

## ADR 102: Use Laravel Hash Facade for Password Credential Storage: Applications Implement Automatic

**Policies**:
1. Applications MAY implement automatic password rehashing on login if the configured algorithm or work factor changes

---

## ADR 103: Use Laravel Hash Facade for Password Credential Storage: Hash Facade Configuration

**Policies**:
1. The Hash facade configuration SHOULD use bcrypt or argon2id algorithms with framework-recommended work factors

---

## ADR 104: Use Laravel Hash Facade for Password Credential Storage: Password Hashing Operations

**Policies**:
1. Password hashing operations SHOULD be performed immediately before database persistence to minimize plain-text exposure in memory

---

## ADR 105: Use Laravel Hash Facade for Password Credential Storage: Password Verification Use

**Policies**:
1. Password verification MUST use Hash::check() to compare plain-text input against stored hashes

---

## ADR 106: Use Laravel Hash Facade for Password Credential Storage: Plain Text Passwords

**Policies**:
1. Plain-text passwords MUST NOT be stored in any persistent storage including databases, logs, or cache

---

## ADR 107: Use Laravel Hash Facade for Password Credential Storage: Password Hashing Occur

**Policies**:
1. Password hashing MUST occur in service layer classes or Fortify action classes, never in controllers or views

---

## ADR 108: Use Laravel Hash Facade for Password Credential Storage: Password Credentials Hashed

**Policies**:
1. All password credentials MUST be hashed using Laravel's Hash facade before storage in the database

---

## ADR 109: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Implement Versioning

**Policies**:
1. Public APIs MAY implement versioning strategies (URL path, header-based, or content negotiation) when backward compatibility cannot be maintained

---

## ADR 110: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Contracts Not

**Policies**:
1. Public API contracts SHOULD NOT expose internal domain models directly; always use DTOs or resource representations

---

## ADR 111: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Components Implement

**Policies**:
1. All public API components MUST implement logging through standardized traits or interfaces (e.g., Loggable) for observability and debugging

---

## ADR 112: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: External Service Integrations

**Policies**:
1. External service integrations SHOULD implement service-specific exception types (e.g., DavServerNotCompliantException) to distinguish integration failures from application errors

---

## ADR 113: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Contracts Include

**Policies**:
1. Public API contracts SHOULD include ViewHelper classes for presentation layer concerns, separating data transformation from business logic

---

## ADR 114: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Throw Domain

**Policies**:
1. Public APIs MUST throw domain-specific exceptions (extending base exception classes) for all error conditions, with descriptive messages and appropriate HTTP status codes

---

## ADR 115: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Data Crossing Public

**Policies**:
1. Data crossing public API boundaries MUST be encapsulated in dedicated Data Transfer Objects (DTOs) with clearly defined properties and validation rules

---

## ADR 116: Standardize Public API Contract Design with Interface-Based DTOs and Exception Handling: Public Endpoints External

**Policies**:
1. All public API endpoints and external integration points MUST define explicit interface contracts (e.g., IDAVBackend) that declare method signatures, parameters, and return types

---

## ADR 117: Standardize Exception and Logging Formatting for External API Responses: Exception Classes Include

**Policies**:
1. Exception classes MAY include additional domain-specific fields in the formatted response if they enhance client-side error handling

---

## ADR 118: Standardize Exception and Logging Formatting for External API Responses: Exception Formatters Not

**Policies**:
1. Exception formatters MUST NOT expose internal system details, stack traces, or sensitive data in external API responses

---

## ADR 119: Standardize Exception and Logging Formatting for External API Responses: Formatted Error Responses

**Policies**:
1. Formatted error responses SHOULD follow a standard JSON schema that is versioned and documented in API specifications

---

## ADR 120: Standardize Exception and Logging Formatting for External API Responses: Exception Formatters Include

**Policies**:
1. Exception formatters SHOULD include contextual metadata (e.g., resource IDs, user context) when available without exposing sensitive information

---

## ADR 121: Standardize Exception and Logging Formatting for External API Responses: Logging Utilities Such

**Policies**:
1. Logging utilities (such as Loggable trait) MUST use the same formatting pattern as exception handlers to ensure consistency across error tracking and API responses

---

## ADR 122: Standardize Exception and Logging Formatting for External API Responses: Exception Formatters Include

**Policies**:
1. Exception formatters MUST include at minimum: error code, human-readable message, HTTP status code, and timestamp

---

## ADR 123: Standardize Exception and Logging Formatting for External API Responses: Exception Classes Exposed

**Policies**:
1. All exception classes exposed through external APIs MUST implement a consistent formatter interface or trait that standardizes error response structure

---

## ADR 124: Adopt Quality Gates Pattern for Domain Service Layer Validation: Domain Services Not

**Policies**:
1. Domain services MUST NOT assume data validity without explicit validation, even when receiving data from internal components

---

## ADR 125: Adopt Quality Gates Pattern for Domain Service Layer Validation: Quality Gates Implemented

**Policies**:
1. Quality gates MAY be implemented as reusable validator classes or traits when validation logic is shared across multiple services

---

## ADR 126: Adopt Quality Gates Pattern for Domain Service Layer Validation: Synchronization Services That

**Policies**:
1. Synchronization services that reconcile external data sources SHOULD implement quality gates to validate data consistency before persisting changes

---

## ADR 127: Adopt Quality Gates Pattern for Domain Service Layer Validation: Controllers Receiving Webhook

**Policies**:
1. Controllers receiving webhook or external API data SHOULD implement quality gates to verify payload structure and authentication before delegating to domain services

---

## ADR 128: Adopt Quality Gates Pattern for Domain Service Layer Validation: Quality Gate Failures

**Policies**:
1. Quality gate failures SHOULD throw typed exceptions that clearly indicate the validation failure reason and affected data element

---

## ADR 129: Adopt Quality Gates Pattern for Domain Service Layer Validation: View Helpers That

**Policies**:
1. View helpers that transform domain data for presentation MUST validate the completeness and structure of input data before transformation

---

## ADR 130: Adopt Quality Gates Pattern for Domain Service Layer Validation: Quality Gates Validate

**Policies**:
1. Quality gates MUST validate data type correctness, required field presence, and business rule constraints at the earliest possible point in the execution flow

---

## ADR 131: Adopt Quality Gates Pattern for Domain Service Layer Validation: Domain Service Methods

**Policies**:
1. All domain service methods that accept external input or cross-domain data MUST implement quality gate validation before processing business logic

---

## ADR 132: Standardize Logging with Laravel Log Facade in DAV and Job Components: Components Use Dedicated

**Policies**:
1. Components MAY use dedicated log channels for DAV operations to enable separate log routing and retention policies

---

## ADR 133: Standardize Logging with Laravel Log Facade in DAV and Job Components: Synchronization Services Use

**Policies**:
1. Synchronization services SHOULD use appropriate log levels: debug for routine operations, info for significant events, warning for recoverable issues, error for failures

---

## ADR 134: Standardize Logging with Laravel Log Facade in DAV and Job Components: Log Statements Include

**Policies**:
1. Log statements SHOULD include structured context arrays with relevant identifiers (contact_id, addressbook_id, subscription_id) to enable log aggregation and filtering

---

## ADR 135: Standardize Logging with Laravel Log Facade in DAV and Job Components: Console Commands Performing

**Policies**:
1. Console commands performing setup or subscription operations SHOULD log progress milestones and completion status for operational visibility

---

## ADR 136: Standardize Logging with Laravel Log Facade in DAV and Job Components: Davclient Service Classes

**Policies**:
1. DavClient service classes MUST log all external HTTP requests and responses at appropriate log levels (debug for success, warning/error for failures)

---

## ADR 137: Standardize Logging with Laravel Log Facade in DAV and Job Components: Background Jobs Handling

**Policies**:
1. Background jobs handling VCard/VCalendar operations MUST log job start, completion, and failure events with contextual data including resource identifiers

---

## ADR 138: Standardize Logging with Laravel Log Facade in DAV and Job Components: Dav Backend Implementations

**Policies**:
1. All DAV backend implementations (CalDAV, CardDAV) MUST use Laravel's Log facade for recording synchronization events, errors, and state transitions

---

## ADR 139: Enforce Authorization Checks at Controller Entry Points: Applications Use Framework

**Policies**:
1. Applications MAY use framework-provided authorization middleware (e.g., Laravel policies, gates) to standardize enforcement patterns

---

## ADR 140: Enforce Authorization Checks at Controller Entry Points: Controllers Not Delegate

**Policies**:
1. Controllers MUST NOT delegate authorization responsibility solely to the frontend or client-side validation

---

## ADR 141: Enforce Authorization Checks at Controller Entry Points: Authorization Logic Centralized

**Policies**:
1. Authorization logic SHOULD be centralized in reusable authorization service classes or middleware rather than duplicated across controllers

---

## ADR 142: Enforce Authorization Checks at Controller Entry Points: Services That Can

**Policies**:
1. Services that can be invoked from multiple entry points SHOULD implement their own authorization checks to ensure defense-in-depth

---

## ADR 143: Enforce Authorization Checks at Controller Entry Points: Authorization Checks Validate

**Policies**:
1. Authorization checks MUST validate user permissions against the specific resource being accessed, not just general role-based permissions

---

## ADR 144: Enforce Authorization Checks at Controller Entry Points: Authorization Enforcement Points

**Policies**:
1. Authorization enforcement points MUST be implemented at the earliest possible boundary (controller entry point or service layer) to fail fast on unauthorized requests

---

## ADR 145: Enforce Authorization Checks at Controller Entry Points: Controller Methods That

**Policies**:
1. All controller methods that access or modify domain resources MUST perform authorization checks before executing business logic

---

## ADR 146: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Helper Classes Provide

**Policies**:
1. Helper classes MAY provide utility functions for common datastore query patterns, but MUST remain stateless and reusable

---

## ADR 147: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Background Jobs That

**Policies**:
1. Background jobs that access datastores MUST implement proper error handling and transaction management

---

## ADR 148: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: View Helpers Retrieve

**Policies**:
1. View helpers SHOULD retrieve data through service layer methods rather than directly querying datastores when business logic is involved

---

## ADR 149: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Datastore Interactions Use

**Policies**:
1. All datastore interactions MUST use the application's configured primary database connection and MUST NOT hardcode connection strings

---

## ADR 150: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Data Access Logic

**Policies**:
1. Data access logic SHOULD be encapsulated in dedicated repository classes or service methods rather than scattered across view helpers

---

## ADR 151: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Direct Sql Queries

**Policies**:
1. Direct SQL queries MUST NOT be used in domain services or view helpers unless explicitly justified and documented for performance reasons

---

## ADR 152: Standardize Primary Datastore Access Patterns in Domain Services and Helpers: Domain Services View

**Policies**:
1. All domain services, view helpers, and background jobs MUST access primary datastores through well-defined repository patterns or ORM abstractions (e.g., Eloquent models)

---

## ADR 153: Adopt HTTP Client Libraries for External API Integration: Projects Implement Custom

**Policies**:
1. Projects MAY implement custom HTTP client wrappers for domain-specific requirements while maintaining the underlying library usage

---

## ADR 154: Adopt HTTP Client Libraries for External API Integration: Http Client Configurations

**Policies**:
1. HTTP client configurations SHOULD be externalized to configuration files or environment variables for different environments

---

## ADR 155: Adopt HTTP Client Libraries for External API Integration: External Integrations Wrapped

**Policies**:
1. External API integrations SHOULD be wrapped in service classes that encapsulate the HTTP client library usage

---

## ADR 156: Adopt HTTP Client Libraries for External API Integration: Http Client Implementations

**Policies**:
1. HTTP client implementations SHOULD support middleware patterns for cross-cutting concerns like logging, retry logic, and authentication

---

## ADR 157: Adopt HTTP Client Libraries for External API Integration: Vcard Vcalendar Data

**Policies**:
1. vCard and vCalendar data processing MUST use specialized parsing libraries (e.g., Sabre VObject) rather than custom string manipulation

---

## ADR 158: Adopt HTTP Client Libraries for External API Integration: Dav Caldav Carddav

**Policies**:
1. DAV/CalDAV/CardDAV protocol interactions MUST use Sabre DAV client libraries or equivalent standards-compliant implementations

---

## ADR 159: Adopt HTTP Client Libraries for External API Integration: Oauth Authentication Flows

**Policies**:
1. OAuth authentication flows MUST utilize Laravel Socialite or equivalent OAuth client libraries

---

## ADR 160: Adopt HTTP Client Libraries for External API Integration: External Http Communications

**Policies**:
1. All external HTTP API communications MUST use established HTTP client libraries rather than raw socket or curl implementations

---

## ADR 161: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Not Contain

**Policies**:
1. Models MUST NOT contain business logic beyond data access concerns; complex business rules belong in service classes or domain objects

---

## ADR 162: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Custom

**Policies**:
1. Models MAY define custom attributes using accessors and mutators for computed or transformed data

---

## ADR 163: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Complex Query Logic

**Policies**:
1. Complex query logic SHOULD be encapsulated in model scopes or query builder methods rather than scattered throughout controllers

---

## ADR 164: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Declare Fillable

**Policies**:
1. Models SHOULD declare fillable or guarded properties to control mass assignment protection

---

## ADR 165: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Explicit

**Policies**:
1. Models SHOULD define explicit relationships using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.) rather than manual joins

---

## ADR 166: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Each Model Class

**Policies**:
1. Each model class MUST correspond to a single database table following Laravel naming conventions (singular PascalCase class name to plural snake_case table name)

---

## ADR 167: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Model Classes Placed

**Policies**:
1. Model classes MUST be placed in the app/Models namespace and directory structure

---

## ADR 168: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Domain Entities That

**Policies**:
1. All domain entities that map to database tables MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 169: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Query

**Policies**:
1. Models MAY define query scopes for reusable query logic specific to the entity

---

## ADR 170: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Include Accessor

**Policies**:
1. Models MAY include accessor and mutator methods for computed attributes or attribute transformation

---

## ADR 171: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Business Logic Not

**Policies**:
1. Business logic MUST NOT be tightly coupled to model classes; models should focus on data representation and persistence concerns

---

## ADR 172: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Casts

**Policies**:
1. Models SHOULD define casts for attributes that require type conversion (dates, JSON, booleans, etc.)

---

## ADR 173: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Relationships Between Entities

**Policies**:
1. Relationships between entities SHOULD be defined using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.)

---

## ADR 174: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Models Define Their

**Policies**:
1. Models SHOULD define their fillable or guarded properties to control mass assignment protection

---

## ADR 175: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Each Model Class

**Policies**:
1. Each model class MUST correspond to a single database table with clear naming conventions (singular model name, plural table name by default)

---

## ADR 176: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Model Classes Placed

**Policies**:
1. Model classes MUST be placed in the app/Models directory following Laravel namespace conventions

---

## ADR 177: Adopt Eloquent ORM Models as Standard Data Modeling Pattern: Database Backed Domain

**Policies**:
1. All database-backed domain entities MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 178: Adopt Eloquent ORM Models as Standard Data Access Layer: Models Define Custom

**Policies**:
1. Models MAY define custom query scopes for reusable query logic specific to that entity

---

## ADR 179: Adopt Eloquent ORM Models as Standard Data Access Layer: Controllers Services Not

**Policies**:
1. Controllers and services MUST NOT bypass models by executing raw SQL queries directly for standard CRUD operations

---

## ADR 180: Adopt Eloquent ORM Models as Standard Data Access Layer: Model Specific Business

**Policies**:
1. Model-specific business logic and computed attributes SHOULD be encapsulated within the model class using accessors, mutators, and custom methods

---

## ADR 181: Adopt Eloquent ORM Models as Standard Data Access Layer: Eloquent Relationships Hasmany

**Policies**:
1. Eloquent relationships (hasMany, belongsTo, belongsToMany, etc.) SHOULD be defined as methods within the model class rather than using manual joins

---

## ADR 182: Adopt Eloquent ORM Models as Standard Data Access Layer: Models Define Their

**Policies**:
1. Models SHOULD define their fillable or guarded properties to control mass assignment protection

---

## ADR 183: Adopt Eloquent ORM Models as Standard Data Access Layer: Each Model Correspond

**Policies**:
1. Each model MUST correspond to a single database table with the table name following Laravel's naming conventions (plural, snake_case)

---

## ADR 184: Adopt Eloquent ORM Models as Standard Data Access Layer: Model Classes Placed

**Policies**:
1. Model classes MUST be placed in the app/Models namespace following Laravel's standard directory structure

---

## ADR 185: Adopt Eloquent ORM Models as Standard Data Access Layer: Database Backed Entities

**Policies**:
1. All database-backed entities MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 186: Adopt Inertia.js with SSR for Frontend-Backend Integration: Applications Implement Custom

**Policies**:
1. Applications MAY implement custom stateful request handling (e.g., EnsureDavRequestsAreStateful) to support specialized protocols while maintaining Inertia compatibility

---

## ADR 187: Adopt Inertia.js with SSR for Frontend-Backend Integration: Feature Gating Middleware

**Policies**:
1. Feature-gating middleware (e.g., EnsureSignupIsEnabled) SHOULD integrate with Inertia's response cycle to provide seamless redirects without breaking SPA navigation

---

## ADR 188: Adopt Inertia.js with SSR for Frontend-Backend Integration: Javascript Entry Points

**Policies**:
1. JavaScript entry points (app.js, ssr.js) MUST be located in resources/js/ directory following Laravel's standard asset organization

---

## ADR 189: Adopt Inertia.js with SSR for Frontend-Backend Integration: Middleware Handling Stateful

**Policies**:
1. Middleware handling stateful requests SHOULD extend or integrate with Inertia's HandleInertiaRequests middleware to maintain consistent request/response patterns

---

## ADR 190: Adopt Inertia.js with SSR for Frontend-Backend Integration: Custom Middleware Extending

**Policies**:
1. Custom middleware extending Inertia's base middleware MUST be placed in app/Http/Middleware/ and follow the naming convention Ensure[Feature][Condition].php

---

## ADR 191: Adopt Inertia.js with SSR for Frontend-Backend Integration: Server Side Rendering

**Policies**:
1. Server-side rendering (SSR) MUST be implemented using a dedicated ssr.js entry point separate from the client-side app.js entry point

---

## ADR 192: Adopt Inertia.js with SSR for Frontend-Backend Integration: Frontend Backend Integration

**Policies**:
1. All frontend-backend integration MUST use Inertia.js as the primary communication layer between Laravel controllers and JavaScript components

---

## ADR 193: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Models Define Custom

**Policies**:
1. Models MAY define custom query scopes to encapsulate common query patterns

---

## ADR 194: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Models Define Relationships

**Policies**:
1. Models SHOULD define relationships using Eloquent relationship methods (hasMany, belongsTo, etc.) rather than manual joins

---

## ADR 195: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Business Logic Not

**Policies**:
1. Business logic MUST NOT bypass models to access database directly via raw queries except for performance-critical operations with documented justification

---

## ADR 196: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Models Define Fillable

**Policies**:
1. Models SHOULD define $fillable or $guarded properties to control mass assignment protection

---

## ADR 197: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Models Use Explicit

**Policies**:
1. Models SHOULD use explicit table name declarations via the $table property when the table name does not follow Laravel naming conventions

---

## ADR 198: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Models Define Their

**Policies**:
1. Models MUST define their public API contracts including fillable attributes, relationships, and accessor/mutator methods

---

## ADR 199: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Model Classes Placed

**Policies**:
1. Model classes MUST be placed in the app/Models namespace following Laravel conventions

---

## ADR 200: Standardize Eloquent Models as Primary Data Access Layer with Public API Contracts: Database Entities Represented

**Policies**:
1. All database entities MUST be represented by Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 201: Adopt Eloquent ORM Models as Standard Data Access Layer: Business Logic Not

**Policies**:
1. Business logic MUST NOT be tightly coupled to model classes; models should focus on data representation and persistence

---

## ADR 202: Adopt Eloquent ORM Models as Standard Data Access Layer: Models Define Custom

**Policies**:
1. Models MAY define custom query scopes, accessors, and mutators for domain-specific data manipulation

---

## ADR 203: Adopt Eloquent ORM Models as Standard Data Access Layer: Models Use Type

**Policies**:
1. Models SHOULD use type casting via the $casts property for automatic attribute transformation

---

## ADR 204: Adopt Eloquent ORM Models as Standard Data Access Layer: Relationships Between Entities

**Policies**:
1. Relationships between entities SHOULD be defined using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.)

---

## ADR 205: Adopt Eloquent ORM Models as Standard Data Access Layer: Models Define Fillable

**Policies**:
1. Models SHOULD define fillable or guarded properties to control mass assignment protection

---

## ADR 206: Adopt Eloquent ORM Models as Standard Data Access Layer: Each Model Correspond

**Policies**:
1. Each model MUST correspond to a single database table with explicit or conventional table name mapping

---

## ADR 207: Adopt Eloquent ORM Models as Standard Data Access Layer: Model Classes Placed

**Policies**:
1. Model classes MUST be placed in the app/Models namespace following Laravel conventions

---

## ADR 208: Adopt Eloquent ORM Models as Standard Data Access Layer: Database Entities Represented

**Policies**:
1. All database entities MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 209: Adopt Modular Architecture with Factory-Based Component Generation: Modules Define Their

**Policies**:
1. Modules MAY define their own factory classes for complex nested structures (e.g., ModuleRow within Module)

---

## ADR 210: Adopt Modular Architecture with Factory-Based Component Generation: Scheduled Tasks Defined

**Policies**:
1. Scheduled tasks MUST be defined in a centralized Schedule class that extends the framework's scheduling infrastructure

---

## ADR 211: Adopt Modular Architecture with Factory-Based Component Generation: Module Initialization Logic

**Policies**:
1. Module initialization logic SHOULD be encapsulated in dedicated setup commands (e.g., SetupApplication, SetupDocumentation) rather than scattered across the codebase

---

## ADR 212: Adopt Modular Architecture with Factory-Based Component Generation: View Helpers Isolated

**Policies**:
1. View helpers SHOULD be isolated in dedicated ViewHelper classes within the Web layer of their respective domains

---

## ADR 213: Adopt Modular Architecture with Factory-Based Component Generation: Console Commands Application

**Policies**:
1. Console commands for application setup and initialization MUST be implemented in app/Console/Commands/ and follow the Command pattern

---

## ADR 214: Adopt Modular Architecture with Factory-Based Component Generation: Database Entity Factories

**Policies**:
1. Database entity factories MUST extend the framework's base Factory class and be placed in database/factories/ directory

---

## ADR 215: Adopt Modular Architecture with Factory-Based Component Generation: Domain Modules Organized

**Policies**:
1. All domain modules MUST be organized under a clear namespace hierarchy following the pattern app/Domains/{Domain}/{Subdomain}/{Layer}

---

## ADR 216: Adopt Laravel Migrations as Standard Database Schema Management: Migrations Include Data

**Policies**:
1. Migrations MAY include data seeding operations when necessary for schema-dependent reference data, though seeders are preferred for test data

---

## ADR 217: Adopt Laravel Migrations as Standard Database Schema Management: Migrations Include Appropriate

**Policies**:
1. Migrations SHOULD include appropriate indexes, foreign key constraints, and default values as part of the schema definition

---

## ADR 218: Adopt Laravel Migrations as Standard Database Schema Management: Migration Files Atomic

**Policies**:
1. Migration files SHOULD be atomic, focusing on a single logical schema change to facilitate easier rollback and debugging

---

## ADR 219: Adopt Laravel Migrations as Standard Database Schema Management: Direct Sql Schema

**Policies**:
1. Direct SQL schema modifications MUST NOT be performed on production databases outside of the migration system

---

## ADR 220: Adopt Laravel Migrations as Standard Database Schema Management: Migration Files Use

**Policies**:
1. Migration files MUST use Laravel's Schema Builder API (Schema::create, Schema::table, etc.) rather than raw SQL for database-agnostic operations

---

## ADR 221: Adopt Laravel Migrations as Standard Database Schema Management: Each Migration File

**Policies**:
1. Each migration file MUST implement both up() and down() methods to support forward migration and rollback operations

---

## ADR 222: Adopt Laravel Migrations as Standard Database Schema Management: Migration Files Follow

**Policies**:
1. Migration files MUST follow Laravel's naming convention: YYYY_MM_DD_HHMMSS_descriptive_name.php with timestamps ensuring chronological execution order

---

## ADR 223: Adopt Laravel Migrations as Standard Database Schema Management: Database Schema Changes

**Policies**:
1. All database schema changes MUST be implemented using Laravel migration files stored in the database/migrations directory

---

## ADR 224: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Tests Use Factory

**Policies**:
1. Tests MAY use factory patterns or fixtures for test data generation to improve maintainability

---

## ADR 225: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Test Methods Use

**Policies**:
1. Test methods MUST use descriptive names that clearly indicate the behavior being tested

---

## ADR 226: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Test File Naming

**Policies**:
1. Test file naming SHOULD follow the pattern {ClassName}Test.php matching the class under test

---

## ADR 227: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Test Classes Use

**Policies**:
1. Test classes SHOULD use trait-based helper utilities (e.g., DatabaseTransactions, RefreshDatabase) for shared testing functionality

---

## ADR 228: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Test Classes Extend

**Policies**:
1. Test classes MUST extend PHPUnit\Framework\TestCase or an appropriate base test class

---

## ADR 229: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Unit Tests Organized

**Policies**:
1. Unit tests MUST be organized under the tests/Unit/ directory with subdirectories reflecting the application structure (Models, Helpers, etc.)

---

## ADR 230: Standardize PHPUnit Test Structure with setUp and Trait-Based Helpers: Phpunit Test Classes

**Policies**:
1. All PHPUnit test classes MUST implement a setUp() method for test initialization and dependency preparation

---

## ADR 231: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Domains Contain Additional

**Policies**:
1. Domains MAY contain additional subdirectories for domain-specific concerns such as Events, Repositories, or ValueObjects

---

## ADR 232: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Service Classes Not

**Policies**:
1. Service classes MUST NOT directly handle HTTP concerns such as request parsing or response formatting

---

## ADR 233: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Domain Boundaries Align

**Policies**:
1. Domain boundaries SHOULD align with business capabilities and use cases rather than technical layers

---

## ADR 234: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Controllers Delegate Business

**Policies**:
1. Controllers SHOULD delegate business logic to service classes rather than implementing logic directly

---

## ADR 235: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Service Classes Encapsulate

**Policies**:
1. Service classes MUST encapsulate single business operations with clear, action-oriented names (e.g., RemoveContactFromPost, UpdateJournalMetric)

---

## ADR 236: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Each Domain Separate

**Policies**:
1. Each domain MUST separate concerns into distinct subdirectories: Services for business logic, Web/Controllers for HTTP handling, and Models for data structures

---

## ADR 237: Organize Domain Logic Using Domain-Driven Design Bounded Contexts: Business Logic Organized

**Policies**:
1. Business logic MUST be organized into domain-specific directories under app/Domains/{DomainName}

---

## ADR 238: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Pipelines Leverage Domain

**Policies**:
1. CI/CD pipelines MAY leverage the domain-based directory structure to execute tests in parallel by domain or sub-domain

---

## ADR 239: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Test Directory Root

**Policies**:
1. The test directory root MUST be located at tests/Unit/ for unit tests, with integration and functional tests in separate parallel hierarchies

---

## ADR 240: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Web Concerns Separated

**Policies**:
1. API and Web concerns SHOULD be separated into distinct test directories (Api/Controllers vs Web/ViewHelpers) to enable independent testing strategies

---

## ADR 241: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Tests Organized Architectural

**Policies**:
1. Tests SHOULD be organized by architectural layer (Services, Controllers, ViewHelpers) within each domain to support layer-specific test execution

---

## ADR 242: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Test File Names

**Policies**:
1. Test file names MUST follow the pattern {ClassName}Test.php, where {ClassName} is the exact name of the class under test

---

## ADR 243: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Domain Boundaries Reflected

**Policies**:
1. Domain boundaries MUST be reflected in the test directory structure, with tests organized under their respective domain and sub-domain directories

---

## ADR 244: Adopt Domain-Driven Test Organization with Mirrored Directory Structure: Test Files Organized

**Policies**:
1. Test files MUST be organized in a directory structure that mirrors the production code hierarchy, maintaining a 1:1 correspondence between test and implementation files

---

## ADR 245: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Controllers Use Inertia

**Policies**:
1. Controllers MAY use Inertia's partial reloads to optimize data fetching for specific component updates

---

## ADR 246: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Controllers Not Mix

**Policies**:
1. Controllers MUST NOT mix Inertia responses with traditional view() responses in the same domain context

---

## ADR 247: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Form Submissions Return

**Policies**:
1. Form submissions SHOULD return Inertia responses with appropriate redirect() or back() methods to maintain SPA navigation

---

## ADR 248: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Controllers Use Inertia

**Policies**:
1. Controllers SHOULD use Inertia's lazy loading for expensive data that is not immediately needed on page load

---

## ADR 249: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Data Passed Frontend

**Policies**:
1. All data passed to the frontend MUST be serialized as props in the Inertia response, not through session flash data or view composers

---

## ADR 250: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Controllers Return Inertia

**Policies**:
1. Controllers MUST return Inertia responses using the Inertia::render() method with a component name and props array

---

## ADR 251: Adopt Inertia.js for Server-Driven Single Page Application Rendering: Web Controllers Managejournals

**Policies**:
1. Web controllers in the ManageJournals domain MUST use Inertia.js responses for rendering views instead of traditional Blade templates or JSON API responses

---

## ADR 252: Enforce Public API Contract Testing in CI/CD Pipeline: Teams Implement Contract

**Policies**:
1. Teams MAY implement contract testing frameworks (e.g., Pact, Spring Cloud Contract) for more sophisticated consumer-driven contract testing

---

## ADR 253: Enforce Public API Contract Testing in CI/CD Pipeline: Contract Tests Follow

**Policies**:
1. API contract tests SHOULD follow naming conventions that clearly identify the component under test (e.g., *ControllerTest.php, *ServiceTest.php, *ViewHelperTest.php)

---

## ADR 254: Enforce Public API Contract Testing in CI/CD Pipeline: Breaking Changes Public

**Policies**:
1. Breaking changes to public API contracts MUST cause CI/CD pipeline failures and prevent deployment

---

## ADR 255: Enforce Public API Contract Testing in CI/CD Pipeline: Contract Tests Validate

**Policies**:
1. Contract tests SHOULD validate both successful responses and error conditions to ensure comprehensive API behavior coverage

---

## ADR 256: Enforce Public API Contract Testing in CI/CD Pipeline: Contract Tests Organized

**Policies**:
1. API contract tests SHOULD be organized by domain boundaries (e.g., Settings/ManageTemplates, Settings/ManageUsers) to maintain clear separation of concerns

---

## ADR 257: Enforce Public API Contract Testing in CI/CD Pipeline: Test Coverage Public

**Policies**:
1. Test coverage for public API contracts MUST include all CRUD operations (Create, Read, Update, Delete) where applicable

---

## ADR 258: Enforce Public API Contract Testing in CI/CD Pipeline: Public Contract Tests

**Policies**:
1. Public API contract tests MUST be executed as part of the CI/CD pipeline before any code can be merged to main branches

---

## ADR 259: Enforce Public API Contract Testing in CI/CD Pipeline: Public Endpoints Service

**Policies**:
1. All public API endpoints and service contracts MUST have corresponding unit tests that validate request/response schemas, method signatures, and return types

---

## ADR 260: Adopt Internationalization (i18n) Language Files for Multi-Language Support: Locale Specific Formatting

**Policies**:
1. Locale-specific formatting rules (dates, numbers, currency) MAY be defined in dedicated format.php files per locale

---

## ADR 261: Adopt Internationalization (i18n) Language Files for Multi-Language Support: New Locales Maintain

**Policies**:
1. New locales SHOULD maintain structural parity with existing language files to ensure feature completeness across all supported languages

---

## ADR 262: Adopt Internationalization (i18n) Language Files for Multi-Language Support: Business Logic Code

**Policies**:
1. Business logic code MUST NOT contain hardcoded user-facing strings; all such strings MUST reference translation keys

---

## ADR 263: Adopt Internationalization (i18n) Language Files for Multi-Language Support: Translation Files Use

**Policies**:
1. Translation files SHOULD use PHP array return structures for framework compatibility and easy key-value access

---

## ADR 264: Adopt Internationalization (i18n) Language Files for Multi-Language Support: Each Locale Provide

**Policies**:
1. Each locale MUST provide translation files for core categories: auth, validation, passwords, actions, pagination, http-statuses, and format

---

## ADR 265: Adopt Internationalization (i18n) Language Files for Multi-Language Support: Language Files Organized

**Policies**:
1. Language files MUST be organized by locale code (e.g., lang/en/, lang/hi/, lang/he/, lang/ja/, lang/it/) following ISO 639-1 standards

---

## ADR 266: Adopt Internationalization (i18n) Language Files for Multi-Language Support: User Facing Strings

**Policies**:
1. All user-facing strings MUST be externalized into language-specific resource files organized under a lang/ directory structure

---

## ADR 267: Adopt Domain-Driven Controller Organization for Journal Management: Domains Organize Controllers

**Policies**:
1. Domains MAY organize controllers into further subdirectories if the number of controllers exceeds 10 within a single domain

---

## ADR 268: Adopt Domain-Driven Controller Organization for Journal Management: Related Controllers Handling

**Policies**:
1. Related controllers handling sub-resources SHOULD use composite naming that reflects the parent-child relationship (e.g., PostMetricController, PostSliceOfLifeController)

---

## ADR 269: Adopt Domain-Driven Controller Organization for Journal Management: Controllers Placed Within

**Policies**:
1. Controllers MUST be placed within the Web/Controllers subdirectory of their domain to separate web concerns from other layers

---

## ADR 270: Adopt Domain-Driven Controller Organization for Journal Management: Controller Naming Follow

**Policies**:
1. Controller naming SHOULD follow the pattern {Entity}Controller or {Entity}{Concern}Controller (e.g., JournalController, PostPhotoController)

---

## ADR 271: Adopt Domain-Driven Controller Organization for Journal Management: Each Distinct Entity

**Policies**:
1. Each distinct entity or concern within journal management (journals, posts, photos, metrics, slices of life) MUST have a dedicated controller class

---

## ADR 272: Adopt Domain-Driven Controller Organization for Journal Management: Controllers Handling Journal

**Policies**:
1. Controllers handling journal management features MUST be organized under the app/Domains/Vault/ManageJournals/Web/Controllers namespace

---

## ADR 273: Adopt Domain-Driven Service Layer Pattern for Journal Management: Services Composed Together

**Policies**:
1. Services MAY be composed together to implement complex workflows, but each service should remain independently testable

---

## ADR 274: Adopt Domain-Driven Service Layer Pattern for Journal Management: Domain Operations Organized

**Policies**:
1. Domain operations MUST be organized by subdomain (ManageJournals) with clear namespace boundaries separating Web, Services, and other concerns

---

## ADR 275: Adopt Domain-Driven Service Layer Pattern for Journal Management: Services Handle Transaction

**Policies**:
1. Services SHOULD handle transaction boundaries and data persistence concerns internally, exposing clean interfaces to controllers

---

## ADR 276: Adopt Domain-Driven Service Layer Pattern for Journal Management: Service Class Names

**Policies**:
1. Service class names SHOULD use verb-noun naming convention that clearly describes the operation (e.g., RemoveContactFromPost, IncrementPostReadCounter)

---

## ADR 277: Adopt Domain-Driven Service Layer Pattern for Journal Management: Web Controllers Managejournals

**Policies**:
1. Web controllers in the ManageJournals/Web/Controllers directory MUST delegate business logic to service classes rather than implementing logic directly

---

## ADR 278: Adopt Domain-Driven Service Layer Pattern for Journal Management: Service Classes Follow

**Policies**:
1. Service classes MUST follow single-responsibility principle with one primary operation per class (e.g., CreatePostMetric, DestroySliceOfLife, UpdateJournalMetric)

---

## ADR 279: Adopt Domain-Driven Service Layer Pattern for Journal Management: Business Logic Journal

**Policies**:
1. All business logic for journal management operations MUST be encapsulated in dedicated service classes within the app/Domains/Vault/ManageJournals/Services directory

---

## ADR 280: Organize Test Files by Domain and Feature Modules: Pipelines Implement Domain

**Policies**:
1. CI/CD pipelines MAY implement domain-specific test stages that execute only tests for changed domains

---

## ADR 281: Organize Test Files by Domain and Feature Modules: Test Organization Facilitate

**Policies**:
1. Test organization SHOULD facilitate parallel test execution by allowing independent domain or module test runs

---

## ADR 282: Organize Test Files by Domain and Feature Modules: Domain Boundaries Enforced

**Policies**:
1. Domain boundaries SHOULD be enforced in CI/CD pipelines to enable selective test execution by domain or feature module

---

## ADR 283: Organize Test Files by Domain and Feature Modules: Test Files Maintain

**Policies**:
1. Test files MUST maintain the same subdirectory structure within feature modules as production code (e.g., Services/, Web/ViewHelpers/, Api/Controllers/)

---

## ADR 284: Organize Test Files by Domain and Feature Modules: Test File Names

**Policies**:
1. Test file names MUST append 'Test' suffix to the corresponding production class name (e.g., RemoveModuleFromTemplatePage.php -> RemoveModuleFromTemplatePageTest.php)

---

## ADR 285: Organize Test Files by Domain and Feature Modules: Each Domain Subdirectory

**Policies**:
1. Each domain subdirectory MUST contain feature module subdirectories that mirror the production code organization (e.g., ManageTemplates, ManageUserPreferences, ManageUsers)

---

## ADR 286: Organize Test Files by Domain and Feature Modules: Test Files Organized

**Policies**:
1. Test files MUST be organized under tests/Unit/Domains/ following the same domain structure as production code

---

## ADR 287: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Tests Use Phpunit

**Policies**:
1. Tests MAY use PHPUnit mocking capabilities to isolate dependencies

---

## ADR 288: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Test Suites Executable

**Policies**:
1. Test suites SHOULD be executable in CI/CD pipelines for automated verification

---

## ADR 289: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Unit Tests Focus

**Policies**:
1. Unit tests MUST focus on testing individual components in isolation without external dependencies

---

## ADR 290: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Each Service Class

**Policies**:
1. Each service class, controller, and view helper SHOULD have a corresponding unit test file

---

## ADR 291: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Test Class Files

**Policies**:
1. Test class files MUST follow the naming convention {ClassName}Test.php where {ClassName} is the class under test

---

## ADR 292: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Unit Test Files

**Policies**:
1. Unit test files MUST be placed in tests/Unit/Domains/ directory structure mirroring the application domain hierarchy

---

## ADR 293: Adopt PHPUnit for Unit Testing in Domain-Driven Architecture: Unit Tests Written

**Policies**:
1. All unit tests MUST be written using PHPUnit as the testing framework

---

## ADR 294: Standardize Authentication Middleware for Journal Management Controllers: Individual Route Methods

**Policies**:
1. Individual route methods MAY apply additional authorization checks beyond the base authentication middleware

---

## ADR 295: Standardize Authentication Middleware for Journal Management Controllers: Authentication Configuration Consistent

**Policies**:
1. Authentication configuration SHOULD be consistent across related resource controllers (e.g., Journal and JournalPhoto controllers)

---

## ADR 296: Standardize Authentication Middleware for Journal Management Controllers: Controllers Apply Authentication

**Policies**:
1. Controllers SHOULD apply authentication middleware in the constructor method to ensure all routes are protected by default

---

## ADR 297: Standardize Authentication Middleware for Journal Management Controllers: New Controllers Added

**Policies**:
1. New controllers added to the ManageJournals domain MUST follow the established authentication middleware pattern without deviation

---

## ADR 298: Standardize Authentication Middleware for Journal Management Controllers: Authentication Middleware Configured

**Policies**:
1. Authentication middleware MUST be configured using the same authentication method pattern detected across JournalController, PostController, JournalPhotoController, PostPhotoController, JournalMetricController, PostMetricController, SliceOfLifeController, and PostSliceOfLifeController

---

## ADR 299: Standardize Authentication Middleware for Journal Management Controllers: Controllers Within App

**Policies**:
1. All controllers within app/Domains/Vault/ManageJournals/Web/Controllers MUST apply authentication middleware to protect routes from unauthorized access

---

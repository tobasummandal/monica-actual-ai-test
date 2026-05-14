# Monica AI Development Guidelines

## ADR 1: Domain Services Reused

Domain services MAY be reused across multiple controllers or other services when appropriate

---

## ADR 2: Controllers Placed Web

Controllers SHOULD be placed in Web/Controllers subdirectories within their respective domain feature folders

---

## ADR 3: Service Classes Encapsulate

Service classes SHOULD encapsulate a single business operation or use case to maintain single responsibility principle

---

## ADR 4: Domain Services Organized

Domain services MUST be organized by feature area (e.g., CreateAccount, CancelAccount, ManageUsers) to maintain clear boundaries

---

## ADR 5: Web Controllers Delegate

Web controllers MUST delegate business logic execution to domain service classes rather than implementing logic directly

---

## ADR 6: Business Operations Implemented

Business operations MUST be implemented as dedicated service classes within domain-specific namespaces (e.g., app/Domains/{Domain}/{Feature}/Services/)

---

## ADR 7: Pipelines Run Unit

CI/CD pipelines MAY run unit and feature tests in parallel to optimize build time

---

## ADR 8: Domain Specific Tests

Domain-specific tests SHOULD be organized in subdirectories reflecting the application's domain structure

---

## ADR 9: Test Files Follow

Test files SHOULD follow the naming convention *Test.php to ensure automatic discovery

---

## ADR 10: Unit Tests Run

Unit tests MUST run before feature tests in the CI/CD pipeline to provide fast feedback

---

## ADR 11: Pipelines Execute Both

CI/CD pipelines MUST execute both unit and feature test suites on every commit

---

## ADR 12: Feature Tests Placed

All feature tests MUST be placed in the tests/Feature directory for end-to-end scenario validation

---

## ADR 13: Unit Tests Placed

All unit tests MUST be placed in the tests/Unit directory and organized by domain boundaries

---

## ADR 14: Models Implement Additional

Models MAY implement additional interfaces or traits to support cross-cutting concerns like auditing, soft deletes, or timestamps

---

## ADR 15: Resource Transformation Logic

Resource transformation logic (converting between domain models and external formats) SHOULD be encapsulated within dedicated resource classes

---

## ADR 16: Data Models Follow

Data models MUST follow a consistent naming convention that reflects their domain purpose (e.g., File.php for file entities, VCardResource.php for vCard protocol resources)

---

## ADR 17: Model Classes Organized

Model classes SHOULD be organized by domain context (e.g., Contact, File) to maintain clear bounded contexts

---

## ADR 18: Resource Classes External

Resource classes for external protocol integration (e.g., VCard, VCalendar) MUST be separated from core domain models

---

## ADR 19: Domain Entities Represented

All domain entities MUST be represented by dedicated model classes that encapsulate data structure and basic persistence logic

---

## ADR 20: Teams Use Environment

Teams MAY use environment-specific secret namespaces to isolate development, staging, and production credentials

---

## ADR 21: Pipeline Logs Not

Pipeline logs MUST NOT expose secret values in output, error messages, or debug information

---

## ADR 22: Secrets Rotation Policies

Secrets rotation policies SHOULD be implemented with automated expiration and renewal mechanisms

---

## ADR 23: Secrets Scoped Minimum

Secrets SHOULD be scoped to the minimum required access level (environment, project, or organization)

---

## ADR 24: Pipeline Configurations Reference

CI/CD pipeline configurations MUST reference secrets by identifier or variable name, not by value

---

## ADR 25: Plaintext Secrets Not

Plaintext secrets MUST NOT be committed to version control repositories or stored in pipeline configuration files

---

## ADR 26: Secrets Credentials Encryption

All secrets, credentials, and encryption keys used in CI/CD pipelines MUST be stored in encrypted form using a dedicated secrets management system

---

## ADR 27: Teams Use Contract

Teams MAY use contract testing or recorded fixtures to validate mock behavior against real service responses

---

## ADR 28: Integration Tests That

Integration tests that verify real external service interactions SHOULD be separated from unit tests and run in dedicated CI/CD stages

---

## ADR 29: Mock Expectations Verify

Mock expectations SHOULD verify that external service methods are called with correct parameters and in the expected order

---

## ADR 30: Test Doubles Created

Test doubles SHOULD be created using the testing framework's built-in mocking capabilities (e.g., PHPUnit mocks, Mockery) for consistency

---

## ADR 31: Unit Tests Not

Unit tests MUST NOT require network connectivity, external service availability, or real credentials to execute successfully

---

## ADR 32: Mock Objects Simulate

Mock objects MUST simulate both success and failure scenarios for external service calls to ensure comprehensive error handling coverage

---

## ADR 33: Unit Tests Services

Unit tests for services that interact with external APIs or network resources MUST use mocks, stubs, or fakes instead of real connections

---

## ADR 34: Controllers Delegate Domain

Controllers MAY delegate to domain services or Fortify actions based on the complexity and domain-specificity of the operation

---

## ADR 35: Authentication Action Classes

Authentication action classes MUST NOT contain presentation logic (views, redirects, session management) to maintain separation between authentication logic and deployment target concerns

---

## ADR 36: Feature Tests Authentication

Feature tests for authentication operations SHOULD verify behavior independently of presentation layer to ensure deployment target flexibility

---

## ADR 37: Authentication Actions Stateless

Authentication actions SHOULD be stateless and idempotent where possible to support horizontal scaling and API-first deployment patterns

---

## ADR 38: Password Validation Hashing

Password validation and hashing operations MUST use Laravel's Hash facade and validation rules to ensure consistent security standards across all deployment targets

---

## ADR 39: Domain Specific User

Domain-specific user management services (CreateAccount, AcceptInvitation, CancelAccount) MUST be implemented as dedicated service classes within their respective domain boundaries

---

## ADR 40: Authentication Actions Password

All authentication actions (password reset, password update, user creation) MUST be implemented as Laravel Fortify action classes in the app/Actions/Fortify namespace

---

## ADR 41: Deployment Targets Include

Deployment targets MAY include containerized environments (Docker) or traditional LAMP/LEMP stacks as long as PHP runtime requirements are satisfied

---

## ADR 42: Authentication Security Critical

Authentication and security-critical operations (password reset, user management) MUST execute within the PHP runtime using Laravel's built-in security features

---

## ADR 43: Development Production Environments

Development and production environments SHOULD maintain PHP version parity to minimize deployment-related issues

---

## ADR 44: Application Servers Use

Application servers SHOULD use PHP-FPM or similar process managers for optimal performance and resource management

---

## ADR 45: Php Extensions Required

PHP extensions required by Laravel (OpenSSL, PDO, Mbstring, Tokenizer, XML, Ctype, JSON, BCMath) MUST be available in the deployment target

---

## ADR 46: Deployment Environment Provide

The deployment environment MUST provide PHP runtime version compatible with Laravel framework requirements (PHP 8.0 or higher recommended)

---

## ADR 47: Backend Application Code

All backend application code MUST be written in PHP to ensure consistent runtime environment and deployment target compatibility

---

## ADR 48: Domain Services Not

Domain services MUST NOT implement custom password hashing, validation, or authentication logic that bypasses Fortify

---

## ADR 49: Account Lifecycle Operations

Account lifecycle operations (creation, cancellation, invitation acceptance) SHOULD integrate with Fortify's authentication context when user credentials are involved

---

## ADR 50: Password Validation Hashing

Password validation and hashing MUST be handled exclusively by Fortify's built-in mechanisms

---

## ADR 51: Feature Tests Authentication

Feature tests for authentication flows SHOULD verify Fortify integration behavior to ensure runtime compatibility

---

## ADR 52: Domain Services That

Domain services that require authentication operations MUST delegate to Fortify actions rather than implementing authentication logic directly

---

## ADR 53: Authentication Actions Implemented

Authentication actions MUST be implemented in the app/Actions/Fortify namespace following Fortify's action contract pattern

---

## ADR 54: Authentication Operations Password

All authentication operations (password reset, password update, account creation) MUST use Laravel Fortify as the core authentication runtime library

---

## ADR 55: Integration Modules Include

Integration modules MAY include utility classes for protocol-specific operations (e.g., Services/Utils/Dav) when needed for complex transformations

---

## ADR 56: Core Domain Entities

Core domain entities and business logic MUST NOT directly depend on external protocol implementation classes or libraries

---

## ADR 57: Viewhelper Classes Providing

ViewHelper classes providing external API functionality MUST reside in Web/ViewHelpers directories within their respective domain modules

---

## ADR 58: Resource Handler Classes

Resource handler classes (e.g., ImportResource, ImportVCardResource) SHOULD be used to manage external data import/export operations with clear single responsibilities

---

## ADR 59: External Specific Exceptions

External API-specific exceptions SHOULD be defined within the integration module (e.g., DavServerNotCompliantException) to provide clear error boundaries

---

## ADR 60: Backend Interfaces External

Backend interfaces for external protocols MUST be defined as contracts (e.g., IDAVBackend) to enable multiple implementations and testing

---

## ADR 61: Data Transfer Between

Data transfer between external APIs and domain logic MUST use dedicated DTO (Data Transfer Object) classes located in Services/Utils/Model directories

---

## ADR 62: Each External Integration

Each external API integration MUST provide a dedicated client service layer (e.g., DavClient/Services) that encapsulates all protocol-specific communication logic

---

## ADR 63: External Integrations Organized

External API integrations MUST be organized within domain-specific modules following the pattern: app/Domains/{DomainName}/{IntegrationName}/

---

## ADR 64: Applications Customize Fortify

Applications MAY customize Fortify's default behavior by providing custom Action implementations

---

## ADR 65: Authentication Logic Not

Authentication logic MUST NOT be duplicated outside of Fortify Actions

---

## ADR 66: Services That Handle

Services that handle user data SHOULD leverage validated data from Fortify Actions rather than implementing separate validation logic

---

## ADR 67: Input Validation Rules

Input validation rules for user data MUST be centralized within their respective Fortify Action classes

---

## ADR 68: Custom Fortify Actions

Custom Fortify Actions SHOULD extend or implement Fortify's action contracts to maintain consistency with the framework

---

## ADR 69: Fortify Actions Registered

Fortify Actions MUST be registered and configured in FortifyServiceProvider

---

## ADR 70: User Input Authentication

All user input in authentication flows MUST be validated using Laravel's validation rules before processing

---

## ADR 71: Authentication Operations Registration

All authentication operations (registration, login, password reset, profile updates) MUST be implemented using Laravel Fortify Actions

---

## ADR 72: Viewhelpers Integrate Dav

ViewHelpers MAY integrate DAV synchronization status and controls into user interface components for vault and personalization features

---

## ADR 73: Import Operations Provide

Import operations SHOULD provide separate resource handlers for generic DAV imports and vCard-specific imports

---

## ADR 74: Dav Client Services

DAV client services SHOULD be organized under dedicated DavClient namespace to separate external integration concerns from core domain logic

---

## ADR 75: Non Compliant Dav

Non-compliant DAV servers MUST be handled with specific exceptions (DavServerNotCompliantException) to provide clear error diagnostics

---

## ADR 76: Contact Operations Create

Contact operations (create, update, delete) with external systems MUST use structured DTOs (ContactDto, ContactDeleteDto) to encapsulate data transfer

---

## ADR 77: Dav Backend Implementations

DAV backend implementations MUST implement the IDAVBackend interface to ensure consistent protocol handling

---

## ADR 78: Contact Data Interchange

Contact data interchange with external systems MUST use vCard format for import and export operations

---

## ADR 79: External Contact Synchronization

All external contact synchronization MUST use CardDAV/WebDAV protocols as the standard integration mechanism

---

## ADR 80: Domain Services Implement

Domain services MAY implement additional validation layers for VCard data to ensure compliance with RFC 6350 specifications

---

## ADR 81: Viewhelper Classes Used

ViewHelper classes SHOULD be used to prepare domain data for presentation layers without exposing internal domain logic

---

## ADR 82: Import Export Operations

Import and export operations SHOULD be separated into distinct resource classes (ImportResource, ImportVCardResource) following single responsibility principle

---

## ADR 83: Non Compliant Dav

Non-compliant DAV server behaviors MUST be handled through explicit exception types (e.g., DavServerNotCompliantException) with clear error messaging

---

## ADR 84: Dav Backend Implementations

DAV backend implementations MUST implement defined interface contracts (e.g., IDAVBackend) to enable testability and substitutability

---

## ADR 85: Data Transfer Between

Data transfer between external DAV systems and internal domains MUST use dedicated DTO objects (ContactDto, ContactDeleteDto) to enforce boundary isolation

---

## ADR 86: External Dav Carddav

External DAV/CardDAV integrations MUST be encapsulated within domain-specific service layers (e.g., Contact domain DavClient services)

---

## ADR 87: Test Suites Verify

Test suites SHOULD verify password hashing behavior in authentication feature tests

---

## ADR 88: Password Validation Rules

Password validation rules MUST be enforced before hashing (minimum length, complexity requirements)

---

## ADR 89: Password Hashing Logic

Password hashing logic SHOULD be centralized in dedicated service methods or use framework-provided mechanisms rather than inline implementations

---

## ADR 90: Password Update Operations

Password update operations (reset, change, initial creation) MUST apply the same hashing strategy consistently

---

## ADR 91: Plain Text Passwords

Plain-text passwords MUST NOT be stored in the database or logged in any application logs

---

## ADR 92: Password Hashing Occur

Password hashing MUST occur before persisting user credentials to the database in all authentication workflows

---

## ADR 93: Password Storage Operations

All password storage operations MUST use Laravel's Hash facade or bcrypt hashing algorithm with appropriate cost factors

---

## ADR 94: External Integrations Implement

External API integrations SHOULD implement logging capabilities using traits (e.g., Loggable) for consistent observability across API interactions

---

## ADR 95: Permission Validation External

Permission validation for external API operations MUST throw specific permission exceptions (NotEnoughPermissionException) rather than generic authorization errors

---

## ADR 96: Viewhelper Classes Used

ViewHelper classes SHOULD be used to prepare data for external API responses, separating presentation logic from business logic

---

## ADR 97: External Clients Implement

External API clients SHOULD implement compliance validation to detect and handle non-compliant external servers gracefully

---

## ADR 98: Resource Import Operations

Resource import operations from external APIs MUST implement dedicated resource classes (e.g., ImportResource, ImportVCardResource) that handle protocol-specific data transformation

---

## ADR 99: External Integrations Define

External API integrations MUST define domain-specific exception types that extend base exception classes and provide meaningful error context for API-specific failures

---

## ADR 100: Protocol Specific Operations

Protocol-specific operations MUST be abstracted behind interface contracts (e.g., IDAVBackend) to enable multiple implementations and improve testability

---

## ADR 101: External Integrations Use

External API integrations MUST use Data Transfer Objects (DTOs) to represent external data structures and maintain clear boundaries between external formats and internal domain models

---

## ADR 102: Applications Implement Automatic

Applications MAY implement automatic password rehashing on login if the configured algorithm or work factor changes

---

## ADR 103: Hash Facade Configuration

The Hash facade configuration SHOULD use bcrypt or argon2id algorithms with framework-recommended work factors

---

## ADR 104: Password Hashing Operations

Password hashing operations SHOULD be performed immediately before database persistence to minimize plain-text exposure in memory

---

## ADR 105: Password Verification Use

Password verification MUST use Hash::check() to compare plain-text input against stored hashes

---

## ADR 106: Plain Text Passwords

Plain-text passwords MUST NOT be stored in any persistent storage including databases, logs, or cache

---

## ADR 107: Password Hashing Occur

Password hashing MUST occur in service layer classes or Fortify action classes, never in controllers or views

---

## ADR 108: Password Credentials Hashed

All password credentials MUST be hashed using Laravel's Hash facade before storage in the database

---

## ADR 109: Public Implement Versioning

Public APIs MAY implement versioning strategies (URL path, header-based, or content negotiation) when backward compatibility cannot be maintained

---

## ADR 110: Public Contracts Not

Public API contracts SHOULD NOT expose internal domain models directly; always use DTOs or resource representations

---

## ADR 111: Public Components Implement

All public API components MUST implement logging through standardized traits or interfaces (e.g., Loggable) for observability and debugging

---

## ADR 112: External Service Integrations

External service integrations SHOULD implement service-specific exception types (e.g., DavServerNotCompliantException) to distinguish integration failures from application errors

---

## ADR 113: Public Contracts Include

Public API contracts SHOULD include ViewHelper classes for presentation layer concerns, separating data transformation from business logic

---

## ADR 114: Public Throw Domain

Public APIs MUST throw domain-specific exceptions (extending base exception classes) for all error conditions, with descriptive messages and appropriate HTTP status codes

---

## ADR 115: Data Crossing Public

Data crossing public API boundaries MUST be encapsulated in dedicated Data Transfer Objects (DTOs) with clearly defined properties and validation rules

---

## ADR 116: Public Endpoints External

All public API endpoints and external integration points MUST define explicit interface contracts (e.g., IDAVBackend) that declare method signatures, parameters, and return types

---

## ADR 117: Exception Classes Include

Exception classes MAY include additional domain-specific fields in the formatted response if they enhance client-side error handling

---

## ADR 118: Exception Formatters Not

Exception formatters MUST NOT expose internal system details, stack traces, or sensitive data in external API responses

---

## ADR 119: Formatted Error Responses

Formatted error responses SHOULD follow a standard JSON schema that is versioned and documented in API specifications

---

## ADR 120: Exception Formatters Include

Exception formatters SHOULD include contextual metadata (e.g., resource IDs, user context) when available without exposing sensitive information

---

## ADR 121: Logging Utilities Such

Logging utilities (such as Loggable trait) MUST use the same formatting pattern as exception handlers to ensure consistency across error tracking and API responses

---

## ADR 122: Exception Formatters Include

Exception formatters MUST include at minimum: error code, human-readable message, HTTP status code, and timestamp

---

## ADR 123: Exception Classes Exposed

All exception classes exposed through external APIs MUST implement a consistent formatter interface or trait that standardizes error response structure

---

## ADR 124: Domain Services Not

Domain services MUST NOT assume data validity without explicit validation, even when receiving data from internal components

---

## ADR 125: Quality Gates Implemented

Quality gates MAY be implemented as reusable validator classes or traits when validation logic is shared across multiple services

---

## ADR 126: Synchronization Services That

Synchronization services that reconcile external data sources SHOULD implement quality gates to validate data consistency before persisting changes

---

## ADR 127: Controllers Receiving Webhook

Controllers receiving webhook or external API data SHOULD implement quality gates to verify payload structure and authentication before delegating to domain services

---

## ADR 128: Quality Gate Failures

Quality gate failures SHOULD throw typed exceptions that clearly indicate the validation failure reason and affected data element

---

## ADR 129: View Helpers That

View helpers that transform domain data for presentation MUST validate the completeness and structure of input data before transformation

---

## ADR 130: Quality Gates Validate

Quality gates MUST validate data type correctness, required field presence, and business rule constraints at the earliest possible point in the execution flow

---

## ADR 131: Domain Service Methods

All domain service methods that accept external input or cross-domain data MUST implement quality gate validation before processing business logic

---

## ADR 132: Components Use Dedicated

Components MAY use dedicated log channels for DAV operations to enable separate log routing and retention policies

---

## ADR 133: Synchronization Services Use

Synchronization services SHOULD use appropriate log levels: debug for routine operations, info for significant events, warning for recoverable issues, error for failures

---

## ADR 134: Log Statements Include

Log statements SHOULD include structured context arrays with relevant identifiers (contact_id, addressbook_id, subscription_id) to enable log aggregation and filtering

---

## ADR 135: Console Commands Performing

Console commands performing setup or subscription operations SHOULD log progress milestones and completion status for operational visibility

---

## ADR 136: Davclient Service Classes

DavClient service classes MUST log all external HTTP requests and responses at appropriate log levels (debug for success, warning/error for failures)

---

## ADR 137: Background Jobs Handling

Background jobs handling VCard/VCalendar operations MUST log job start, completion, and failure events with contextual data including resource identifiers

---

## ADR 138: Dav Backend Implementations

All DAV backend implementations (CalDAV, CardDAV) MUST use Laravel's Log facade for recording synchronization events, errors, and state transitions

---

## ADR 139: Applications Use Framework

Applications MAY use framework-provided authorization middleware (e.g., Laravel policies, gates) to standardize enforcement patterns

---

## ADR 140: Controllers Not Delegate

Controllers MUST NOT delegate authorization responsibility solely to the frontend or client-side validation

---

## ADR 141: Authorization Logic Centralized

Authorization logic SHOULD be centralized in reusable authorization service classes or middleware rather than duplicated across controllers

---

## ADR 142: Services That Can

Services that can be invoked from multiple entry points SHOULD implement their own authorization checks to ensure defense-in-depth

---

## ADR 143: Authorization Checks Validate

Authorization checks MUST validate user permissions against the specific resource being accessed, not just general role-based permissions

---

## ADR 144: Authorization Enforcement Points

Authorization enforcement points MUST be implemented at the earliest possible boundary (controller entry point or service layer) to fail fast on unauthorized requests

---

## ADR 145: Controller Methods That

All controller methods that access or modify domain resources MUST perform authorization checks before executing business logic

---

## ADR 146: Helper Classes Provide

Helper classes MAY provide utility functions for common datastore query patterns, but MUST remain stateless and reusable

---

## ADR 147: Background Jobs That

Background jobs that access datastores MUST implement proper error handling and transaction management

---

## ADR 148: View Helpers Retrieve

View helpers SHOULD retrieve data through service layer methods rather than directly querying datastores when business logic is involved

---

## ADR 149: Datastore Interactions Use

All datastore interactions MUST use the application's configured primary database connection and MUST NOT hardcode connection strings

---

## ADR 150: Data Access Logic

Data access logic SHOULD be encapsulated in dedicated repository classes or service methods rather than scattered across view helpers

---

## ADR 151: Direct Sql Queries

Direct SQL queries MUST NOT be used in domain services or view helpers unless explicitly justified and documented for performance reasons

---

## ADR 152: Domain Services View

All domain services, view helpers, and background jobs MUST access primary datastores through well-defined repository patterns or ORM abstractions (e.g., Eloquent models)

---

## ADR 153: Projects Implement Custom

Projects MAY implement custom HTTP client wrappers for domain-specific requirements while maintaining the underlying library usage

---

## ADR 154: Http Client Configurations

HTTP client configurations SHOULD be externalized to configuration files or environment variables for different environments

---

## ADR 155: External Integrations Wrapped

External API integrations SHOULD be wrapped in service classes that encapsulate the HTTP client library usage

---

## ADR 156: Http Client Implementations

HTTP client implementations SHOULD support middleware patterns for cross-cutting concerns like logging, retry logic, and authentication

---

## ADR 157: Vcard Vcalendar Data

vCard and vCalendar data processing MUST use specialized parsing libraries (e.g., Sabre VObject) rather than custom string manipulation

---

## ADR 158: Dav Caldav Carddav

DAV/CalDAV/CardDAV protocol interactions MUST use Sabre DAV client libraries or equivalent standards-compliant implementations

---

## ADR 159: Oauth Authentication Flows

OAuth authentication flows MUST utilize Laravel Socialite or equivalent OAuth client libraries

---

## ADR 160: External Http Communications

All external HTTP API communications MUST use established HTTP client libraries rather than raw socket or curl implementations

---

## ADR 161: Models Not Contain

Models MUST NOT contain business logic beyond data access concerns; complex business rules belong in service classes or domain objects

---

## ADR 162: Models Define Custom

Models MAY define custom attributes using accessors and mutators for computed or transformed data

---

## ADR 163: Complex Query Logic

Complex query logic SHOULD be encapsulated in model scopes or query builder methods rather than scattered throughout controllers

---

## ADR 164: Models Declare Fillable

Models SHOULD declare fillable or guarded properties to control mass assignment protection

---

## ADR 165: Models Define Explicit

Models SHOULD define explicit relationships using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.) rather than manual joins

---

## ADR 166: Each Model Class

Each model class MUST correspond to a single database table following Laravel naming conventions (singular PascalCase class name to plural snake_case table name)

---

## ADR 167: Model Classes Placed

Model classes MUST be placed in the app/Models namespace and directory structure

---

## ADR 168: Domain Entities That

All domain entities that map to database tables MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 169: Models Define Query

Models MAY define query scopes for reusable query logic specific to the entity

---

## ADR 170: Models Include Accessor

Models MAY include accessor and mutator methods for computed attributes or attribute transformation

---

## ADR 171: Business Logic Not

Business logic MUST NOT be tightly coupled to model classes; models should focus on data representation and persistence concerns

---

## ADR 172: Models Define Casts

Models SHOULD define casts for attributes that require type conversion (dates, JSON, booleans, etc.)

---

## ADR 173: Relationships Between Entities

Relationships between entities SHOULD be defined using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.)

---

## ADR 174: Models Define Their

Models SHOULD define their fillable or guarded properties to control mass assignment protection

---

## ADR 175: Each Model Class

Each model class MUST correspond to a single database table with clear naming conventions (singular model name, plural table name by default)

---

## ADR 176: Model Classes Placed

Model classes MUST be placed in the app/Models directory following Laravel namespace conventions

---

## ADR 177: Database Backed Domain

All database-backed domain entities MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 178: Models Define Custom

Models MAY define custom query scopes for reusable query logic specific to that entity

---

## ADR 179: Controllers Services Not

Controllers and services MUST NOT bypass models by executing raw SQL queries directly for standard CRUD operations

---

## ADR 180: Model Specific Business

Model-specific business logic and computed attributes SHOULD be encapsulated within the model class using accessors, mutators, and custom methods

---

## ADR 181: Eloquent Relationships Hasmany

Eloquent relationships (hasMany, belongsTo, belongsToMany, etc.) SHOULD be defined as methods within the model class rather than using manual joins

---

## ADR 182: Models Define Their

Models SHOULD define their fillable or guarded properties to control mass assignment protection

---

## ADR 183: Each Model Correspond

Each model MUST correspond to a single database table with the table name following Laravel's naming conventions (plural, snake_case)

---

## ADR 184: Model Classes Placed

Model classes MUST be placed in the app/Models namespace following Laravel's standard directory structure

---

## ADR 185: Database Backed Entities

All database-backed entities MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 186: Applications Implement Custom

Applications MAY implement custom stateful request handling (e.g., EnsureDavRequestsAreStateful) to support specialized protocols while maintaining Inertia compatibility

---

## ADR 187: Feature Gating Middleware

Feature-gating middleware (e.g., EnsureSignupIsEnabled) SHOULD integrate with Inertia's response cycle to provide seamless redirects without breaking SPA navigation

---

## ADR 188: Javascript Entry Points

JavaScript entry points (app.js, ssr.js) MUST be located in resources/js/ directory following Laravel's standard asset organization

---

## ADR 189: Middleware Handling Stateful

Middleware handling stateful requests SHOULD extend or integrate with Inertia's HandleInertiaRequests middleware to maintain consistent request/response patterns

---

## ADR 190: Custom Middleware Extending

Custom middleware extending Inertia's base middleware MUST be placed in app/Http/Middleware/ and follow the naming convention Ensure[Feature][Condition].php

---

## ADR 191: Server Side Rendering

Server-side rendering (SSR) MUST be implemented using a dedicated ssr.js entry point separate from the client-side app.js entry point

---

## ADR 192: Frontend Backend Integration

All frontend-backend integration MUST use Inertia.js as the primary communication layer between Laravel controllers and JavaScript components

---

## ADR 193: Models Define Custom

Models MAY define custom query scopes to encapsulate common query patterns

---

## ADR 194: Models Define Relationships

Models SHOULD define relationships using Eloquent relationship methods (hasMany, belongsTo, etc.) rather than manual joins

---

## ADR 195: Business Logic Not

Business logic MUST NOT bypass models to access database directly via raw queries except for performance-critical operations with documented justification

---

## ADR 196: Models Define Fillable

Models SHOULD define $fillable or $guarded properties to control mass assignment protection

---

## ADR 197: Models Use Explicit

Models SHOULD use explicit table name declarations via the $table property when the table name does not follow Laravel naming conventions

---

## ADR 198: Models Define Their

Models MUST define their public API contracts including fillable attributes, relationships, and accessor/mutator methods

---

## ADR 199: Model Classes Placed

Model classes MUST be placed in the app/Models namespace following Laravel conventions

---

## ADR 200: Database Entities Represented

All database entities MUST be represented by Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 201: Business Logic Not

Business logic MUST NOT be tightly coupled to model classes; models should focus on data representation and persistence

---

## ADR 202: Models Define Custom

Models MAY define custom query scopes, accessors, and mutators for domain-specific data manipulation

---

## ADR 203: Models Use Type

Models SHOULD use type casting via the $casts property for automatic attribute transformation

---

## ADR 204: Relationships Between Entities

Relationships between entities SHOULD be defined using Eloquent relationship methods (hasMany, belongsTo, belongsToMany, etc.)

---

## ADR 205: Models Define Fillable

Models SHOULD define fillable or guarded properties to control mass assignment protection

---

## ADR 206: Each Model Correspond

Each model MUST correspond to a single database table with explicit or conventional table name mapping

---

## ADR 207: Model Classes Placed

Model classes MUST be placed in the app/Models namespace following Laravel conventions

---

## ADR 208: Database Entities Represented

All database entities MUST be represented as Eloquent Model classes extending Illuminate\Database\Eloquent\Model

---

## ADR 209: Modules Define Their

Modules MAY define their own factory classes for complex nested structures (e.g., ModuleRow within Module)

---

## ADR 210: Scheduled Tasks Defined

Scheduled tasks MUST be defined in a centralized Schedule class that extends the framework's scheduling infrastructure

---

## ADR 211: Module Initialization Logic

Module initialization logic SHOULD be encapsulated in dedicated setup commands (e.g., SetupApplication, SetupDocumentation) rather than scattered across the codebase

---

## ADR 212: View Helpers Isolated

View helpers SHOULD be isolated in dedicated ViewHelper classes within the Web layer of their respective domains

---

## ADR 213: Console Commands Application

Console commands for application setup and initialization MUST be implemented in app/Console/Commands/ and follow the Command pattern

---

## ADR 214: Database Entity Factories

Database entity factories MUST extend the framework's base Factory class and be placed in database/factories/ directory

---

## ADR 215: Domain Modules Organized

All domain modules MUST be organized under a clear namespace hierarchy following the pattern app/Domains/{Domain}/{Subdomain}/{Layer}

---

## ADR 216: Migrations Include Data

Migrations MAY include data seeding operations when necessary for schema-dependent reference data, though seeders are preferred for test data

---

## ADR 217: Migrations Include Appropriate

Migrations SHOULD include appropriate indexes, foreign key constraints, and default values as part of the schema definition

---

## ADR 218: Migration Files Atomic

Migration files SHOULD be atomic, focusing on a single logical schema change to facilitate easier rollback and debugging

---

## ADR 219: Direct Sql Schema

Direct SQL schema modifications MUST NOT be performed on production databases outside of the migration system

---

## ADR 220: Migration Files Use

Migration files MUST use Laravel's Schema Builder API (Schema::create, Schema::table, etc.) rather than raw SQL for database-agnostic operations

---

## ADR 221: Each Migration File

Each migration file MUST implement both up() and down() methods to support forward migration and rollback operations

---

## ADR 222: Migration Files Follow

Migration files MUST follow Laravel's naming convention: YYYY_MM_DD_HHMMSS_descriptive_name.php with timestamps ensuring chronological execution order

---

## ADR 223: Database Schema Changes

All database schema changes MUST be implemented using Laravel migration files stored in the database/migrations directory

---

## ADR 224: Tests Use Factory

Tests MAY use factory patterns or fixtures for test data generation to improve maintainability

---

## ADR 225: Test Methods Use

Test methods MUST use descriptive names that clearly indicate the behavior being tested

---

## ADR 226: Test File Naming

Test file naming SHOULD follow the pattern {ClassName}Test.php matching the class under test

---

## ADR 227: Test Classes Use

Test classes SHOULD use trait-based helper utilities (e.g., DatabaseTransactions, RefreshDatabase) for shared testing functionality

---

## ADR 228: Test Classes Extend

Test classes MUST extend PHPUnit\Framework\TestCase or an appropriate base test class

---

## ADR 229: Unit Tests Organized

Unit tests MUST be organized under the tests/Unit/ directory with subdirectories reflecting the application structure (Models, Helpers, etc.)

---

## ADR 230: Phpunit Test Classes

All PHPUnit test classes MUST implement a setUp() method for test initialization and dependency preparation

---

## ADR 231: Domains Contain Additional

Domains MAY contain additional subdirectories for domain-specific concerns such as Events, Repositories, or ValueObjects

---

## ADR 232: Service Classes Not

Service classes MUST NOT directly handle HTTP concerns such as request parsing or response formatting

---

## ADR 233: Domain Boundaries Align

Domain boundaries SHOULD align with business capabilities and use cases rather than technical layers

---

## ADR 234: Controllers Delegate Business

Controllers SHOULD delegate business logic to service classes rather than implementing logic directly

---

## ADR 235: Service Classes Encapsulate

Service classes MUST encapsulate single business operations with clear, action-oriented names (e.g., RemoveContactFromPost, UpdateJournalMetric)

---

## ADR 236: Each Domain Separate

Each domain MUST separate concerns into distinct subdirectories: Services for business logic, Web/Controllers for HTTP handling, and Models for data structures

---

## ADR 237: Business Logic Organized

Business logic MUST be organized into domain-specific directories under app/Domains/{DomainName}

---

## ADR 238: Pipelines Leverage Domain

CI/CD pipelines MAY leverage the domain-based directory structure to execute tests in parallel by domain or sub-domain

---

## ADR 239: Test Directory Root

The test directory root MUST be located at tests/Unit/ for unit tests, with integration and functional tests in separate parallel hierarchies

---

## ADR 240: Web Concerns Separated

API and Web concerns SHOULD be separated into distinct test directories (Api/Controllers vs Web/ViewHelpers) to enable independent testing strategies

---

## ADR 241: Tests Organized Architectural

Tests SHOULD be organized by architectural layer (Services, Controllers, ViewHelpers) within each domain to support layer-specific test execution

---

## ADR 242: Test File Names

Test file names MUST follow the pattern {ClassName}Test.php, where {ClassName} is the exact name of the class under test

---

## ADR 243: Domain Boundaries Reflected

Domain boundaries MUST be reflected in the test directory structure, with tests organized under their respective domain and sub-domain directories

---

## ADR 244: Test Files Organized

Test files MUST be organized in a directory structure that mirrors the production code hierarchy, maintaining a 1:1 correspondence between test and implementation files

---

## ADR 245: Controllers Use Inertia

Controllers MAY use Inertia's partial reloads to optimize data fetching for specific component updates

---

## ADR 246: Controllers Not Mix

Controllers MUST NOT mix Inertia responses with traditional view() responses in the same domain context

---

## ADR 247: Form Submissions Return

Form submissions SHOULD return Inertia responses with appropriate redirect() or back() methods to maintain SPA navigation

---

## ADR 248: Controllers Use Inertia

Controllers SHOULD use Inertia's lazy loading for expensive data that is not immediately needed on page load

---

## ADR 249: Data Passed Frontend

All data passed to the frontend MUST be serialized as props in the Inertia response, not through session flash data or view composers

---

## ADR 250: Controllers Return Inertia

Controllers MUST return Inertia responses using the Inertia::render() method with a component name and props array

---

## ADR 251: Web Controllers Managejournals

Web controllers in the ManageJournals domain MUST use Inertia.js responses for rendering views instead of traditional Blade templates or JSON API responses

---

## ADR 252: Teams Implement Contract

Teams MAY implement contract testing frameworks (e.g., Pact, Spring Cloud Contract) for more sophisticated consumer-driven contract testing

---

## ADR 253: Contract Tests Follow

API contract tests SHOULD follow naming conventions that clearly identify the component under test (e.g., *ControllerTest.php, *ServiceTest.php, *ViewHelperTest.php)

---

## ADR 254: Breaking Changes Public

Breaking changes to public API contracts MUST cause CI/CD pipeline failures and prevent deployment

---

## ADR 255: Contract Tests Validate

Contract tests SHOULD validate both successful responses and error conditions to ensure comprehensive API behavior coverage

---

## ADR 256: Contract Tests Organized

API contract tests SHOULD be organized by domain boundaries (e.g., Settings/ManageTemplates, Settings/ManageUsers) to maintain clear separation of concerns

---

## ADR 257: Test Coverage Public

Test coverage for public API contracts MUST include all CRUD operations (Create, Read, Update, Delete) where applicable

---

## ADR 258: Public Contract Tests

Public API contract tests MUST be executed as part of the CI/CD pipeline before any code can be merged to main branches

---

## ADR 259: Public Endpoints Service

All public API endpoints and service contracts MUST have corresponding unit tests that validate request/response schemas, method signatures, and return types

---

## ADR 260: Locale Specific Formatting

Locale-specific formatting rules (dates, numbers, currency) MAY be defined in dedicated format.php files per locale

---

## ADR 261: New Locales Maintain

New locales SHOULD maintain structural parity with existing language files to ensure feature completeness across all supported languages

---

## ADR 262: Business Logic Code

Business logic code MUST NOT contain hardcoded user-facing strings; all such strings MUST reference translation keys

---

## ADR 263: Translation Files Use

Translation files SHOULD use PHP array return structures for framework compatibility and easy key-value access

---

## ADR 264: Each Locale Provide

Each locale MUST provide translation files for core categories: auth, validation, passwords, actions, pagination, http-statuses, and format

---

## ADR 265: Language Files Organized

Language files MUST be organized by locale code (e.g., lang/en/, lang/hi/, lang/he/, lang/ja/, lang/it/) following ISO 639-1 standards

---

## ADR 266: User Facing Strings

All user-facing strings MUST be externalized into language-specific resource files organized under a lang/ directory structure

---

## ADR 267: Domains Organize Controllers

Domains MAY organize controllers into further subdirectories if the number of controllers exceeds 10 within a single domain

---

## ADR 268: Related Controllers Handling

Related controllers handling sub-resources SHOULD use composite naming that reflects the parent-child relationship (e.g., PostMetricController, PostSliceOfLifeController)

---

## ADR 269: Controllers Placed Within

Controllers MUST be placed within the Web/Controllers subdirectory of their domain to separate web concerns from other layers

---

## ADR 270: Controller Naming Follow

Controller naming SHOULD follow the pattern {Entity}Controller or {Entity}{Concern}Controller (e.g., JournalController, PostPhotoController)

---

## ADR 271: Each Distinct Entity

Each distinct entity or concern within journal management (journals, posts, photos, metrics, slices of life) MUST have a dedicated controller class

---

## ADR 272: Controllers Handling Journal

Controllers handling journal management features MUST be organized under the app/Domains/Vault/ManageJournals/Web/Controllers namespace

---

## ADR 273: Services Composed Together

Services MAY be composed together to implement complex workflows, but each service should remain independently testable

---

## ADR 274: Domain Operations Organized

Domain operations MUST be organized by subdomain (ManageJournals) with clear namespace boundaries separating Web, Services, and other concerns

---

## ADR 275: Services Handle Transaction

Services SHOULD handle transaction boundaries and data persistence concerns internally, exposing clean interfaces to controllers

---

## ADR 276: Service Class Names

Service class names SHOULD use verb-noun naming convention that clearly describes the operation (e.g., RemoveContactFromPost, IncrementPostReadCounter)

---

## ADR 277: Web Controllers Managejournals

Web controllers in the ManageJournals/Web/Controllers directory MUST delegate business logic to service classes rather than implementing logic directly

---

## ADR 278: Service Classes Follow

Service classes MUST follow single-responsibility principle with one primary operation per class (e.g., CreatePostMetric, DestroySliceOfLife, UpdateJournalMetric)

---

## ADR 279: Business Logic Journal

All business logic for journal management operations MUST be encapsulated in dedicated service classes within the app/Domains/Vault/ManageJournals/Services directory

---

## ADR 280: Pipelines Implement Domain

CI/CD pipelines MAY implement domain-specific test stages that execute only tests for changed domains

---

## ADR 281: Test Organization Facilitate

Test organization SHOULD facilitate parallel test execution by allowing independent domain or module test runs

---

## ADR 282: Domain Boundaries Enforced

Domain boundaries SHOULD be enforced in CI/CD pipelines to enable selective test execution by domain or feature module

---

## ADR 283: Test Files Maintain

Test files MUST maintain the same subdirectory structure within feature modules as production code (e.g., Services/, Web/ViewHelpers/, Api/Controllers/)

---

## ADR 284: Test File Names

Test file names MUST append 'Test' suffix to the corresponding production class name (e.g., RemoveModuleFromTemplatePage.php -> RemoveModuleFromTemplatePageTest.php)

---

## ADR 285: Each Domain Subdirectory

Each domain subdirectory MUST contain feature module subdirectories that mirror the production code organization (e.g., ManageTemplates, ManageUserPreferences, ManageUsers)

---

## ADR 286: Test Files Organized

Test files MUST be organized under tests/Unit/Domains/ following the same domain structure as production code

---

## ADR 287: Tests Use Phpunit

Tests MAY use PHPUnit mocking capabilities to isolate dependencies

---

## ADR 288: Test Suites Executable

Test suites SHOULD be executable in CI/CD pipelines for automated verification

---

## ADR 289: Unit Tests Focus

Unit tests MUST focus on testing individual components in isolation without external dependencies

---

## ADR 290: Each Service Class

Each service class, controller, and view helper SHOULD have a corresponding unit test file

---

## ADR 291: Test Class Files

Test class files MUST follow the naming convention {ClassName}Test.php where {ClassName} is the class under test

---

## ADR 292: Unit Test Files

Unit test files MUST be placed in tests/Unit/Domains/ directory structure mirroring the application domain hierarchy

---

## ADR 293: Unit Tests Written

All unit tests MUST be written using PHPUnit as the testing framework

---

## ADR 294: Individual Route Methods

Individual route methods MAY apply additional authorization checks beyond the base authentication middleware

---

## ADR 295: Authentication Configuration Consistent

Authentication configuration SHOULD be consistent across related resource controllers (e.g., Journal and JournalPhoto controllers)

---

## ADR 296: Controllers Apply Authentication

Controllers SHOULD apply authentication middleware in the constructor method to ensure all routes are protected by default

---

## ADR 297: New Controllers Added

New controllers added to the ManageJournals domain MUST follow the established authentication middleware pattern without deviation

---

## ADR 298: Authentication Middleware Configured

Authentication middleware MUST be configured using the same authentication method pattern detected across JournalController, PostController, JournalPhotoController, PostPhotoController, JournalMetricController, PostMetricController, SliceOfLifeController, and PostSliceOfLifeController

---

## ADR 299: Controllers Within App

All controllers within app/Domains/Vault/ManageJournals/Web/Controllers MUST apply authentication middleware to protect routes from unauthorized access

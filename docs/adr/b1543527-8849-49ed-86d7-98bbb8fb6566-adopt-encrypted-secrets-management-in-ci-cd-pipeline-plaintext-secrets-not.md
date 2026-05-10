# Adopt Encrypted Secrets Management in CI/CD Pipeline: Plaintext Secrets Not

Status: proposed
Date: 2024-01-15
Deciders: Detection Pipeline (automated)

## Activation

This ADR is ALWAYS ACTIVE for all CI/CD pipeline configurations and deployment workflows.

## Context

- The codebase contains test files that interact with authentication and data verification mechanisms, indicating a need for secure credential handling during automated testing
- CI/CD pipelines require access to sensitive credentials (API keys, database passwords, encryption keys) to execute tests and deployments
- Pattern detected across multiple test domains (Auth, Contact/DAV) suggests a consistent approach to handling encrypted data in automated workflows
- Security facet 'security.encryption' indicates the pattern involves cryptographic operations that must be protected in CI/CD environments
- Modern DevOps practices require secrets to be encrypted at rest and in transit, never committed to version control in plaintext

## Problem Statement

CI/CD pipelines need access to sensitive credentials and encryption keys to run tests and deploy applications, but storing these secrets in plaintext within pipeline configurations or version control systems creates significant security vulnerabilities. Without a standardized encrypted secrets management approach, teams may inadvertently expose credentials, fail compliance audits, or create inconsistent security postures across different pipeline stages.

## Decision

1. MUST_NOT: Plaintext secrets MUST NOT be committed to version control repositories or stored in pipeline configuration files

## Policy Block

- MUST_NOT Plaintext secrets MUST NOT be committed to version control repositories or stored in pipeline configuration files

In scope:
- All CI/CD pipeline configurations (GitHub Actions, GitLab CI, Jenkins, CircleCI, etc.)
- Automated test suites requiring authentication or encrypted data access
- Deployment scripts and infrastructure-as-code templates
- Container orchestration secrets (Kubernetes Secrets, Docker Swarm secrets)
- Build-time environment variables containing sensitive data

Out of scope:
- Local development environment configurations (covered by separate developer workstation policies)
- Runtime application secrets management (covered by application architecture ADRs)
- Database encryption at rest (covered by data storage ADRs)
- End-user authentication flows (covered by application security ADRs)

Exceptions:
- EXC-001: Non-sensitive configuration values that are publicly documented (e.g., public API endpoints, feature flags with no security impact)
- EXC-002: Temporary debugging in isolated development pipelines with synthetic test data only

## Rationale

- Pattern detected with 80.83% confidence across 3 files in authentication and data verification domains, indicating a consistent architectural approach to encrypted data handling
- Security.encryption facet suggests cryptographic operations are central to the pattern, requiring protected key material in CI/CD contexts
- Industry best practices (OWASP, NIST, CIS Benchmarks) mandate encrypted secrets management to prevent credential exposure and meet compliance requirements
- Automated testing of authentication and encryption features requires access to test credentials that must be protected with the same rigor as production secrets

## Consequences

Positive:
- Significantly reduces risk of credential exposure through version control history, pipeline logs, or configuration file leaks
- Enables centralized secrets management with audit trails, rotation policies, and access controls
- Facilitates compliance with security standards (SOC 2, ISO 27001, PCI-DSS) that require encrypted credential storage
- Improves developer experience by providing consistent secrets access patterns across all pipeline stages

Negative:
- Introduces dependency on secrets management infrastructure (e.g., HashiCorp Vault, AWS Secrets Manager, GitHub Secrets)
- Adds complexity to pipeline configuration and initial setup time for new projects
- May increase pipeline execution time due to secrets retrieval operations
- Requires additional operational overhead for secrets rotation, access management, and monitoring

## Alternatives

- Store encrypted secrets directly in version control using tools like git-crypt or SOPS (rejected)
  Rejected because: Requires all developers to have decryption keys, creates key distribution challenges, and makes secrets rotation more difficult. Audit trails are limited to git history.
  When valid: May be acceptable for very small teams (2-3 developers) with simple deployment needs and no compliance requirements
- Use environment variables set manually in CI/CD platform UI without encryption (rejected)
  Rejected because: Secrets are stored in plaintext in the CI/CD platform's database, lack proper access controls, and cannot be easily rotated or audited. Does not meet security compliance standards.
  When valid: Never valid for production systems; only acceptable for throwaway proof-of-concept environments
- Implement custom secrets encryption using application-level cryptography (rejected)
  Rejected because: Reinvents the wheel, increases maintenance burden, and is prone to implementation errors. Lacks enterprise features like audit logging, rotation, and access policies.
  When valid: Only when working with highly specialized security requirements that cannot be met by existing secrets management solutions

## Risks

- Secrets management service outage could block all CI/CD pipeline executions
  Mitigation: Implement fallback mechanisms, cache secrets with short TTL, and establish SLA monitoring with alerting for secrets service availability
  Owner: DevOps team
- Misconfigured access controls could allow unauthorized access to secrets
  Mitigation: Implement principle of least privilege, regular access audits, and automated compliance scanning of secrets permissions
  Owner: Security team
- Secrets may be inadvertently logged or exposed in error messages during pipeline failures
  Mitigation: Implement automatic secret masking in CI/CD platforms, use structured logging with secret redaction, and conduct regular log audits
  Owner: Engineering team

## Implementation Notes

- Choose a secrets management solution appropriate for your infrastructure: GitHub Secrets for GitHub Actions, GitLab CI/CD variables with masking, AWS Secrets Manager for AWS-based pipelines, or HashiCorp Vault for multi-cloud environments
- Establish naming conventions for secrets (e.g., ENV_SERVICE_CREDENTIAL_TYPE) to improve discoverability and prevent naming conflicts
- Implement automated secret scanning in pre-commit hooks and CI pipelines using tools like truffleHog, git-secrets, or detect-secrets to prevent accidental commits
- Document the secrets retrieval process in pipeline configuration comments and maintain a secrets inventory with ownership and rotation schedules

## Continuation Context


Verify commands:
- grep -r "password\|secret\|api[_-]key" .github/workflows/ .gitlab-ci.yml Jenkinsfile | grep -v "\${{" | grep -v "\${" || echo 'No plaintext secrets found'
- git log -p | grep -E "(password|secret|api[_-]?key)\s*=\s*['\"][^'\"]{8,}" || echo 'No secrets in git history'
- find . -name '*.yml' -o -name '*.yaml' | xargs grep -l 'secrets\|vault\|encrypted' | wc -l

Accept when:
- No plaintext secrets are found in pipeline configuration files when scanning with grep patterns
- All secrets are referenced using platform-specific variable syntax (e.g., ${{ secrets.NAME }}, ${VAULT_SECRET})
- Pipeline logs demonstrate secret masking with values replaced by *** or [REDACTED] markers
- Secrets management documentation exists with inventory of all secrets, their purpose, and rotation schedule

## Enforcement

- Verified by: Automated secret scanning in pre-commit hooks and CI pipeline stages
- Verified by: Code review checklist requiring verification of encrypted secrets usage
- Verified by: Quarterly security audits of pipeline configurations and secrets access logs
- Verified by: Automated compliance scanning using tools like Checkov, tfsec, or custom policy-as-code
- Violation handling: Pre-commit hooks block commits containing potential secrets and provide remediation guidance
- Violation handling: CI pipeline fails if plaintext secrets are detected in configuration files
- Violation handling: Security team is automatically notified of violations via alerting system
- Violation handling: Violations require immediate remediation with root cause analysis and team training
- Exception process: Submit exception request to security team with justification and risk assessment
- Exception process: Security team reviews request within 2 business days with approval/rejection decision
- Exception process: Approved exceptions are time-bound (max 30 days) and require compensating controls
- Exception process: All exceptions are logged in security audit system with automatic expiration and renewal workflow
# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.1.x   | Yes       |

## Reporting a Vulnerability

If you discover a security vulnerability in this Helm chart, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, please email [security@radiusmethod.com](mailto:security@radiusmethod.com) with:

- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Response Timeline

- **Acknowledgment**: Within 2 business days
- **Initial Assessment**: Within 5 business days
- **Fix Release**: Depending on severity, typically within 14 days for critical issues

## Scope

This policy covers the Helm chart templates, default configurations, and documentation in this repository. For vulnerabilities in the Citadel application itself, please report to the [Citadel repository](https://github.com/radiusmethod/citadel).

## Best Practices

When deploying Citadel, we recommend:

- Always set a strong `citadel.secretKey` (use `openssl rand -hex 32`)
- Disable `citadel.devLoginEnabled` in production
- Use `existingSecret` with a secrets manager (Vault, Sealed Secrets, ESO) for sensitive values
- Enable network policies in production clusters
- Use TLS termination via Ingress or Istio
- Regularly update to the latest chart version

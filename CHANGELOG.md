# Changelog

All notable changes to the Citadel Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-03-03

### Added

- Initial Helm chart for Citadel AI Gateway
- Deployment with configurable replicas and autoscaling (HPA)
- Bundled PostgreSQL via Bitnami subchart
- Bundled Redis via Bitnami subchart (optional)
- External database support
- Init container to wait for database readiness
- ConfigMap-based application configuration
- Secret management with `existingSecret` support for Vault/ESO
- Configurable models via `models.yaml` ConfigMap
- LLM provider configuration: OpenRouter, Anthropic, Vertex AI, AWS Bedrock
- Okta/OIDC authentication support
- Guardrails configuration (OpenAI moderation, PII filter)
- Plugin system toggle
- API key passthrough mode
- Kubernetes Ingress support
- Istio VirtualService for Big Bang integration
- ServiceAccount with configurable annotations
- Security context defaults (non-root, drop all capabilities)
- Helm test for health endpoint verification
- CI workflows for linting and OCI chart releases

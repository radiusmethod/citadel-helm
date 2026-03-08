# Changelog

All notable changes to the Citadel Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2026-03-08

### Changed

- **Go runtime migration**: Removed Python/uvicorn command override and `PYTHONPATH` env var from deployment — the Go image's `CMD ["/app/citadel"]` is now used as the entrypoint
- **Init container**: Replaced Python/asyncpg database wait script with a lightweight `busybox` + `nc` TCP check (no longer pulls the full app image for the init container)
- **`passthrough.enabled`**: Default changed from `false` to `true` to match the Go app default
- **`guardrails.openaiModeration`**: Default changed from `false` to `true` to match the Go app default
- Bumped `appVersion` to `0.2.0`

### Added

- **`citadel.uiSessionSecret`** value: Exposes `UI_SESSION_SECRET` in the Helm secret so production deployments don't silently CrashLoop when the Go app rejects the default session secret
- **NOTES.txt**: Added post-install guidance for creating an API key and PVC cleanup reminder

### Fixed

- Docs: Removed unnecessary "Add Bitnami repo" step (chart uses OCI dependencies)
- Docs: Fixed health response format from `{"status": "healthy"}` to `{"status":"ok"}`
- Docs: Replaced Python `asyncpg` troubleshooting command with `curl` health check
- Docs: Updated image tag references from `0.1.0` to `0.2.0`
- Docs: Added `uiSessionSecret` to production hardening checklist

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

# Architecture Overview

This document describes the Citadel AI Gateway architecture for operators and platform engineers deploying the system.

## What is Citadel?

Citadel is a zero-trust AI gateway that sits between your users (developers using Claude Code, OpenAI SDK, etc.) and LLM providers (OpenRouter, Anthropic, Vertex AI, AWS Bedrock). It provides:

- **Centralized API key management** — Users get virtual API keys; real provider keys stay in the gateway
- **Spend tracking and budget enforcement** — Per-user and per-key cost monitoring with configurable limits
- **Guardrails** — Input/output content filtering (PII detection, moderation, custom plugins)
- **Audit logging** — Full request/response logging for compliance
- **Model curation** — Control which models are available to users
- **OpenAI-compatible API** — Drop-in replacement for OpenAI/Anthropic API endpoints

## Request Flow

```
┌──────────────────────────────────────────────────────────────────────┐
│                          CITADEL GATEWAY                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│   Client Request (Claude Code / OpenAI SDK / curl)                   │
│        │                                                              │
│        ▼                                                              │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐           │
│   │  Security   │────▶│    Auth     │────▶│  Guardrails │           │
│   │  Headers    │     │  (API Key / │     │  (Pre-call) │           │
│   └─────────────┘     │  JWT/OIDC)  │     └─────────────┘           │
│                        └─────────────┘           │                   │
│                              │                   ▼                   │
│                        ┌─────────────┐     ┌─────────────┐          │
│                        │   Budget    │     │  Provider   │          │
│                        │   Check     │     │  Router     │          │
│                        └─────────────┘     └─────────────┘          │
│                                                  │                   │
│                    ┌─────────────────────────────┼──────────┐       │
│                    ▼                             ▼           ▼       │
│             ┌───────────┐              ┌───────────┐  ┌──────────┐ │
│             │ OpenRouter │              │ Vertex AI │  │ Bedrock  │ │
│             └───────────┘              └───────────┘  └──────────┘ │
│                    │                             │           │       │
│                    └─────────────────────────────┼───────────┘       │
│                                                  ▼                   │
│                                          ┌───────────┐              │
│                                          │ Guardrails│              │
│                                          │(Post-call)│              │
│                                          └───────────┘              │
│                                                  │                   │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐          │
│   │  Logging    │◀────│   Spend     │◀────│  Response   │          │
│   │  (Async)    │     │  Tracking   │     │  Transform  │          │
│   └─────────────┘     └─────────────┘     └─────────────┘          │
│         │                   │                                        │
│         ▼                   ▼                                        │
│   ┌──────────────────────────────────┐                               │
│   │          PostgreSQL              │                               │
│   │  (Keys, Users, Logs, Spend)     │                               │
│   └──────────────────────────────────┘                               │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

## API Endpoints

### LLM Endpoints (OpenAI-Compatible)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/chat/completions` | Chat completion (streaming and non-streaming) |
| GET | `/v1/models` | List available models |

### LLM Endpoints (Anthropic-Compatible)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/messages` | Anthropic Messages API (streaming, thinking, caching) |
| POST | `/v1/messages/count_tokens` | Count tokens for a messages request |

### Management API

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/keys` | Create virtual API key |
| GET | `/api/keys` | List user's keys |
| GET | `/api/keys/{id}` | Get key details |
| DELETE | `/api/keys/{id}` | Revoke key |
| GET | `/api/keys/{id}/usage` | Key usage stats |
| POST | `/api/users` | Create user |
| GET | `/api/users` | List users |
| GET | `/api/users/{id}` | User details |
| PATCH | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Deactivate user |
| GET | `/api/users/{id}/usage` | User usage stats |

### Plugin API

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/plugins` | List plugins |
| POST | `/api/plugins` | Register plugin |
| PATCH | `/api/plugins/{id}` | Update plugin config |
| POST | `/api/plugins/{id}/enable` | Enable plugin |
| POST | `/api/plugins/{id}/disable` | Disable plugin |
| POST | `/api/plugins/reload` | Reload all plugins |

### Health Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Liveness probe |
| GET | `/health/ready` | Readiness probe (checks DB connectivity) |

## Authentication Chain

Citadel supports multiple authentication methods, evaluated in priority order:

1. **Passthrough** — If `x-citadel-api-key` header is present and passthrough is enabled, the client's `Authorization` header is forwarded to the upstream provider. The Citadel key is used for logging and budget tracking.

2. **SocketZero JWT** — If enabled, verifies RS256-signed JWTs from SocketZero Receiver. Users are auto-provisioned on first auth.

3. **API Key** — Traditional `sk-citadel-xxx` virtual API keys. Keys are SHA-256 hashed before storage.

4. **OIDC (Okta)** — For the management UI. Users authenticate via Okta and get session cookies.

5. **Dev Login** — Bypass authentication for evaluation. Must be explicitly enabled.

## Database Schema

Citadel uses PostgreSQL with four core tables:

### users

Stores user accounts with spend tracking and budget limits.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `email` | VARCHAR | Unique email |
| `name` | VARCHAR | Display name |
| `max_budget` | DECIMAL | Spending limit |
| `spend` | DECIMAL | Current spend |
| `is_active` | BOOLEAN | Account status |
| `source` | VARCHAR | How user was created (api_key, socketzero, admin) |

### api_keys

Virtual API keys with per-key budgets and model restrictions.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `key_hash` | VARCHAR | SHA-256 hash of the key |
| `key_prefix` | VARCHAR | First 20 chars for identification |
| `user_id` | UUID | Owner reference |
| `max_budget` | DECIMAL | Per-key spending limit |
| `allowed_models` | TEXT[] | Model whitelist (NULL = all) |
| `rate_limit_rpm` | INTEGER | Requests per minute |
| `rate_limit_tpm` | INTEGER | Tokens per minute |
| `expires_at` | TIMESTAMPTZ | Key expiration |

### request_logs

Audit trail of all LLM requests.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `request_id` | VARCHAR | Correlation ID |
| `api_key_id` | UUID | Key used |
| `model` | VARCHAR | Model requested |
| `provider` | VARCHAR | Provider used |
| `prompt_tokens` | INTEGER | Input tokens |
| `completion_tokens` | INTEGER | Output tokens |
| `cost` | DECIMAL | Request cost |
| `latency_ms` | INTEGER | Response time |
| `status` | VARCHAR | success, error, guardrail_blocked |

### daily_spend

Pre-aggregated daily spend for fast dashboard queries.

## Provider Routing

The provider router maps model names from `models.yaml` to upstream providers:

| Provider | Transport | Authentication | Notes |
|----------|-----------|---------------|-------|
| **OpenRouter** | HTTPS REST | API key in header | 200+ models, cost in response |
| **Anthropic** | HTTPS REST | API key in header | Native Messages API passthrough |
| **Vertex AI** | HTTPS REST | Service account JSON | Google Cloud Gemini models |
| **Bedrock** | AWS SDK (SigV4) | IAM credentials or task role | GovCloud support |

Models are curated via `models.yaml` (ConfigMap). When `model_curation_enabled: true`, only listed models are available. Set `fallback_to_dynamic: true` to allow unlisted models.

## Plugin System

Citadel has an extensible plugin system with lifecycle hooks:

```
Auth → PRE_REQUEST → CHECK_INPUT → PRE_PROVIDER → Provider Call
                                                       ↓
POST_REQUEST ← Spend/Log ← CHECK_OUTPUT ← POST_PROVIDER
```

Built-in plugins:

| Plugin | Hooks | Description |
|--------|-------|-------------|
| WebhookNotifier | POST_REQUEST, ON_ERROR | Send request events to external webhooks |
| Anonymizer | PRE_PROVIDER, POST_PROVIDER | Redact PII before sending to provider |
| CostAlerter | POST_REQUEST | Alert when spend exceeds thresholds |
| JailbreakDetector | CHECK_INPUT | Detect prompt injection attempts |

Existing guardrails (OpenAI Moderation, PII Filter) are automatically wrapped via `GuardrailPluginAdapter` and participate in the plugin lifecycle.

## Security Model

### Data Protection

- API keys are SHA-256 hashed before storage — plaintext keys are never persisted
- All provider credentials stay in the gateway — users never see real API keys
- Security headers on all responses (X-Content-Type-Options, X-Frame-Options, HSTS, CSP)
- FIPS 140-2 compatible cryptographic operations

### Network Security

When `networkPolicy.enabled: true`, the chart creates a NetworkPolicy allowing:

- **Ingress**: HTTP (port 8000) from any source
- **Egress**: DNS (53), PostgreSQL (5432), Redis (6379), HTTPS (443) for LLM APIs

### Rate Limiting

- Default per-key limits: 60 RPM, 100,000 TPM
- Per-key overrides via the management API
- Redis required for distributed rate limiting across replicas

## Kubernetes Resources

The chart creates these resources:

| Resource | Condition | Purpose |
|----------|-----------|---------|
| Deployment | Always | Citadel application pods |
| Service (ClusterIP) | Always | Internal service |
| ConfigMap (`-env`) | Always | Non-sensitive environment variables |
| ConfigMap (`-models`) | Always | Models configuration |
| Secret | `existingSecret` not set | Sensitive credentials |
| ServiceAccount | `serviceAccount.create` | Pod identity |
| Ingress | `ingress.enabled` | External HTTP access |
| VirtualService | `istio.enabled` | Istio service mesh routing |
| HPA | `autoscaling.enabled` | Horizontal pod autoscaler |
| PDB | `podDisruptionBudget.enabled` | Disruption budget |
| NetworkPolicy | `networkPolicy.enabled` | Network access control |
| PostgreSQL (subchart) | `postgresql.enabled` | Bundled database |
| Redis (subchart) | `redis.enabled` | Bundled cache/rate limiting |

## Database Migrations

Migrations are managed automatically by the application at startup via `main.py:lifespan()`. The chart's init container (`wait-for-db`) only verifies database connectivity before the main container starts — it does not run migrations.

The migration runner is idempotent and tracks applied migrations in a `schema_migrations` table.

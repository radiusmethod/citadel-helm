# Citadel Helm Chart

Helm chart for [Citadel AI Gateway](https://github.com/radiusmethod/citadel) — a zero-trust AI gateway with spend tracking, guardrails, and OpenAI-compatible API.

Works as a standalone Kubernetes install **and** as a Big Bang package.

## Quick Start

```bash
helm install citadel oci://ghcr.io/radiusmethod/citadel-helm/citadel-chart \
  --set citadel.secretKey="$(openssl rand -hex 32)" \
  --set citadel.environment=development \
  --set citadel.devLoginEnabled=true \
  --set providers.openrouter.apiKey="sk-or-xxx"
```

> **Note**: The flags above enable evaluation mode (development environment with dev login). See [Evaluation Mode](#evaluation-mode) for details.

Port-forward and open the UI:

```bash
kubectl port-forward svc/citadel 8000:8000
open http://localhost:8000/ui
```

Click **Dev Login** to get started immediately — no OIDC setup required.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.10+

## Documentation

- **[Getting Started Guide](docs/GETTING_STARTED.md)** — End-to-end deployment walkthrough
- **[Configuration Reference](docs/CONFIGURATION.md)** — Complete values.yaml parameter reference
- **[Architecture Overview](docs/ARCHITECTURE_OVERVIEW.md)** — System design for operators

## Installation

### Evaluation Mode

For trying out Citadel before production deployment. Enables the dev login UI so you can create users and API keys without configuring OIDC.

```bash
helm install citadel oci://ghcr.io/radiusmethod/citadel-helm/citadel-chart \
  --set citadel.secretKey="change-me" \
  --set citadel.environment=development \
  --set citadel.devLoginEnabled=true \
  --set providers.openrouter.apiKey="sk-or-xxx"
```

This deploys Citadel with the bundled PostgreSQL, development mode, and dev login enabled.

### Production (external database)

```bash
helm install citadel oci://ghcr.io/radiusmethod/citadel-helm/citadel-chart \
  --set citadel.secretKey="$(openssl rand -hex 32)" \
  --set citadel.okta.enabled=true \
  --set citadel.okta.domain="company.okta.com" \
  --set citadel.okta.clientId="0oaXXX" \
  --set citadel.okta.clientSecret="secret" \
  --set citadel.okta.sessionSecret="$(openssl rand -hex 32)" \
  --set postgresql.enabled=false \
  --set externalDatabase.url="postgresql://user:pass@db-host:5432/citadel" \
  --set providers.openrouter.apiKey="sk-or-xxx"
```

### Big Bang

```yaml
# In your Big Bang values override:
addons:
  citadel:
    enabled: true
    values:
      istio:
        enabled: true
        citadel:
          gateways:
            - "istio-system/public"
          hosts:
            - "citadel.bigbang.dev"
      citadel:
        secretKey: "change-me"
      providers:
        openrouter:
          apiKey: "sk-or-xxx"
```

### Using an Existing Secret

If you manage secrets externally (Vault, Sealed Secrets, ESO), create a Kubernetes Secret with the expected keys and reference it:

```bash
helm install citadel oci://ghcr.io/radiusmethod/citadel-helm/citadel-chart \
  --set existingSecret=my-citadel-secrets
```

Required keys in your secret: `DATABASE_URL`, `SECRET_KEY`. Optional: `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, etc.

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image | `ghcr.io/radiusmethod/citadel` |
| `image.tag` | Image tag (defaults to appVersion) | `""` |
| `citadel.secretKey` | Session signing key (**required**) | `""` |
| `citadel.environment` | `development`, `staging`, or `production` | `production` |
| `citadel.devLoginEnabled` | Enable dev login bypass | `false` |
| `citadel.logLevel` | Log level | `INFO` |
| `citadel.autoProvisionUsers` | Auto-create users from headers | `true` |
| `citadel.guardrails.enabled` | Enable guardrails | `true` |
| `citadel.passthrough.enabled` | Enable API key passthrough | `true` |
| `citadel.plugins.enabled` | Enable plugin system | `true` |
| `citadel.okta.enabled` | Enable Okta OIDC | `false` |
| `providers.openrouter.apiKey` | OpenRouter API key | `""` |
| `providers.anthropic.apiKey` | Anthropic API key | `""` |
| `providers.vertexai.projectId` | GCP project ID | `""` |
| `providers.bedrock.enabled` | Enable AWS Bedrock | `false` |
| `postgresql.enabled` | Deploy bundled PostgreSQL | `true` |
| `postgresql.auth.password` | PostgreSQL password | `"citadel"` |
| `externalDatabase.url` | External PostgreSQL URL | `""` |
| `redis.enabled` | Deploy bundled Redis | `false` |
| `istio.enabled` | Enable Istio VirtualService | `false` |
| `ingress.enabled` | Enable Kubernetes Ingress | `false` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `existingSecret` | Use external Secret | `""` |

For the complete configuration reference, see [docs/CONFIGURATION.md](docs/CONFIGURATION.md).

## Client Configuration

### Claude Code

```bash
claude config set --global apiBaseUrl http://<citadel-host>:8000/v1
```

### OpenAI SDK / Python

```python
from openai import OpenAI
client = OpenAI(
    base_url="http://<citadel-host>:8000/v1",
    api_key="<your-citadel-api-key>",
)
```

### curl

```bash
curl http://<citadel-host>:8000/v1/chat/completions \
  -H "Authorization: Bearer <your-citadel-api-key>" \
  -H "Content-Type: application/json" \
  -d '{"model": "or-claude-sonnet-4.5 [EXTERNAL]", "messages": [{"role": "user", "content": "Hello"}]}'
```

## Database Migrations

Migrations run automatically inside the application on startup via the app's lifespan handler. The init container only waits for database connectivity before the main container starts — it does not run migrations.

The migration runner is idempotent and tracks state in a `schema_migrations` table.

## Uninstall

```bash
helm uninstall citadel
```

Note: The bundled PostgreSQL PVC is **not** deleted automatically. To fully clean up:

```bash
kubectl delete pvc data-citadel-postgresql-0
```

## License

MIT License — see [LICENSE](LICENSE) for details.

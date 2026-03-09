# Configuration Reference

Complete reference for all `values.yaml` parameters in the Citadel Helm chart.

## Core Settings

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `replicaCount` | Number of Citadel pod replicas | `1` | — |
| `image.repository` | Container image repository | `ghcr.io/radiusmethod/citadel` | — |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` | — |
| `image.tag` | Image tag (defaults to chart `appVersion`) | `""` | — |
| `nameOverride` | Override the chart name | `""` | — |
| `fullnameOverride` | Override the full resource name | `"citadel"` | — |
| `domain` | Base domain for Big Bang integration | `"bigbang.dev"` | — |
| `imagePullSecrets` | Image pull secrets for private registries | `[]` | — |

## Citadel Application

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `citadel.environment` | Application environment (`development`, `staging`, `production`) | `production` | `ENVIRONMENT` |
| `citadel.logLevel` | Log level (`DEBUG`, `INFO`, `WARNING`, `ERROR`) | `INFO` | `LOG_LEVEL` |
| `citadel.secretKey` | Secret key for signing sessions and tokens (**required**) | `""` | `SECRET_KEY` |
| `citadel.apiKeyPrefix` | Prefix for generated API keys | `"sk-citadel"` | `API_KEY_PREFIX` |
| `citadel.autoProvisionUsers` | Auto-create users on first authentication | `true` | `AUTO_PROVISION_USERS` |
| `citadel.devLoginEnabled` | Enable dev login bypass (disable in production) | `false` | `DEV_LOGIN_ENABLED` |

### Guardrails

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `citadel.guardrails.enabled` | Enable the guardrails system | `true` | `GUARDRAILS_ENABLED` |
| `citadel.guardrails.openaiModeration` | Enable OpenAI moderation API guardrail | `false` | `GUARDRAIL_OPENAI_MODERATION` |
| `citadel.guardrails.piiFilter` | Enable PII detection and filtering | `false` | `GUARDRAIL_PII_FILTER` |

### Passthrough

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `citadel.passthrough.enabled` | Enable passthrough mode for client-provided auth | `false` | `PASSTHROUGH_ENABLED` |

When passthrough is enabled, clients can send their own LLM provider credentials via the `Authorization` header while using a Citadel key in `x-citadel-api-key` for gateway authentication. Useful for Claude Code Max users.

### Plugins

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `citadel.plugins.enabled` | Enable the plugin system | `true` | `PLUGINS_ENABLED` |

### Okta / OIDC

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `citadel.okta.enabled` | Enable Okta OIDC authentication | `false` | — |
| `citadel.okta.domain` | Okta domain (e.g., `company.okta.com`) | `""` | `OKTA_DOMAIN` |
| `citadel.okta.clientId` | Okta OAuth client ID | `""` | `OKTA_CLIENT_ID` |
| `citadel.okta.clientSecret` | Okta OAuth client secret | `""` | `OKTA_CLIENT_SECRET` |
| `citadel.okta.sessionSecret` | Secret for encrypting UI sessions | `""` | `UI_SESSION_SECRET` |
| `citadel.okta.sessionExpiryHours` | Session expiry in hours | `24` | `UI_SESSION_EXPIRY_HOURS` |
| `citadel.okta.baseUrl` | Base URL for OIDC redirect (if behind proxy) | `""` | `UI_BASE_URL` |

## Rate Limiting

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `rateLimiting.defaultRpm` | Default requests per minute per API key | `60` | `DEFAULT_RATE_LIMIT_RPM` |
| `rateLimiting.defaultTpm` | Default tokens per minute per API key | `100000` | `DEFAULT_RATE_LIMIT_TPM` |

Rate limits can also be set per-key when creating API keys via the management API.

## Logging

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `logging.requestBody` | Store full request bodies in logs | `true` | `LOG_REQUEST_BODY` |
| `logging.responseBody` | Store full response bodies in logs | `true` | `LOG_RESPONSE_BODY` |

Enabling body logging significantly increases storage usage but provides a full audit trail.

## SocketZero JWT Authentication

Keyless authentication via signed JWTs from SocketZero Receiver.

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `socketzero.enabled` | Enable SocketZero JWT authentication | `false` | `TRUST_SOCKETZERO_JWT` |
| `socketzero.jwtPublicKey` | PEM-encoded RS256 public key for JWT verification | `""` | `SOCKETZERO_JWT_PUBLIC_KEY` |
| `socketzero.jwtHeader` | HTTP header containing the JWT | `"X-SocketZero-Jwt-Assertion"` | `SOCKETZERO_JWT_HEADER` |
| `socketzero.jwtAudience` | Expected JWT audience claim | `"citadel"` | `SOCKETZERO_JWT_AUDIENCE` |
| `socketzero.jwtIssuer` | Expected JWT issuer claim | `"socketzero"` | `SOCKETZERO_JWT_ISSUER` |

## LLM Providers

### OpenRouter

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `providers.openrouter.apiKey` | OpenRouter API key | `""` | `OPENROUTER_API_KEY` |
| `providers.openrouter.siteUrl` | Your site URL (for OpenRouter analytics) | `""` | `OPENROUTER_SITE_URL` |
| `providers.openrouter.appName` | Your app name (for OpenRouter analytics) | `""` | `OPENROUTER_APP_NAME` |

### Anthropic

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `providers.anthropic.apiKey` | Anthropic API key (enables `/v1/messages` endpoint) | `""` | `ANTHROPIC_API_KEY` |

### Vertex AI (Google Cloud)

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `providers.vertexai.projectId` | GCP project ID | `""` | `GCP_PROJECT_ID` |
| `providers.vertexai.location` | GCP region | `"us-central1"` | `GCP_LOCATION` |
| `providers.vertexai.credentialsJson` | Service account JSON credentials | `""` | `GOOGLE_APPLICATION_CREDENTIALS_JSON` |

### AWS Bedrock

| Parameter | Description | Default | Env Var |
|-----------|-------------|---------|---------|
| `providers.bedrock.enabled` | Enable AWS Bedrock provider | `false` | — |
| `providers.bedrock.region` | AWS region | `"us-east-1"` | `AWS_REGION` |
| `providers.bedrock.accessKeyId` | AWS access key ID | `""` | `AWS_ACCESS_KEY_ID` |
| `providers.bedrock.secretAccessKey` | AWS secret access key | `""` | `AWS_SECRET_ACCESS_KEY` |
| `providers.bedrock.useTaskRole` | Use IAM task role instead of explicit credentials | `false` | `AWS_USE_TASK_ROLE` |

## Secrets

| Parameter | Description | Default |
|-----------|-------------|---------|
| `existingSecret` | Name of an existing Kubernetes Secret to use instead of creating one | `""` |

When `existingSecret` is set, the chart skips creating its own Secret and references the named Secret instead. Required keys:

- `DATABASE_URL` — PostgreSQL connection string
- `SECRET_KEY` — Application signing secret

Optional keys:

- `OPENROUTER_API_KEY`
- `ANTHROPIC_API_KEY`
- `GOOGLE_APPLICATION_CREDENTIALS_JSON`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `OKTA_CLIENT_SECRET`
- `UI_SESSION_SECRET`
- `REDIS_URL`
- `SOCKETZERO_JWT_PUBLIC_KEY`

## Database

### Bundled PostgreSQL (Bitnami)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Deploy the bundled PostgreSQL subchart | `true` |
| `postgresql.auth.database` | Database name | `citadel` |
| `postgresql.auth.username` | Database username | `citadel` |
| `postgresql.auth.password` | Database password (change in production) | `"citadel"` |
| `postgresql.primary.persistence.size` | PVC size | `8Gi` |

For full Bitnami PostgreSQL options, see the [Bitnami PostgreSQL chart docs](https://github.com/bitnami/charts/tree/main/bitnami/postgresql).

### External Database

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalDatabase.url` | PostgreSQL connection URL | `""` |

Set `postgresql.enabled: false` when using an external database.

## Redis

### Bundled Redis (Bitnami)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Deploy the bundled Redis subchart | `false` |

For full Bitnami Redis options, see the [Bitnami Redis chart docs](https://github.com/bitnami/charts/tree/main/bitnami/redis).

### External Redis

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalRedis.url` | Redis connection URL | `""` |

## Networking

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Kubernetes Ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress host rules | see values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Istio / Big Bang

| Parameter | Description | Default |
|-----------|-------------|---------|
| `istio.enabled` | Enable Istio VirtualService | `false` |
| `istio.citadel.gateways` | Istio gateways | `["istio-system/public"]` |
| `istio.citadel.hosts` | VirtualService hosts | `["citadel.{{ .Values.domain }}"]` |
| `istio.mtls.mode` | mTLS mode | `STRICT` |

### NetworkPolicy

| Parameter | Description | Default |
|-----------|-------------|---------|
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `networkPolicy.additionalEgressRules` | Additional egress rules | `[]` |

When enabled, creates a NetworkPolicy allowing inbound HTTP (8000), and outbound DNS, PostgreSQL (5432), Redis (6379), and HTTPS (443) for LLM API calls.

## Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port | `8000` |

## ServiceAccount

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create a ServiceAccount | `true` |
| `serviceAccount.annotations` | ServiceAccount annotations (e.g., for IRSA) | `{}` |
| `serviceAccount.name` | Override ServiceAccount name | `""` |

## Pod Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podSecurityContext` | Pod-level security context | `{}` |
| `securityContext` | Container-level security context | `{capabilities: {drop: [ALL]}, runAsNonRoot: true, ...}` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `512Mi` |
| `resources.limits.cpu` | CPU limit | `1` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `nodeSelector` | Node selector labels | `{}` |
| `tolerations` | Pod tolerations | `[]` |
| `affinity` | Pod affinity rules | `{}` |
| `podLabels` | Additional pod labels | `{}` |
| `podAnnotations` | Additional pod annotations | `{}` |

## Autoscaling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HorizontalPodAutoscaler | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `70` |

## PodDisruptionBudget

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods during disruption | `1` |
| `podDisruptionBudget.maxUnavailable` | Maximum unavailable pods (alternative to minAvailable) | — |

## Escape Hatches

| Parameter | Description | Default |
|-----------|-------------|---------|
| `extraEnv` | Additional environment variables for the Citadel container | `[]` |
| `extraVolumes` | Additional volumes to add to the pod | `[]` |
| `extraVolumeMounts` | Additional volume mounts for the Citadel container | `[]` |

Example:

```yaml
extraEnv:
  - name: LANGFUSE_PUBLIC_KEY
    value: "pk-xxxx"
  - name: LANGFUSE_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: langfuse-credentials
        key: secret-key

extraVolumes:
  - name: custom-plugins
    configMap:
      name: my-plugins

extraVolumeMounts:
  - name: custom-plugins
    mountPath: /app/plugins/custom
```

## Models Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `modelsConfig` | Custom models.yaml content (replaces the built-in default) | — |

When not set, the chart uses a built-in models.yaml with curated models for Bedrock, OpenRouter, and Vertex AI.

Example override:

```yaml
modelsConfig: |
  settings:
    model_curation_enabled: true
    fallback_to_dynamic: false
  model_list:
    - model_name: my-claude-sonnet
      provider: openrouter
      provider_params:
        model: anthropic/claude-sonnet-4.5
    - model_name: my-gpt-4
      provider: openrouter
      provider_params:
        model: openai/gpt-4o
```

Each model entry requires:

- `model_name` — The name clients use when making requests
- `provider` — One of `openrouter`, `bedrock`, `vertex_ai`
- `provider_params.model` — The upstream model identifier

Optional compliance labels (e.g., `[CUI-APPROVED]`, `[EXTERNAL]`) can be appended to model names for organizational visibility.

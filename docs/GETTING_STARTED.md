# Getting Started with Citadel

This guide walks you through deploying Citadel AI Gateway on Kubernetes and configuring clients to use it.

## Prerequisites

- **Kubernetes cluster** (1.23+) with `kubectl` configured
- **Helm** 3.10+
- **At least one LLM provider API key** (OpenRouter recommended for quickest setup)

## Step 1: Install the Chart

### Add the Bitnami dependency repo

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### Install in evaluation mode

Evaluation mode enables dev login so you can explore the UI, create users, and generate API keys without configuring OIDC.

```bash
helm install citadel oci://ghcr.io/radiusmethod/citadel-helm/citadel \
  --set citadel.secretKey="$(openssl rand -hex 32)" \
  --set citadel.environment=development \
  --set citadel.devLoginEnabled=true \
  --set providers.openrouter.apiKey="sk-or-v1-YOUR-KEY"
```

**What each flag does:**

| Flag | Purpose |
|------|---------|
| `citadel.secretKey` | Signing key for sessions and tokens. Generate a random one. |
| `citadel.environment=development` | Enables debug-friendly behavior. |
| `citadel.devLoginEnabled=true` | Adds a "Dev Login" button to the UI — no OIDC required. |
| `providers.openrouter.apiKey` | Your OpenRouter API key. Get one at [openrouter.ai](https://openrouter.ai). |

This deploys Citadel with a bundled PostgreSQL instance. No external database needed.

## Step 2: Verify the Deployment

Wait for all pods to be ready:

```bash
kubectl get pods -l app.kubernetes.io/name=citadel -w
```

Check health endpoints:

```bash
# Port-forward to access Citadel locally
kubectl port-forward svc/citadel 8000:8000 &

# Liveness check
curl -s http://localhost:8000/health | jq .
# Expected: {"status": "healthy", "version": "0.1.0"}

# Readiness check (verifies database connectivity)
curl -s http://localhost:8000/health/ready | jq .
# Expected: {"status": "ready", ...}
```

## Step 3: Access the UI

Open the Citadel management UI:

```bash
open http://localhost:8000/ui
```

Click **Dev Login** to sign in as an admin user. From the UI you can:

- View available models
- Create API keys
- Monitor spend and usage
- Manage users

## Step 4: Create Your First API Key

1. In the UI, navigate to **API Keys**
2. Click **Create Key**
3. Give it a name (e.g., "my-dev-key")
4. Copy the generated key (starts with `sk-citadel-`)

Or via curl:

```bash
# Using dev login session — first get a session cookie
# Then create a key via the API
curl -s http://localhost:8000/api/keys \
  -H "Content-Type: application/json" \
  -d '{"name": "my-dev-key"}' \
  -b cookies.txt | jq .
```

## Step 5: Configure Claude Code

Claude Code can use Citadel as its API backend. Configure it with:

### Option A: Environment variables

```bash
export ANTHROPIC_BASE_URL="http://localhost:8000"
export ANTHROPIC_API_KEY="sk-citadel-YOUR-KEY"
```

Add to `~/.zshrc` or `~/.bashrc` for persistence.

### Option B: Claude Code settings

```bash
claude config set --global apiBaseUrl http://localhost:8000/v1
```

Then set your API key when prompted, or via:

```json
// ~/.claude/settings.json
{
  "apiBaseUrl": "http://localhost:8000/v1",
  "apiKey": "sk-citadel-YOUR-KEY"
}
```

### Option C: Passthrough mode (Claude Code Max / own Anthropic key)

If you have your own Anthropic subscription, route through Citadel for logging and guardrails while using your own auth:

```bash
export ANTHROPIC_BASE_URL="http://localhost:8000"
export ANTHROPIC_CUSTOM_HEADERS="x-citadel-api-key: Bearer sk-citadel-YOUR-KEY"
# Your own Anthropic OAuth/API key flows through the Authorization header automatically
```

### Verify Claude Code connection

```bash
claude "Say hello in exactly 5 words"
```

## Step 6: Configure Other Clients

### OpenAI SDK (Python)

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="sk-citadel-YOUR-KEY",
)

response = client.chat.completions.create(
    model="or-claude-sonnet-4.5 [EXTERNAL]",
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

### curl

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Authorization: Bearer sk-citadel-YOUR-KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "or-claude-sonnet-4.5 [EXTERNAL]",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Anthropic Messages API

Citadel also supports the native Anthropic Messages API format:

```bash
curl http://localhost:8000/v1/messages \
  -H "Authorization: Bearer sk-citadel-YOUR-KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Step 7: Provider Setup

Citadel supports multiple LLM providers. Configure the ones you need:

### OpenRouter (recommended for getting started)

Provides access to 200+ models through a single API key.

1. Sign up at [openrouter.ai](https://openrouter.ai)
2. Create an API key
3. Set `providers.openrouter.apiKey` in your Helm values

```yaml
providers:
  openrouter:
    apiKey: "sk-or-v1-YOUR-KEY"
    siteUrl: "https://your-company.com"   # optional
    appName: "Your App Name"               # optional
```

### Anthropic (Direct)

For direct access to Claude models (required for Claude Code passthrough and native Messages API):

```yaml
providers:
  anthropic:
    apiKey: "sk-ant-YOUR-KEY"
```

### Google Vertex AI

For Gemini models via Google Cloud:

```yaml
providers:
  vertexai:
    projectId: "your-gcp-project"
    location: "us-central1"
    credentialsJson: |
      { "type": "service_account", ... }
```

### AWS Bedrock

For models on AWS GovCloud:

```yaml
providers:
  bedrock:
    enabled: true
    region: "us-gov-west-1"
    accessKeyId: "AKIA..."
    secretAccessKey: "..."
    # Or use IAM task roles (EKS/ECS):
    # useTaskRole: true
```

## Step 8: Production Hardening

Before deploying to production, review this checklist:

### Security

- [ ] **Set a strong `secretKey`**: `openssl rand -hex 32`
- [ ] **Disable dev login**: `citadel.devLoginEnabled: false` (default)
- [ ] **Set environment to production**: `citadel.environment: production` (default)
- [ ] **Configure OIDC** (Okta) for user authentication
- [ ] **Use `existingSecret`** with a secrets manager (Vault, Sealed Secrets, ESO) instead of plaintext values
- [ ] **Change the PostgreSQL password** from the default `"citadel"`
- [ ] **Enable network policies**: `networkPolicy.enabled: true`
- [ ] **Enable TLS** via Ingress or Istio

### Reliability

- [ ] **Use an external database** for production: `postgresql.enabled: false` + `externalDatabase.url`
- [ ] **Enable autoscaling**: `autoscaling.enabled: true`
- [ ] **Enable PDB**: `podDisruptionBudget.enabled: true`
- [ ] **Set resource requests/limits** appropriate for your workload
- [ ] **Enable Redis** for rate limiting: `redis.enabled: true`

### Monitoring

- [ ] **Check health endpoints** are accessible to your monitoring stack
- [ ] **Review rate limits**: `rateLimiting.defaultRpm` and `rateLimiting.defaultTpm`
- [ ] **Consider enabling request body logging** for audit (`logging.requestBody: true`)

### Example production values

```yaml
citadel:
  secretKey: ""  # Use existingSecret instead
  environment: production
  devLoginEnabled: false
  okta:
    enabled: true
    domain: "company.okta.com"
    clientId: "0oaXXXXXX"

existingSecret: "citadel-secrets"  # Managed by Vault/ESO

postgresql:
  enabled: false
externalDatabase:
  url: ""  # Provided via existingSecret

redis:
  enabled: true

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5

podDisruptionBudget:
  enabled: true

networkPolicy:
  enabled: true

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: citadel.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: citadel-tls
      hosts:
        - citadel.your-domain.com
```

## Troubleshooting

### Pod stuck in CrashLoopBackOff

Check the logs:

```bash
kubectl logs -l app.kubernetes.io/name=citadel --previous
```

Common causes:
- **Missing `DATABASE_URL`**: Ensure PostgreSQL is ready or external DB URL is correct
- **Missing `SECRET_KEY`**: Set `citadel.secretKey` or provide it via `existingSecret`
- **Invalid provider credentials**: Check API keys are correct

### ImagePullBackOff

The container image may not be accessible:

```bash
kubectl describe pod -l app.kubernetes.io/name=citadel
```

- Verify image exists: `docker pull ghcr.io/radiusmethod/citadel-helm/citadel:0.1.0`
- For private registries, set `imagePullSecrets`

### Database connection failures

The init container waits up to 60 seconds for the database. If it times out:

```bash
# Check PostgreSQL pod status
kubectl get pods -l app.kubernetes.io/name=postgresql

# Check init container logs
kubectl logs citadel-XXXXX -c wait-for-db
```

### 401 Unauthorized from Claude Code

1. Verify your `sk-citadel-` key is correct and active
2. Check the key hasn't expired
3. Ensure `ANTHROPIC_BASE_URL` points to the correct Citadel instance
4. For passthrough mode, verify `citadel.passthrough.enabled: true`

### Models not showing up

1. Check the models ConfigMap: `kubectl get configmap -l app.kubernetes.io/name=citadel`
2. Verify provider API keys are set for the providers your models reference
3. For custom models, ensure `modelsConfig` is correctly formatted YAML

### Health check passes but /health/ready fails

This means the database is not connected. Check:

```bash
# PostgreSQL connectivity
kubectl exec -it citadel-XXXXX -- python -c "import asyncio, asyncpg, os; asyncio.run(asyncpg.connect(os.environ['DATABASE_URL']))"
```

# Journiv Helm Chart

This chart deploys Journiv with:
- the Journiv application container
- a PostgreSQL database
- a Valkey instance for caching and task broker configuration
- optional ingress exposure
- optional Gateway API HTTPRoute exposure
- persistent storage for app data and database state

## Prerequisites

- Kubernetes cluster
- Helm 3

## Install

```bash
helm install journiv ./charts/journiv
```

## Important values to change

Before deploying, update the following values in [values.yaml](values.yaml):
- `config.secretKey`: must be a strong secret
- `config.domainName`: the public hostname used by Journiv
- `ingress.hosts`: set your ingress hostname if you want external access
- `gatewayApi.hostnames` and `gatewayApi.parentRefs`: configure a Gateway API route if you use an API gateway

Journiv authentication-related defaults in this chart:
- `config.disableSignup`: `false` (maps to `DISABLE_SIGNUP=false`)
- `config.oidc.enabled`: `false` (maps to `OIDC_ENABLED=false`)
- `config.oidc.only`: `false` (maps to `OIDC_ONLY=false`)
- `config.oidc.autoProvision`: `true` (maps to `OIDC_AUTO_PROVISION=true`)
- `config.oidc.issuer`: `""` (maps to `OIDC_ISSUER`, e.g. `https://keycloak.example.com/realms/journiv`)
- `config.oidc.clientId`: `""` (maps to `OIDC_CLIENT_ID`)
- `config.oidc.clientSecret`: `""` (maps to `OIDC_CLIENT_SECRET`)
- `config.oidc.existingSecret`: `""` (when set, `OIDC_CLIENT_ID` and `OIDC_CLIENT_SECRET` are read from this Secret instead of plain values)
- `config.oidc.clientIdKey`: `OIDC_CLIENT_ID` (key name in `config.oidc.existingSecret`)
- `config.oidc.clientSecretKey`: `OIDC_CLIENT_SECRET` (key name in `config.oidc.existingSecret`)
- `config.oidc.redirectUri`: `""` (maps to `OIDC_REDIRECT_URI`, usually `https://your-domain.com/api/v1/auth/oidc/callback`)
- `config.oidc.scopes`: `openid email profile` (maps to `OIDC_SCOPES`)

Passwords and application secrets are generated dynamically during install or upgrade when they are not supplied explicitly. You can still override them by setting the relevant values or by providing your own Secret.

## Example

```bash
helm upgrade --install journiv ./charts/journiv \
  --set config.secretKey='replace-with-a-strong-secret' \
  --set config.domainName='journiv.example.com' \
  --set postgresql.auth.password='change-me-strongly'
```

To point Journiv at an external PostgreSQL instance, you can provide a connection URL plus an existing Secret that contains the username and password under your chosen keys:

```yaml
config:
  postgres:
    connectionString: "postgresql://db.example.com:5432/journiv"
    secretName: "my-db-secret"
    usernameKey: "username"
    passwordKey: "password"
```

To load OIDC client credentials from a Kubernetes Secret instead of values:

```yaml
config:
  oidc:
    enabled: true
    issuer: "https://keycloak.example.com/realms/journiv"
    existingSecret: "journiv-oidc"
    clientIdKey: "OIDC_CLIENT_ID"
    clientSecretKey: "OIDC_CLIENT_SECRET"
```

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
helm install journiv ./charts/journiv -f my-values.yaml
```

Supply the credentials described below in `my-values.yaml`, or reference existing Secrets.

## Important values to change

Before deploying, update the following values in [values.yaml](values.yaml):
- `config.secretKey`: must be a strong secret
- `postgresql.auth.password`: must be a strong database password
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

The chart requires stable credentials: set `config.secretKey` and `postgresql.auth.password`, or reference existing Secrets. Missing credentials cause a render error. The chart does not generate random credentials or look up live Secrets to populate the Secrets it manages, so repeated Helm renders produce identical Secret data. This avoids [Argo CD drift caused by random data](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#random-data). Secrets use base64-encoded `data`, matching the representation stored by Kubernetes; base64 is not encryption.

To use independently managed Secrets (for example, from an external secrets controller):

```yaml
config:
  existingSecret: journiv-app-credentials       # Must contain SECRET_KEY
  postgres:
    existingSecret: journiv-db-credentials     # Must contain POSTGRES_PASSWORD
```

These references are used by the application and bundled PostgreSQL without requiring cluster access during rendering. The chart does not create the referenced Secrets.

### Upgrading an existing installation to 0.1.4

Previous versions generated credentials when values were empty. Before syncing the updated chart, retrieve the current values and supply those same values as `config.secretKey` and `postgresql.auth.password` through your protected values workflow. For release `journiv`:

```bash
kubectl -n <namespace> get secret journiv-app -o jsonpath='{.data.SECRET_KEY}' | base64 --decode
kubectl -n <namespace> get secret journiv-postgres -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode
```

Adjust Secret names if you use a different release name or `fullnameOverride`. Keep these values private. Reusing the current application key and database password preserves credentials; changing the Secret alone does not change the password in an initialized PostgreSQL database. Once the values are supplied, sync the updated chart in Argo CD.

## Example

```bash
helm upgrade --install journiv ./charts/journiv \
  --set config.secretKey='replace-with-a-strong-secret' \
  --set config.domainName='journiv.example.com' \
  --set postgresql.auth.password='change-me-strongly'
```

To point Journiv at an external PostgreSQL instance, set its host and database plus an existing Secret that contains the username and password under your chosen keys:

```yaml
config:
  secretKey: "<current application SECRET_KEY>"
  postgres:
    host: "journiv-postgres-rw"
    database: "journiv"
    secretName: "my-db-secret"
    usernameKey: "username"
    passwordKey: "password"
postgresql:
  enabled: false
```

With bundled PostgreSQL disabled, `config.postgres.secretName` supplies the application credentials without requiring `postgresql.auth.password` (fixed in chart 0.1.5). Keep the current application `config.secretKey`, or set `config.existingSecret` to a separately managed Secret containing `SECRET_KEY`. Redis settings belong under `config.redis`.

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

## Validation

Run `python3 -m unittest discover -s tests` to check deterministic rendering, Secret encoding, required credentials, and existing Secret references. The tests require Helm and Python 3, with no extra Python packages.

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

# Hello World Example Helm Chart

A comprehensive Hello World example Helm chart that demonstrates various `values.yaml` capabilities and supports both Kubernetes Ingress and OpenShift Routes. This chart uses UBI9-based nginx for OpenShift compatibility.

## Features

- **Customizable Hello World Messages**: Override the default hello world string and greeting through values.yaml
- **OpenShift Compatibility**: Uses UBI9-based nginx image and includes OpenShift-compatible security contexts
- **Dual Route Support**: Supports both Kubernetes Ingress and OpenShift Routes
- **Comprehensive Configuration**: Demonstrates numerous Helm values.yaml capabilities
- **Production Ready**: Includes health checks, resource limits, HPA, and monitoring options
- **Security Focused**: OpenShift-compatible security contexts and non-root execution

## Installation

### Prerequisites

- Kubernetes 1.19+ or OpenShift 4.x+
- Helm 3.x

### Quick Start

```bash
# Basic installation
helm install my-hello-world ./hello-world-example

# With custom message
helm install my-hello-world ./hello-world-example \
  --set app.message="Welcome to My Custom App!" \
  --set app.greeting="Built with Helm and Love ❤️"

# With Ingress enabled (Kubernetes)
helm install my-hello-world ./hello-world-example \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=hello-world.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix

# With Route enabled (OpenShift)
helm install my-hello-world ./hello-world-example \
  --set route.enabled=true \
  --set route.host=hello-world.apps.example.com \
  --set route.tls.enabled=true
```

## Configuration

The following table lists the configurable parameters and their default values:

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.message` | The main hello world message | `"Hello World from Helm!"` |
| `app.greeting` | Additional greeting message | `"Welcome to our Kubernetes/OpenShift application!"` |
| `app.environment` | Environment name (dev, staging, prod) | `"development"` |
| `app.version` | Version tag for display | `"v1.0.0"` |

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `registry.redhat.io/ubi9/nginx-124` |
| `image.tag` | Container image tag | `"1-74"` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `8080` |
| `service.targetPort` | Container target port | `8080` |

### Ingress Configuration (Kubernetes)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts[0].host` | Hostname | `hello-world.local` |
| `ingress.hosts[0].paths[0].path` | Path | `/` |
| `ingress.hosts[0].paths[0].pathType` | Path type | `Prefix` |

### Route Configuration (OpenShift)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `route.enabled` | Enable OpenShift route | `false` |
| `route.host` | Route hostname | `""` |
| `route.tls.enabled` | Enable TLS | `false` |
| `route.tls.termination` | TLS termination type | `edge` |

### Autoscaling Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | CPU target percentage | `80` |

### Health Check Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `healthcheck.livenessProbe.enabled` | Enable liveness probe | `true` |
| `healthcheck.readinessProbe.enabled` | Enable readiness probe | `true` |

### HTML Customization

| Parameter | Description | Default |
|-----------|-------------|---------|
| `html.customCSS` | Custom CSS styles | See values.yaml |

## Usage Examples

### 1. Development Environment

```yaml
# values-dev.yaml
app:
  message: "Hello from Development!"
  environment: "development"
  version: "dev-latest"

replicaCount: 1

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 100m
    memory: 128Mi
```

```bash
helm install hello-dev ./hello-world-example -f values-dev.yaml
```

### 2. Production Environment with Ingress

```yaml
# values-prod.yaml
app:
  message: "Welcome to Our Production Application"
  greeting: "Serving customers worldwide since 2024"
  environment: "production"
  version: "v2.1.0"

replicaCount: 3

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

### 3. OpenShift Deployment with Route

```yaml
# values-openshift.yaml
app:
  message: "Hello from OpenShift!"
  environment: "openshift-production"

route:
  enabled: true
  host: hello-world.apps.openshift.example.com
  tls:
    enabled: true
    termination: edge
    insecureEdgeTerminationPolicy: Redirect

# OpenShift-specific security context (automatically set)
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
```

### 4. Multi-Environment with Extra Variables

```yaml
# values-staging.yaml
app:
  message: "Staging Environment"
  environment: "staging"
  version: "v2.0.0-rc1"

extraEnvVars:
  - name: API_ENDPOINT
    value: "https://api-staging.example.com"
  - name: DEBUG_MODE
    value: "true"
  - name: FEATURE_FLAGS
    value: "new-ui,beta-features"

html:
  customCSS: |
    body {
      background: linear-gradient(135deg, #ff7b7b 0%, #667eea 100%);
      font-family: 'Courier New', monospace;
    }
    .container {
      border: 3px dashed #fff;
    }
    h1:after {
      content: " 🚧";
    }
```

## Testing

Run the Helm tests to verify the deployment:

```bash
# Install the chart
helm install test-release ./hello-world-example

# Run tests
helm test test-release

# Check test results
kubectl logs test-release-hello-world-example-test-connection
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade my-hello-world ./hello-world-example \
  --set app.message="Updated Hello World!" \
  --set app.version="v2.0.0"

# Check rollout status
kubectl rollout status deployment/my-hello-world-hello-world-example
```

## Uninstalling

```bash
helm uninstall my-hello-world
```

## Values.yaml Capabilities Demonstrated

This chart showcases numerous Helm values.yaml capabilities:

1. **Simple Value Substitution**: Basic string and number values
2. **Conditional Rendering**: Using `if/else` statements for optional resources
3. **Loops and Ranges**: Iterating over arrays and maps
4. **Helper Templates**: Reusable template functions
5. **Default Values**: Providing sensible defaults with override capability
6. **Nested Objects**: Complex configuration structures
7. **Environment-specific Configuration**: Different values for different environments
8. **Resource Management**: CPU/memory limits and requests
9. **Security Contexts**: OpenShift-compatible security settings
10. **Health Checks**: Configurable liveness and readiness probes
11. **Networking**: Service, Ingress, and Route configurations
12. **Scaling**: HPA configuration with resource-based scaling
13. **Monitoring**: Prometheus metrics configuration
14. **Custom Content**: Dynamic HTML generation with custom CSS
15. **Extra Resources**: Additional volumes, volume mounts, and environment variables

## OpenShift Compatibility

This chart is designed to work seamlessly on OpenShift:

- Uses Red Hat UBI9-based nginx image
- Includes OpenShift-compatible security contexts
- Supports OpenShift Routes alongside Kubernetes Ingress
- Runs as non-root user
- Follows OpenShift security best practices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This Helm chart is open source and available under the MIT License.

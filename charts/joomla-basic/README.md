<!--- app-name: Joomla! -->
<!-- markdownlint-disable-next-line MD026 -->
# Basic Helm chart for Joomla

[Joomla!](http://www.joomla.org/)

## Limitations

ℹ️ Note:
This Joomla Helm chart is actively under development. While created carefully, it likely contains mistakes or unclear configurations. Please verify settings before deployment and feel free to contribute suggestions or improvements.

⚠️ Notice:
This Helm chart is created to the best of my current knowledge but may contain errors or incomplete configurations. Documentation might not cover all scenarios fully. Use with care, and contributions or feedback are welcome!

### Images
```txt
Dockerhub Joomla  official image tag: "php8.3-apache" (https://hub.docker.com/_/joomla)
Dockerhub MySQL   official image tag: "8.0" (https://hub.docker.com/_/mysql)
```

### Charts and subcharts
```txt
Joomla
Sub-charts:
  MySQL
  Common
```

#### CLI
Enable CLI for automatic installer (default false)
```yaml
cli:
  enabled: true
```

### 🛠️ **Init Containers**

These containers perform initial setup tasks before the main Joomla container starts:

| Container Name     | Description / Task                                                                       | Condition                        | Log file                                 |
|--------------------|------------------------------------------------------------------------------------------|----------------------------------|------------------------------------------|
| joomla-bootstrap | Copies Joomla files from `/usr/src/joomla/` to `/var/www/html/` for CLI installer setup. | If CLI installer enabled (`cli.enabled: true`) | `/var/log/joomla-bootstrap.log` |
| joomla-installer | Runs Joomla’s automated CLI installer.                                                   | If CLI installer enabled (`cli.enabled: true`) | `/var/log/cli-installer.log`    |
| mysql-check      | Checks MySQL availability by testing database port readiness.                            | Always runs                      | `/var/log/mysql-check.log`               |


### Global Database settings used by Joomla and MySQL subcharts
```yaml
global:
  dbname: "joomla_db"             # Database name for Joomla
  dbuser: "joomla"                # Username for Joomla database user
  dbpassword: "dbpassword"        # Password for Joomla database user
  joomlaDbHost: "joomla-mysql"    # Hostname of the MySQL server
  joomlaDbPort: "3306"            # MySQL server port
```

### Joomla CLI Installation (optional)
Reference: Joomla CLI Installation Guide https://jdocmanual.org/en/jdocmanual?article=user/command-line-interface/joomla-cli-installation

CLI installation enables automatic initial setup of Joomla. If cli.enabled: true, Joomla will skip the web-based installation wizard and perform a fully automatic install based on these settings:

```yaml
cli:
  enabled: true                       # Enable automatic Joomla installation via CLI (default: false)
  siteName: "Joomla Basic"            # Website name as it appears on Joomla
  adminUser: "Karen"                  # Real name of Super User account
  adminUsername: "karen126"           # Login username for Super User
  adminPassword: "Garbage1n0ut"       # Super User account password (change for security!)
  adminEmail: "karens@mail.dk"        # Email address for Super User account
  dbType: "mysqli"                    # Database type: mysql (PDO), mysqli, pgsql
  dbPrefix: "w7amf_"                  # Table prefix (leave blank for auto-generation)
  dbEncryption: "0"                   # DB encryption: 0=None, 1=One way, 2=Two way
  publicFolder: ""                    # Public folder path (relative or absolute; leave empty for default)

```

### updateStrategy
This Helm chart uses the update strategy Recreate by default:

Recreate (default):
>Terminates all running pods before creating new ones.
This strategy is recommended when using Persistent Volume Claims (PVCs) with access mode ReadWriteOnce (RWO), as it ensures safe detachment and reattachment of storage, preventing conflicts. The downside is brief downtime between updates, which is acceptable for most standard Joomla installations.

Alternative strategy (if minimal downtime is required):

RollingUpdate (optional):
> Gradually replaces pods one by one, minimizing downtime. However, with PVCs using RWO mode, RollingUpdate can result in pod scheduling errors or conflicts during updates, since two pods cannot attach to the same volume simultaneously. Use this only if your storage configuration supports it (e.g., PVCs with ReadWriteMany (RWX)).

```yaml
  updateStrategy:
    type: Recreate         # default recommended
    # type: RollingUpdate  # only use if PVC supports RWX access mode
```

### joomla persistence
Persistence (enabled: true) ensures data is retained across pod restarts. Disabling results in data loss upon pod deletion.

```yaml
  enabled: true
  storageClass: "local-path"
  accessModes: "ReadWriteOnce"
```

### joomla service (default)
type: LoadBalancer exposes Joomla externally through a cloud provider's load balancer. Consider ClusterIP or NodePort for internal/test environments.

```yaml
  type: LoadBalancer
  port: 80
  #clusterIP:
  loadBalancerIP: ""
```

### ingress (not tested)
Ingress configuration depends heavily on the ingress controller installed in your Kubernetes cluster (e.g., Traefik, NGINX).

⚠️ Currently untested:
Ingress support hasn't yet been tested for this Helm chart.
Contributions of tested configurations and examples for different ingress controllers are highly encouraged.

```yaml
ingress:
  enabled: false
  className: ""       # e.g., "nginx"
  annotations: {}     # controller-specific annotations
  hosts:
    - host: example.com
      paths:
        - path: /
          pathType: Prefix
  tls: []
```

### Joomla probes
Probes let Kubernetes monitor the health and availability of your Joomla pods.
|Probe Type     |  Default   |  Purpose / Consequences   |
| --- | --- | --- |
| startupProbe    | ❌ Disabled    | Checks if the container has started successfully. A failing startupProbe triggers container restarts during initial pod startup.  |
| livenessProbe   | ✅ Enabled     | Checks regularly if the container is running correctly. A failing livenessProbe will cause Kubernetes to restart the pod.   |
| readinessProbe  | ❌ Disabled    | Checks if the pod is ready to serve traffic. A failing readinessProbe temporarily removes the pod from load balancing until the probe succeeds again, without restarting it.    |

Default Probe Values:
```yaml
startupProbe:
  enabled: false
  initialDelaySeconds: 600   # Wait 600 sec before first probe (default: 0)
  periodSeconds: 15          # Check every 15 sec (default: 10)
  timeoutSeconds: 5          # Must respond within 5 sec (default: 1)
  successThreshold: 6        # Successes required to mark healthy (default: 1)
  failureThreshold: 1        # Failures required to mark unhealthy (default: 3)

livenessProbe:
  enabled: true
  initialDelaySeconds: 600   # Wait 600 sec before first probe
  periodSeconds: 10          # Check every 10 sec
  timeoutSeconds: 5          # Must respond within 5 sec
  failureThreshold: 6        # Failures required to restart pod
  successThreshold: 1        # Successes required to confirm healthy

readinessProbe:
  enabled: false
  initialDelaySeconds: 30    # Wait 30 sec before first probe
  periodSeconds: 5           # Check every 5 sec
  timeoutSeconds: 3          # Must respond within 3 sec
  failureThreshold: 6        # Failures required to remove from service endpoints
  successThreshold: 1        # Successes required to confirm ready
```

### tolerations (default enabled)
Default tolerations allow scheduling on nodes labeled gray or orange. Modify as needed to match your node labels.
```yaml
    - key: "key1"
      operator: "Equal"
      value: "gray"
      effect: "NoSchedule"
    - key: "key1"
      operator: "Equal"
      value: "orange"
      effect: "NoSchedule"
```

### affinity (default enabled)
Affinity rules control scheduling preferences for Kubernetes nodes. Default settings prefer nodes labeled green, then pink. Adjust or disable based on your cluster.
```console
Enable(✅)/Disable(❌)
preferred (✅) required (❌)  : preferred
preferred (❌) required (✅)  : required
preferred (✅) required (✅)  : preferred
preferred (❌) required (❌)  : preferred
```
Explanation: If preferred and required is both enabled (by mistake), then preferred is chosen as both cannot be enabled at the same time.
```yaml
preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
    key: color
    operator: In
    values:
        - pink
    - weight: 5
    key: color
    operator: In
    values:
        - green
requiredDuringSchedulingIgnoredDuringExecution:
    - key: color
    operator: In
    values:
        - green
```
### 🐬 MySQL Configuration
This chart deploys MySQL using the official Docker image.

### image
Specifies the MySQL Docker image and tag. See Docker Hub: MySQL for available tags (https://hub.docker.com/_/mysql).

```yaml
  image:
    repository: mysql
    tag: "8.0"
```    
### Resource Configuration
Configure CPU and memory resources for the MySQL container. Adjust resource values according to your cluster capacity and MySQL workload requirements.

``` yaml
resources:
  enableLimit: false           # Limits disabled by default to prevent unintended pod restarts
  limits:
    memory: "768Mi"
    cpu: "500m"
  enableRequest: true          # Requests enabled by default for scheduling
  requests:
    memory: "512Mi"
    cpu: "250m"
```
⚠️ Recommendation:
Start without resource limits (enableLimit: false) and monitor MySQL resource usage over time.
Once stable usage metrics are available, set appropriate limits. Setting restrictive limits prematurely can cause unexpected pod restarts, affecting Joomla’s stability.

### MySQL Authentication

Root Password

Sets the root user password for MySQL (MYSQL_ROOT_PASSWORD).  
This value must be provided. Ensure it's secure.

Ref.: MySQL Documentation - MYSQL_ROOT_PASSWORD (https://dev.mysql.com/doc/refman/8.0/en/environment-variables.html)
```yaml
  auth:
    rootdbpassword: "bxJK8Q1wd9ZFeDO8bOKbQ9CN"
```    
### MySQL Timezone
Defines the default timezone used by MySQL. Set this to match your local or required timezone.

Ref.: MySQL Documentation - TZ (https://dev.mysql.com/doc/refman/8.0/en/environment-variables.html)
```yaml
  timezone: "Europe/Copenhagen"
```

### Persistence
Persistence ensures data is retained across pod restarts. Disabling results in data loss upon pod deletion. Size describe the initial size (not max)

```yaml
  enabled: true
  storageClass: "local-path"
  accessModes: "ReadWriteOnce"
  size: 2Gi                          # A PVC of 2GB will be created
```
### tolerations (deafult enabled)
Default tolerations allow scheduling the MySQL pod on nodes labeled gray or orange. Modify as needed to match your node labels.
```yaml
  tolerationsEnabled: true
  tolerations:
    - key: "key1"
      operator: "Equal"
      value: "gray"
      effect: "NoSchedule"
    - key: "key1"
      operator: "Equal"
      value: "orange"
      effect: "NoSchedule"
```
### affinity (default preferred enabled)
Affinity rules control scheduling preferences for Kubernetes nodes. Default settings prefer nodes labeled green 5x than nodes labeled pink. Adjust or disable based on your cluster labels.
```console
Enable(✅)/Disable(❌)
preferred (✅) required (❌)  : preferred
preferred (❌) required (✅)  : required
preferred (✅) required (✅)  : preferred
preferred (❌) required (❌)  : preferred
```
Explanation: If preferred and required is both enabled (by mistake), then preferred is chosen as both cannot be enabled at the same time.
```yaml
preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
    key: color
    operator: In
    values:
        - pink
    - weight: 5
    key: color
    operator: In
    values:
        - green
requiredDuringSchedulingIgnoredDuringExecution:
    - key: color
    operator: In
    values:
        - green
```
### MySQL livenessProbe
Probes let Kubernetes monitor the health and availability of your MySQL pod.
|Probe Type     |  Default   |  Purpose / Consequences   |
| --- | --- | --- |
| livenessProbe   | ✅ Enabled     | Checks regularly if the container is running correctly. A failing livenessProbe will cause Kubernetes to restart the pod.   |


Default Probe Values:
```yaml
livenessProbe:
  enabled: true              # disable/enable MySQL livenessProbe
  initialDelaySeconds: 600   # Wait 600 sec before first probe
  periodSeconds: 10          # Check every 10 sec
  timeoutSeconds: 5          # Must respond within 5 sec
  failureThreshold: 6        # Failures required to restart pod
  successThreshold: 1        # Successes required to confirm healthy
```

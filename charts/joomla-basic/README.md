<!--- app-name: Joomla! -->
<!-- markdownlint-disable-next-line MD026 -->
# Basic Helm chart for Joomla

[Joomla!](http://www.joomla.org/)

## Limitations
```txt
ℹ️ Note:
This Joomla Helm chart is actively under development. While created carefully, it likely contains mistakes or unclear configurations. Please verify settings before deployment and feel free to contribute suggestions or improvements.

⚠️ Notice:
This Helm chart is created to the best of my current knowledge but may contain errors or incomplete configurations. Documentation might not cover all scenarios fully. Use with care, and contributions or feedback are welcome!
```

### Images
```console
Dockerhub Joomla  official image tag: "php8.3-apache" (https://hub.docker.com/_/joomla)
Dockerhub MySQL   official image tag: "8.0" (https://hub.docker.com/_/mysql)
```

### Charts
```console
Joomla
Sub-charts:
  MySQL
  Common
```
#### CLI
```console
Enable CLI for automatic installer (default false)
```
```yaml
cli:
  enabled: true
```

### initContainers
```console
0) joomla-bootstrap (If CLI install is enabled):
  joomla-bootstrap will copy files from  /usr/src/joomla/ to /var/www/html/. Necessary for the CLI installer to run correctly.
  Log file: /var/log/joomla-bootstrap.log
1) joomla-installer (If CLI install is enabled):
  Will run the actual Joomla CLI installer.
  Log file: /var/log/cli-installer.log
2) mysql-check:
  Test MYSQL port for availability before going ahead and installing Joomla.
  Log file: /var/log/mysql-check.log
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
```console
Reference: Joomla CLI Installation Guide https://jdocmanual.org/en/jdocmanual?article=user/command-line-interface/joomla-cli-installation

CLI installation enables automatic initial setup of Joomla. If cli.enabled: true, Joomla will skip the web-based installation wizard and perform a fully automatic install based on these settings:
```
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

### updateStrategy (default)
```console
```
```yaml
  type: Recreate
```

### joomla persistence (default)
```console
Persistence (enabled: true) ensures data is retained across pod restarts. Disabling results in data loss upon pod deletion.
```
```yaml
  enabled: true
  storageClass: "local-path"
  accessModes: "ReadWriteOnce"
```

### joomla service (default)
```console
type: LoadBalancer exposes Joomla externally through a cloud provider's load balancer. Consider ClusterIP or NodePort for internal/test environments.
```
```yaml
  type: LoadBalancer
  port: 80
  #clusterIP:
  loadBalancerIP: ""
```

### ingress (not tested)
```console
Ingress configuration placeholder (currently untested). Contributions or tests are encouraged.
```

### Joomla probes (default)
```console
```
```yaml
  startupProbe
  livenessProbe (enabled)
  readinessProbe
```

### tolerations (default enabled)
```console
Default tolerations allow scheduling on nodes labeled gray or orange. Modify as needed to match your node labels.
```
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
```console
Affinity rules control scheduling preferences for Kubernetes nodes. Default settings prefer nodes labeled green, then pink. Adjust or disable based on your cluster.

Enable(+)/Disable(-)
Both preferred and required. 
preferred (+) required (-) : preferred
preferred (-) required (+) : required
preferred (+) required (+) : preferred
preferred (-) required (-) : preferred
```
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
### MySQL (default)
```console
```

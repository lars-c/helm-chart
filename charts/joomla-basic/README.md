# Joomla Basic Helm Chart

`joomla-basic` is a small Helm chart for running Joomla with a bundled MySQL
subchart. It is intended for homelab and learning use, especially clusters that
use simple storage such as `local-path` and expose services through something
like MetalLB.

This chart is not production-ready without careful review. It includes default
passwords, fixed resource names, simple single-pod workloads, and some values
that are present in `values.yaml` but are not wired into the rendered manifests.

Chart metadata:

| Field | Value |
| --- | --- |
| Chart name | `joomla-basic` |
| Chart version | `0.4.3` |
| App version | `6.0.0` |

## What this chart deploys

The parent chart deploys Joomla using the official `joomla:php8.3-apache`
image. By default it also runs init containers that copy Joomla files into the
persistent volume, wait for MySQL, and run the Joomla CLI installer.

Rendered parent resources:

| Resource | Name | Purpose |
| --- | --- | --- |
| `Deployment` | `joomla` | Joomla Apache/PHP container plus optional installer init containers |
| `Service` | `joomla` | Exposes Joomla on `.Values.service.port` |
| `PersistentVolumeClaim` | `joomla-pv-claim` | Stores `/var/www/html` |
| `Secret` | `joomla-secret` | Stores the Joomla database password |
| `ConfigMap` | `joomla` | Created, but currently only contains commented sample keys |

The bundled MySQL subchart deploys:

| Resource | Name | Purpose |
| --- | --- | --- |
| `Deployment` | `joomla-mysql` | Single MySQL pod |
| `Service` | `.Values.global.joomlaDbHost` | Headless MySQL service, default `joomla-mysql` |
| `PersistentVolumeClaim` | `joomla-mysql-pv-claim` | Stores `/var/lib/mysql` |
| `Secret` | `mysql-secret` | Stores database user and root passwords |
| `ConfigMap` | `mysql` | Created, but currently only contains commented sample keys |
| `NetworkPolicy` | `mysql-network-policy` | Allows MySQL ingress from pods labeled `app: joomla` |

## Requirements

- Kubernetes cluster with support for `Deployment`, `Service`, `Secret`,
  `ConfigMap`, `PersistentVolumeClaim`, and `NetworkPolicy`.
- Helm 3.
- A storage class matching the configured values. The defaults use
  `local-path`.
- A way to access a `LoadBalancer` service if you keep the default Joomla
  service type. In a homelab, this is commonly MetalLB.

## Installation

From this chart directory:

```sh
helm dependency build .
helm lint .
helm template joomla .
helm install joomla .
```

Common lifecycle commands:

```sh
helm upgrade joomla .
helm uninstall joomla
```

There are no Helm test templates in this chart at the moment, so `helm test`
does not run any chart-provided checks.

```sh
helm test joomla
```

For a safer first install, create a small override file and change at least the
Joomla admin password, database password, MySQL root password, service type, and
storage class.

## Configuration

Important values from `values.yaml`:

| Value | Default | What it controls |
| --- | --- | --- |
| `global.dbname` | `joomla_db` | Joomla/MySQL database name |
| `global.dbuser` | `joomla` | Joomla/MySQL database user |
| `global.dbpassword` | `dbpassword` | Joomla/MySQL database password |
| `global.joomlaDbHost` | `joomla-mysql` | MySQL service name used by Joomla |
| `global.joomlaDbPort` | `3306` | MySQL container port and Joomla connection port |
| `image.repository` | `joomla` | Joomla image repository |
| `image.tag` | `php8.3-apache` | Joomla image tag |
| `image.pullPolicy` | `IfNotPresent` | Joomla image pull policy |
| `cli.enabled` | `true` | Enables Joomla bootstrap, MySQL wait, and CLI installer init containers |
| `cli.siteName` | `Joomla Basic` | Joomla site name used by the CLI installer |
| `cli.adminUser` | `Karen` | Joomla Super User display name |
| `cli.adminUsername` | `karen126` | Joomla Super User login name |
| `cli.adminPassword` | `Garbage1n0ut` | Joomla Super User password |
| `cli.adminEmail` | `karens@mail.dk` | Joomla Super User email |
| `cli.dbType` | `mysqli` | Database driver passed to Joomla installer |
| `cli.dbPrefix` | `w7amf_` | Joomla table prefix. Empty string generates a random prefix at template time |
| `cli.dbEncryption` | `0` | Joomla DB encryption mode. Must be `0`, `1`, or `2` |
| `service.type` | `LoadBalancer` | Joomla service type |
| `service.port` | `80` | Joomla service port and Joomla container port |
| `service.loadBalancerIP` | `""` | Optional fixed load balancer IP for `LoadBalancer` services |
| `resources.enableRequest` | `true` | Enables Joomla resource requests |
| `resources.enableLimit` | `false` | Enables Joomla resource limits |
| `mysql.image.repository` | `mysql` | MySQL image repository |
| `mysql.image.tag` | `8.0` | MySQL image tag |
| `mysql.auth.rootdbpassword` | `bxJK8Q1wd9ZFeDO8bOKbQ9CN` | MySQL root password |
| `mysql.timezone` | `Europe/Copenhagen` | `TZ` environment variable in the MySQL container |

Example override:

```yaml
global:
  dbname: joomla_db
  dbuser: joomla
  dbpassword: "change-this-db-password"

cli:
  siteName: "Homelab Joomla"
  adminUser: "Admin"
  adminUsername: "admin"
  adminPassword: "change-this-admin-password"
  adminEmail: "admin@example.test"

service:
  type: LoadBalancer
  loadBalancerIP: "192.168.1.50"

persistence:
  storageClass: "local-path"
  size: 1Gi

mysql:
  auth:
    rootdbpassword: "change-this-root-password"
  persistence:
    storageClass: "local-path"
    size: 2Gi
```

Install with overrides:

```sh
helm install joomla . -f my-values.yaml
```

## Persistence

The chart always renders PVC-backed volumes for Joomla and MySQL.

Joomla stores `/var/www/html` in `joomla-pv-claim`:

```yaml
persistence:
  enabled: true
  storageClass: "local-path"
  accessModes: "ReadWriteOnce"
  size: 1Gi
```

MySQL stores `/var/lib/mysql` in `joomla-mysql-pv-claim`:

```yaml
mysql:
  persistence:
    storageClass: "local-path"
    accessModes: "ReadWriteOnce"
    size: 2Gi
```

The rendered Deployments use `Recreate`, which is a practical default for
single-pod workloads using `ReadWriteOnce` storage. It avoids trying to attach
the same PVC to two Joomla pods during an update.

Important persistence caveats:

- `persistence.enabled` exists in values, but the current PVC and Deployment
  templates do not conditionally disable persistence.
- `persistence.existingClaim` exists in values, but the Deployment always mounts
  `joomla-pv-claim`.
- `persistence.hostPath` and `persistence.annotations` exist in values, but are
  not used by the current templates.

## Secrets

The chart creates two Kubernetes Secrets:

- `joomla-secret` with key `dbpassword`.
- `mysql-secret` with keys `dbpassword` and `rootdbpassword`.

`global.dbpassword` is shared between Joomla and MySQL. It is used for:

- `JOOMLA_DB_PASSWORD` in the Joomla container.
- `MYSQL_PASSWORD` in the MySQL container.
- `--db-pass` in the Joomla CLI installer.

`mysql.auth.rootdbpassword` becomes `MYSQL_ROOT_PASSWORD` in the MySQL
container.

These values are stored as Kubernetes Secret data, but they are still plain
values in `values.yaml` unless you supply them another way. For a homelab this
may be acceptable while learning; for anything serious, use your normal secret
management workflow and avoid committing real passwords.

## Services and access

Joomla is exposed through a Service named `joomla`.

Default service values:

```yaml
service:
  type: LoadBalancer
  port: 80
  loadBalancerIP: ""
```

With the default `LoadBalancer` type, get the address with:

```sh
kubectl get svc joomla
```

If your cluster does not provide load balancers, set `service.type` to
`ClusterIP` and use port-forwarding:

```sh
helm upgrade --install joomla . --set service.type=ClusterIP
kubectl port-forward svc/joomla 8080:80
```

Then open `http://localhost:8080`.

MySQL is exposed inside the cluster by a headless Service named from
`global.joomlaDbHost`, default `joomla-mysql`. The MySQL Service template
currently exposes port `3306`.

## Probes

Joomla probe values:

| Probe | Default | Implementation |
| --- | --- | --- |
| `startupProbe` | Disabled | HTTP GET `/index.php` on port `joomla` |
| `livenessProbe` | Enabled | TCP socket check on port `joomla` |
| `readinessProbe` | Disabled | HTTP GET `/index.php` on port `joomla` |

Default Joomla liveness settings:

```yaml
livenessProbe:
  enabled: true
  initialDelaySeconds: 600
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1
```

MySQL has a TCP liveness probe on port `mysql` when
`mysql.livenessProbe.enabled` is true.

```yaml
mysql:
  livenessProbe:
    enabled: true
    initialDelaySeconds: 600
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 6
    successThreshold: 1
```

The long default initial delays are friendly to slow homelab nodes and first
boot installs.

## Scheduling

Both Joomla and MySQL support tolerations and node affinity in their rendered
Deployment templates.

Default Joomla tolerations:

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

Default Joomla affinity prefers nodes with `color=pink` and `color=green`:

```yaml
affinity:
  enabled: true
  preferred: true
  required: false
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 10
      key: color
      operator: In
      values:
        - pink
    - weight: 20
      key: color
      operator: In
      values:
        - green
```

The MySQL subchart has its own `mysql.tolerationsEnabled`,
`mysql.tolerations`, and `mysql.affinity` values.

Note: `nodeSelector` exists in values, but the current Deployment templates do
not render a node selector.

## Troubleshooting

### Joomla pod is stuck in init

Check init container logs:

```sh
kubectl logs deploy/joomla -c joomla-bootstrap
kubectl logs deploy/joomla -c mysql-check
kubectl logs deploy/joomla -c cli-installer
```

Likely causes:

- MySQL is not running or not reachable at `global.joomlaDbHost`.
- PVC provisioning is slow or failed.
- The CLI installer values are invalid.
- The database password values do not match between Joomla and MySQL.

### MySQL pod is pending

Check events and PVCs:

```sh
kubectl get pvc
kubectl describe pod -l app=mysql
```

Likely causes:

- `mysql.persistence.storageClass` does not exist.
- The node affinity or tolerations do not match your nodes.
- The cluster has too little CPU or memory for the configured requests.

### Joomla service has no external IP

```sh
kubectl get svc joomla
```

Likely causes:

- The cluster has no LoadBalancer implementation.
- MetalLB or your load balancer controller is not configured.
- `service.loadBalancerIP` is set to an address the controller cannot allocate.

Use `ClusterIP` plus `kubectl port-forward` if you just want quick local access.

### Joomla keeps restarting after a long delay

The default Joomla liveness probe starts after 600 seconds. If restarts begin
after that point, check:

```sh
kubectl describe pod -l app=joomla
kubectl logs deploy/joomla -c joomla
```

Likely causes:

- Joomla/Apache is not listening on the configured port.
- The Joomla install did not complete.
- The mounted Joomla files or `configuration.php` are missing or invalid.

### Database connection errors in Joomla

Check:

- `global.dbname`
- `global.dbuser`
- `global.dbpassword`
- `global.joomlaDbHost`
- `global.joomlaDbPort`

Also confirm that the MySQL pod has initialized successfully and that the
`mysql-network-policy` is not blocking your expected traffic pattern.

## Limitations

- This chart is for homelab and learning use. Review it before using it for any
  exposed, important, or production workload.
- Workload names are fixed as `joomla` and `joomla-mysql`; release names do not
  prefix those resources.
- The chart deploys single Joomla and MySQL pods. It does not implement Joomla
  horizontal scaling or MySQL replication.
- Default credentials are present in `values.yaml` and must be changed.
- Ingress values exist in `values.yaml`, but no Ingress template is currently
  present in the parent chart.
- `updateStrategy.type` exists in values, but the Deployment template currently
  renders `Recreate` directly.
- `podSecurityContext`, `containerSecurityContext`, `podAnnotations`,
  `podLabels`, `hostAliases`, `volumes`, and `volumeMounts` exist in values, but
  are not rendered by the current parent Deployment template.
- The MySQL Service always exposes port `3306`, while the MySQL container port
  can be changed through `global.joomlaDbPort`. Changing the database port may
  therefore require template changes.
- No Helm tests are currently implemented.

## Notes for future improvements

- Add Helm test templates that verify the Joomla HTTP endpoint and MySQL
  connectivity.
- Wire existing values such as ingress, existing PVC claims, pod security
  contexts, annotations, labels, extra volumes, and node selectors into the
  templates.
- Consider release-scoped names for easier multiple installs in one namespace.
- Add a documented path for external secret management.
- Add tested examples for common homelab setups such as k3s with local-path and
  MetalLB.

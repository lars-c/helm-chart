# joomla-codex

A small, readable Helm chart that deploys Joomla with an included MySQL sub-chart. It is intended for homelab use and keeps the first version deliberately simple: one Joomla Deployment, one MySQL Deployment, one PVC for each application, and Kubernetes Secrets for passwords.

## What It Deploys

- Joomla using the official `joomla:5.4.6-php8.3` image.
- MySQL using the included `charts/mysql` sub-chart.
- A Joomla Service.
- A MySQL Service named `joomla-codex-mysql` by default.
- PersistentVolumeClaims for Joomla files and MySQL data.
- Kubernetes Secrets for Joomla and MySQL passwords.

## Install

From the repository root:

```sh
helm install joomla ./joomla-codex
```

With custom passwords:

```sh
helm install joomla ./joomla-codex \
  --set global.dbPassword='change-this-joomla-password' \
  --set mysql.mysql.rootPassword='change-this-root-password'
```

By default, Joomla will use `global.dbPassword` for `JOOMLA_DB_PASSWORD` when provided, otherwise it falls back to chart-specific values.

## Access Joomla

The default Joomla Service type is `ClusterIP`. For local access:

```sh
kubectl port-forward svc/joomla-joomla-codex 8080:80
```

Then open:

```text
http://127.0.0.1:8080
```

If you set a different Helm release name, the Service name will change. Run this to find it:

```sh
kubectl get svc
```

## Configuration

Most settings are exposed in `values.yaml` and commented there.

Important Joomla values:

- `image.repository`, `image.tag`, and `image.pullPolicy`
- `service.type`, `service.port`, and `service.targetPort`
- `persistence.storageClassName`, `persistence.accessModes`, and `persistence.size`
- `joomla.dbUser`
- `joomla.dbPassword`, optional override for `global.dbPassword`
- `joomla.dbName`
- `joomla.dataMountPath`
- `readinessProbe.*` and `livenessProbe.*`
- `resources.requests` and `resources.limits`

Important MySQL values:

- `mysql.fullnameOverride`
- `mysql.image.repository`, `mysql.image.tag`, and `mysql.image.pullPolicy`
- `mysql.service.type`, `mysql.service.port`, and `mysql.service.targetPort`
- `mysql.persistence.storageClassName`, `mysql.persistence.accessModes`, and `mysql.persistence.size`
- `global.dbName`, `global.dbUser`, and `global.dbPassword` (preferred shared DB settings)
- `mysql.mysql.database` and `mysql.mysql.user` (chart-specific defaults; `global.*` will override when provided)
- `mysql.mysql.rootPassword` (MySQL root password remains chart-specific)
- `mysql.mysql.dataMountPath`
- `mysql.readinessProbe.*` and `mysql.livenessProbe.*`
- `mysql.resources.requests` and `mysql.resources.limits`

## Persistence

Joomla mounts persistent storage at:

```text
/var/www/html
```

MySQL mounts persistent storage at:

```text
/var/lib/mysql
```

By default, both PVCs use:

- `ReadWriteOnce`
- the cluster default StorageClass
- `5Gi` for Joomla
- `8Gi` for MySQL

To set a StorageClass:

```sh
helm install joomla ./joomla-codex \
  --set persistence.storageClassName='local-path' \
  --set mysql.persistence.storageClassName='local-path'
```

## Passwords

Passwords are configured through `values.yaml` and rendered into Kubernetes Secrets. The templates do not hardcode passwords.

For a real installation, change these values before installing:

- `global.dbPassword`
- `mysql.mysql.rootPassword`

The default Joomla database settings are designed to connect automatically to the included MySQL service. Joomla derives `JOOMLA_DB_HOST` from the included MySQL sub-chart Service helper, so there is no database host value to configure. When `global.dbPassword` is set it will be used for both Joomla and the included MySQL user; charts fall back to their chart-specific values when `global.*` is not provided.

```yaml
global:
  dbUser: joomla
  dbPassword: ""
  dbName: joomla

joomla:
  dbUser: joomla
  dbPassword: ""
  dbName: joomla

mysql:
  fullnameOverride: joomla-codex-mysql
  mysql:
    database: joomla
    user: joomla
    password: changeme-joomla
    rootPassword: changeme-root
```

## Testing

This chart includes two Helm test Pods:

- `templates/tests/joomla-http-smoke-test.yaml`
- `charts/mysql/templates/tests/mysql-login-smoke-test.yaml`

Run the tests after installing the chart:

```sh
helm test joomla
```

Show test logs while running:

```sh
helm test joomla --logs
```

If a test fails, inspect the test Pods before rerunning. Successful test Pods are removed automatically. These log examples use the default release name `joomla` and default chart names:

```sh
kubectl get pods
kubectl logs pod/joomla-joomla-codex-http-smoke-test
kubectl logs pod/joomla-codex-mysql-login-smoke-test
```

The Joomla HTTP smoke test starts a small curl Pod and requests the Joomla Service at `/`. It verifies that the Joomla Service is reachable inside the cluster and returns a successful HTTP response. It does not verify the Joomla setup wizard, admin login, content, TLS, Ingress, or persistence.

The MySQL login smoke test starts a MySQL client Pod, reads the MySQL user password from the Secret, connects to the MySQL Service, selects the configured database, and runs `SELECT 1;`. It does not verify backups, restore, storage durability, root login, replication, or Joomla application behavior.

## Upgrade

After changing values:

```sh
helm upgrade joomla ./joomla-codex
```

## Uninstall

```sh
helm uninstall joomla
```

PVCs may remain after uninstall depending on your cluster and StorageClass behavior. Check them with:

```sh
kubectl get pvc
```

## Limitations

- MySQL is deployed as a Deployment, not a StatefulSet.
- There is no database backup or restore automation.
- There is no ingress template.
- There is no TLS configuration.
- There is no horizontal scaling. Joomla and MySQL both run as a single replica.
- Default passwords are placeholders and must be changed for real use.
- The chart is intended for a small homelab, not production.

## Future Improvements

- Add an optional Ingress.
- Add backup and restore jobs for MySQL and Joomla files.
- Add optional existing Secret support.
- Add more complete health checks after the first Joomla setup is complete.
- Move MySQL to a StatefulSet for stronger storage identity.

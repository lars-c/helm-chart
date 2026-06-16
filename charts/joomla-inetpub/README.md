# joomla-inetpub

Helm chart for deploying Joomla with a bundled MySQL subchart.

## Secrets and Passwords

This chart creates two Kubernetes `Opaque` Secrets:

- `joomla-secret`, which contains `dbpassword` for `JOOMLA_DB_PASSWORD`.
- `mysql-secret`, which contains `dbpassword` for `MYSQL_PASSWORD` and `rootdbpassword` for `MYSQL_ROOT_PASSWORD`.

The Joomla and MySQL database password values both come from `global.dbPassword`. The helper encodes that single value into Secret `data`, so both applications receive the same password. The chart requires `global.dbPassword`; it does not generate a fallback database password.

The MySQL root password comes from `mysql.auth.rootdbpassword`. The chart requires this value and encodes it into Secret `data`.

Set these values during installation or in a private values file:

```sh
helm install joomla-inetpub . \
  --set global.dbPassword='change-me' \
  --set mysql.auth.rootdbpassword='change-root-me'
```

The values in Kubernetes Secret `data` are base64-encoded as required by Kubernetes. Base64 is not encryption, so avoid committing real production passwords in `values.yaml`.

## Upgrade Notes

Chart version 0.3.0 renames three global database values:

- `global.dbpassword` -> `global.dbPassword`
- `global.dbuser` -> `global.dbUser`
- `global.dbname` -> `global.dbName`

Update existing custom values files before upgrading.

Before:

```yaml
global:
  dbpassword: change-me
  dbuser: j210
  dbname: joomla_db
```

After:

```yaml
global:
  dbPassword: change-me
  dbUser: j210
  dbName: joomla_db
```

## Testing

This chart includes two Helm test Pods:

- `joomla-http-smoke-test` verifies that the Joomla Service answers HTTP on the configured service port. It does not verify external LoadBalancer access, Joomla setup completion, or the web installer state.
- `mysql-login-smoke-test` verifies that the MySQL Service accepts the configured database user, password, and database name, then runs `SELECT 1`. It does not verify migrations, backups, replication, or persistent storage recovery.

Run the tests after the release is installed and the Pods are ready:

```sh
helm test joomla-inetpub
```

Inspect logs if a test fails:

```sh
kubectl logs joomla-http-smoke-test
kubectl logs mysql-login-smoke-test
```

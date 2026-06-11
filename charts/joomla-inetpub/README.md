# joomla-inetpub

Helm chart for deploying Joomla with a bundled MySQL subchart.

## Secrets and Passwords

This chart creates two Kubernetes `Opaque` Secrets:

- `joomla-secret`, which contains `dbpassword` for `JOOMLA_DB_PASSWORD`.
- `mysql-secret`, which contains `dbpassword` for `MYSQL_PASSWORD` and `rootdbpassword` for `MYSQL_ROOT_PASSWORD`.

The Joomla and MySQL database password values both come from `global.dbpassword`. The helper encodes that single value into Secret `data`, so both applications receive the same password. The chart requires `global.dbpassword`; it does not generate a fallback database password.

The MySQL root password comes from `mysql.auth.rootdbpassword`. The chart requires this value and encodes it into Secret `data`.

Set these values during installation or in a private values file:

```sh
helm install joomla-inetpub . \
  --set global.dbpassword='change-me' \
  --set mysql.auth.rootdbpassword='change-root-me'
```

The values in Kubernetes Secret `data` are base64-encoded as required by Kubernetes. Base64 is not encryption, so avoid committing real production passwords in `values.yaml`.

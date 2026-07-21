# mongodb-basic

Simple Helm chart for running MongoDB as a Kubernetes `StatefulSet` in a homelab.

This chart is intended as the MongoDB backend for Graylog. It is not a Graylog
chart and it is not an OpenSearch chart.

## What It Creates

- One MongoDB `StatefulSet`
- One headless Service named by `serviceName`
- One PVC per MongoDB pod
- Kubernetes Secrets for the MongoDB root credentials and replica-set keyfile
- An optional NetworkPolicy that allows MongoDB traffic from Graylog pods

By default the chart runs 3 MongoDB pods with replica-set arguments enabled.
Initial replica-set setup is still an operational step; the chart does not run
`rs.initiate()` for you.

## Install Or Upgrade

From the repository root:

```bash
helm upgrade --install mongodb ./charts/mongodb-basic \
  --namespace mongodb \
  --create-namespace \
  -f ./charts/mongodb-basic/values.yaml
```

From this chart directory:

```bash
helm upgrade --install mongodb . \
  --namespace mongodb \
  --create-namespace \
  -f values.yaml
```

## Important Values

Common values to review before installing:

```yaml
name: mongodb
replicaCount: 3
serviceName: mongo-service

image:
  repository: mongo
  tag: ""

auth:
  rootUsername: admin
  rootPassword: SecurePassword123

networkPolicy:
  enabled: true
  allowedNamespace: graylog
  allowedPodLabels:
    graylog-mongodb-client: "true"

persistence:
  storageClass: local-path
  size: 1Gi
```

If `image.tag` is empty, the chart uses `Chart.yaml` `appVersion` as the MongoDB
image tag. For this chart version that renders as `mongo:8.0.12`.

Do not commit real homelab passwords to Git. The chart stores credentials in a
Kubernetes Secret at render time, but values files are still plaintext before
they reach the cluster.

## StatefulSet Notes

The StatefulSet selector and pod template labels use the stable selector:

```yaml
app: mongodb
```

Keep this selector stable after install. Changing StatefulSet selector labels can
require recreating the StatefulSet.

Additional labels from `podLabels` are added to the pod template, but the
selector label remains controlled by the chart.

The headless service name must match `serviceName`, because MongoDB pods use
StatefulSet DNS names like:

```text
mongodb-0.mongo-service.mongodb.svc.cluster.local
```

## NetworkPolicy

When `networkPolicy.enabled` is true, the chart creates an ingress-only
NetworkPolicy for MongoDB pods. It allows:

- MongoDB pod-to-pod traffic on TCP/27017 for replica-set communication
- Graylog pods on TCP/27017 when they are in `networkPolicy.allowedNamespace`
  and have the labels from `networkPolicy.allowedPodLabels`

The Graylog namespace selector and pod selector are in the same `from` item, so
both must match.

NetworkPolicy is not a replacement for MongoDB credentials. Keep authentication
enabled and use NetworkPolicy as an extra boundary.

## Required Graylog Labels

Graylog pods must have the MongoDB client label on the pod template:

```yaml
graylog-mongodb-client: "true"
```

If OpenSearch is also protected by a similar NetworkPolicy, Graylog pods usually
need this label too:

```yaml
graylog-opensearch-client: "true"
```

These labels must land on the Graylog pod template, not only on a HelmRelease,
Deployment, or StatefulSet metadata object.

Example Graylog values:

```yaml
graylog:
  customLabels:
    graylog-mongodb-client: "true"
    graylog-opensearch-client: "true"
```

Check your Graylog chart's values schema. Some charts place this at top-level
`customLabels`, while others nest it under the Graylog workload.

## Security context

This chart runs MongoDB as a non-root user.

The default security context is:

```yaml
podSecurityContext:
  enabled: true
  fsGroup: 999
  fsGroupChangePolicy: "OnRootMismatch"

containerSecurityContext:
  enabled: true
  runAsUser: 999
  runAsGroup: 999
  allowPrivilegeEscalation: false
```

### Why this is needed

MongoDB stores its database files under `/data/db`. This path is backed by a PersistentVolumeClaim.

Different Kubernetes storage classes may mount newly created volumes with different ownership and permissions. Some storage classes create permissive volumes that a non-root container can write to immediately. Other storage classes mount the volume as `root:root` with restrictive permissions.

If MongoDB cannot write to `/data/db`, the pod may fail during startup with an error similar to:

```text
Error creating journal directory
directory="/data/db/journal"
error="Permission denied"
```

The `fsGroup` setting makes the mounted data volume accessible to the MongoDB group. Without it, a volume that is owned by `root:root` may not be writable by the MongoDB process.

### Pod security context

The pod-level security context is used for volume access:

```yaml
podSecurityContext:
  enabled: true
  fsGroup: 999
  fsGroupChangePolicy: "OnRootMismatch"
```

`fsGroup: 999` tells Kubernetes that mounted volumes should be accessible to filesystem group `999`.

This is important for the MongoDB data volume. The MongoDB container runs as group `999`, so the data volume must be writable by that group.

`fsGroupChangePolicy: "OnRootMismatch"` avoids unnecessary recursive ownership changes when the volume root already has the expected ownership. This is useful for database volumes, because recursive permission changes on large PVCs can slow down pod startup.

### Container security context

The MongoDB container security context is:

```yaml
containerSecurityContext:
  enabled: true
  runAsUser: 999
  runAsGroup: 999
  allowPrivilegeEscalation: false
```

`runAsUser: 999` runs the MongoDB process as the `mongodb` user.

`runAsGroup: 999` runs the MongoDB process with the `mongodb` group as its primary group.

`allowPrivilegeEscalation: false` prevents the MongoDB process from gaining additional privileges inside the container.

### Do not normally change these values

For the current chart image, `mongo:8.0.12`, the MongoDB user and group are expected to be UID/GID `999`.

These values should normally be left unchanged:

```yaml
fsGroup: 999
runAsUser: 999
runAsGroup: 999
```

Only change them if you deliberately switch to a different MongoDB image that uses another UID/GID.

If the image is changed, verify the expected UID/GID before changing these settings. For example:

```bash
kubectl run --stdin --tty --rm --image <mongo-image>:<tag> mongo-id-test --restart Never -- sh
id mongodb
```

The `fsGroup`, `runAsUser`, and `runAsGroup` values should match the MongoDB user/group used by the selected image.

### Init containers

This chart may use an initContainer to prepare the MongoDB keyfile before the main MongoDB container starts.

The pod-level `fsGroup` setting does not make the initContainer run as UID `999`. It only affects filesystem group handling for mounted volumes.

The initContainer may still run as root when it needs to copy the keyfile, change ownership, or adjust permissions before MongoDB starts.

The main MongoDB container should remain non-root.

### Storage class notes

This chart should not rely on a storage class creating world-writable volumes.

A permissive storage class may appear to work without `fsGroup`, but a stricter storage class may fail with `Permission denied` when MongoDB tries to create `/data/db/journal`.

Keeping `fsGroup: 999` enabled makes the chart more portable across storage classes such as `local-path`, iSCSI-backed CSI volumes, and other dynamically provisioned PVCs.

### Troubleshooting permissions

To check the mounted data volume permissions, inspect the pod or use a temporary debug pod with the same UID/GID as MongoDB:

```yaml
securityContext:
  runAsUser: 999
  runAsGroup: 999
```

If that pod cannot create a file or directory on the mounted PVC, the volume is not writable by the MongoDB user/group.

Then test again with:

```yaml
securityContext:
  runAsUser: 999
  runAsGroup: 999
  fsGroup: 999
  fsGroupChangePolicy: "OnRootMismatch"
```

If the second test works, the storage class requires `fsGroup` for non-root workloads.


## Connection Examples

MongoDB in namespace `mongodb`, Graylog in namespace `graylog`:

```text
mongodb://admin:<password>@mongodb-0.mongo-service.mongodb.svc.cluster.local:27017,mongodb-1.mongo-service.mongodb.svc.cluster.local:27017,mongodb-2.mongo-service.mongodb.svc.cluster.local:27017/graylog?replicaSet=rs0&authSource=admin
```

If OpenSearch runs in namespace `opensearch`, Graylog would normally point at
its service by namespace-qualified DNS, for example:

```text
http://opensearch.opensearch.svc.cluster.local:9200
```

The exact OpenSearch service name depends on the OpenSearch chart you deploy.

## Testing Network Access

From a Graylog-labeled test pod in the `graylog` namespace:

```bash
kubectl run mongodb-allowed-test \
  -n graylog \
  --rm -it \
  --restart=Never \
  --image=busybox \
  --labels='graylog-mongodb-client=true' \
  -- nc -vz mongo-service.mongodb.svc.cluster.local 27017
```

From an unlabeled pod, this should fail or time out when NetworkPolicy is
enforced by your CNI:

```bash
kubectl run mongodb-blocked-test \
  -n graylog \
  --rm -it \
  --restart=Never \
  --image=busybox \
  -- nc -vz mongo-service.mongodb.svc.cluster.local 27017
```

To test from inside the MongoDB namespace:

```bash
kubectl run mongodb-local-test \
  -n mongodb \
  --rm -it \
  --restart=Never \
  --image=busybox \
  -- nc -vz mongo-service 27017
```

## Debugging Rendered Manifests

Values can look correct while the rendered manifest is wrong. Check what Helm
actually produces:

```bash
helm template mongodb ./charts/mongodb-basic -n mongodb -f ./charts/mongodb-basic/values.yaml
helm template mongodb ./charts/mongodb-basic -n mongodb -f ./charts/mongodb-basic/values.yaml | yq '. | select(.kind == "NetworkPolicy")'
helm template mongodb ./charts/mongodb-basic -n mongodb -f ./charts/mongodb-basic/values.yaml | yq '. | select(.kind == "StatefulSet") | .spec.template.metadata.labels'
```

From this chart directory, the equivalent commands are:

```bash
helm template mongodb . -n mongodb -f values.yaml
helm template mongodb . -n mongodb -f values.yaml | yq '. | select(.kind == "NetworkPolicy")'
helm template mongodb . -n mongodb -f values.yaml | yq '. | select(.kind == "StatefulSet") | .spec.template.metadata.labels'
```

## Limitations And Assumptions

- This is a small homelab chart, not a full MongoDB operator.
- Replica-set initialization is manual.
- The Service is internal-only and headless.
- Default credentials are examples and should be overridden.
- The chart assumes your CNI enforces Kubernetes NetworkPolicy.
- `serviceName` and StatefulSet/PVC naming choices should be treated as stable
  after install.

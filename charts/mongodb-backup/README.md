# CronJob - mongodb-backup

⚠️ CronJob for MongoDB mongodump

#### CronJob
```console
mongodump cronjob for a MongoDB StatefulSet
NFS for backup target
Image (custom): ghcr.io/lars-c/mongodb-tools:100.13.0 (Ubuntu 24.04 with MongoDB Database Tools version 100.13.0 installed)

Source: 
mongoHost: "mongo-service.dok1.svc.cluster.local"
auth.rootUsername: "admin"
auth.rootPassword: "SecurePassword123"

Target NFS config
nfs.server: 192.168.1.25
nfs.path: /var/nfs/backup

```
#### source
```console
/srv/github/node/stateful/mongodb-backup/

```
#### Values
```console
auth:
  rootUsername: "admin"
  rootPassword: "SecurePassword123"

mongoHost: "mongo-service.dok1.svc.cluster.local"  

backup:
  schedule: "*/5 * * * *" # Runs backup every five minutes
  retentionDays: 14       # Retention days for backup files

nfs:
  server: 192.168.1.25
  path: /var/nfs/backup

```
#### Secret and connect string
```console
mongodump --uri="mongodb://<user>:<password>@<mongo-service>.<namespace>.svc.cluster.local:27017/?replicaSet=rs0&authSource=admin" --out=/tmp
=>
  MONGO_HOST: "mongodb-service.dok1.svc.cluster.local"
  MONGO_USER: "admin"
  MONGO_PASS: "SecurePassword123"

```



# CronJob - mongodb-backup

⚠️ CronJob for MongoDB mongodump

#### CronJob
```console
mongodump cronjob for a MongoDB StatefulSet
Image (custom): ghcr.io/lars-c/mongodb-tools:100.13.0 (Ubuntu 24.04 with MongoDB Database Tools version 100.13.0 installed)
Include users
NFS for backup target

Source: 
Mongodb host: mongoHost
root username: auth.rootUsername
root password: auth.rootPassword

Target NFS config
nfs server: nfs.server
nfs path: nfs.path

```
#### source
```console
/srv/github/node/stateful/mongodb-backup/

```
#### Backup schedule
```console

schedule: backup.schedule ()"*/5 * * * *" # Runs backup every five minutes)
retention: backup.retentionDays       # Retention days for backup files

```
#### Secret and connect string
```console
mongodump --uri="mongodb://<user>:<password>@<mongo-service>.<namespace>.svc.cluster.local:27017/?replicaSet=rs0&authSource=admin" --out=/tmp
=>
  MONGO_HOST: "mongodb-service.dok1.svc.cluster.local"
  MONGO_USER: "admin"
  MONGO_PASS: "SecurePassword123"

```



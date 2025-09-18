# Job - restore MongoDB 1

⚠️ Testing restore job for MongoDB

#### Values.yaml
```console
auth:
  rootUsername: "admin"
  rootPassword: "SecurePassword123"

mongo:
  # List of host:port for your *target* replica set
  hosts:
    - mongodb-0.mongo-service.dok1.svc.cluster.local:27017
    - mongodb-0.mongo-service.dok1.svc.cluster.local:27017
    - mongodb-0.mongo-service.dok1.svc.cluster.local:27017

```
#### Notes
```console
Copy of mongodb-restore
Added features check and logs

job:
  ttlSecondsAfterFinished: 900
  backoffLimit: 0
  activeDeadlineSeconds: 1800  # optional

```
#### Test
```console
Restore OK

```
#### Restore from NFS
```console
Restore file from NFS (192.168.1.25). 
Path: /var/nfs/backup

Pick latest backup file always

```



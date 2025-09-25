# Statefull - MongoDB StatefulSet

⚠️ StatefulSet for MongoDB

#### Version
```console
0.1.6 volumeClaimTemplates added storageClassName/persistence.storageClass

```

#### servicename and service name
```console
SatefulSet:
spec:
  serviceName: mongo-service

Service:
metadata:
  name: mongo-service

```
#### pod names: 
```console
Pod take name after statefulSet name: <StatefulSet name>-x

StatefulSet:
kind: StatefulSet
metadata:
  name: mongo-backup


NAME             READY   STATUS    RESTARTS   AGE
mongo-backup-0   1/1     Running   0          4m35s
mongo-backup-1   1/1     Running   0          4m29s
mongo-backup-2   1/1     Running   0          4m23s

```
#### helm install
```console
name        servicename         namespace   helm
helm install mongo-backup mongo-backup --create-namespace --namespace mongo-backup --debug

```
#### PV name (not NS bound)
```console
kubectl get pv
NAME                                       MODES   
pvc-238fddd1-a305-4a16-b844-57f9720e772a   mongo-backup/mongodb-storage-mongo-backup-1   
pvc-2faf2b47-35b1-4d00-933c-395c3c5a4264   mongo-backup/mongodb-storage-mongo-backup-2
pvc-5a6dc7e7-672f-4f66-b27d-6c796680b87d   mongo-backup/mongodb-storage-mongo-backup-0

```
#### PVC name
```console
StatefulSet:
volumeClaimTemplates:
  - metadata:
      name: mongodb-storage

<volumeClaimTemplates.name>-<StatefulSet.name>
kubectl get pvc -A
NAMESPACE      NAME                             VOLUME
mongo-backup   mongodb-storage-mongo-backup-0   pvc-5a6dc7e7-672f-4f66-b27d-6c796680b87d   
mongo-backup   mongodb-storage-mongo-backup-1   pvc-238fddd1-a305-4a16-b844-57f9720e772a   
mongo-backup   mongodb-storage-mongo-backup-2   pvc-2faf2b47-35b1-4d00-933c-395c3c5a4264   

```
#### Names
```console
mongo-backup-0.mongo-service.mongo-backup 
StatefulSet:
volumeClaimTemplates:
  - metadata:
      name: mongodb-storage

<volumeClaimTemplates.name>-<StatefulSet.name>
kubectl get pvc -A
NAMESPACE      NAME                             STATUS   VOLUME
mongo-backup   mongodb-storage-mongo-backup-0   Bound    pvc-5a6dc7e7-672f-4f66-b27d-6c796680b87d   
mongo-backup   mongodb-storage-mongo-backup-1   Bound    pvc-238fddd1-a305-4a16-b844-57f9720e772a   
mongo-backup   mongodb-storage-mongo-backup-2   Bound    pvc-2faf2b47-35b1-4d00-933c-395c3c5a4264   

StatefulSet:
# Namespace bound. Keep constant or modify
StatefulSet name: mongo-backup
# Servicename. Keep constant
# DNS <pod-name><servicename><ns>
ServiceName: mongo-service
# PVC name: Keep constant (use statefulSet name change instead)
# <volumeClaimTemplates.name>-<StatefulSet.name>
volumeClaimTemplates.metadata.name: mongodb-storage

Service:
# Must follow StetefulSet servicename
metadata.name: mongo-service
```



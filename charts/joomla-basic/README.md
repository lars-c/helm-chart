<!--- app-name: Joomla! -->
<!-- markdownlint-disable-next-line MD026 -->
# Basic Helm chart for Joomla

[Joomla!](http://www.joomla.org/)

## Limitations
```txt
Chart include configuration errors and omissions. 
Documentation is incomplete and/or misleading.
```

#### Images
```console
Dockerhub Joomla  official image tag: "php8.3-apache" (https://hub.docker.com/_/joomla)
Dockerhub MySQL official image tag: "8.0" (https://hub.docker.com/_/mysql)
```

#### Charts
```console
Joomla
Sub-charts:
  MySQL
  Common
```

#### initContainers
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

#### Global values (mandatory)
```console
  dbname: "joomla_db"
  dbuser: "joomla"
  dbpassword: "dbpassword"
  joomlaDbHost: "joomla-mysql"
  joomlaDbPort: "3306"
```

#### CLI install (automatic install)
```console

  dbname: "joomla_db"
  dbuser: "joomla"
  dbpassword: "dbpassword"
  joomlaDbHost: "joomla-mysql"
  joomlaDbPort: "3306"
```

##### updateStrategy (default)
```console
  type: Recreate
```

#### joomla persistence (default)
```console
  enabled: true
  storageClass: "local-path"
  accessModes: "ReadWriteOnce"
```

#### joomla service (default)
```console
  type: LoadBalancer
  port: 80
  #clusterIP:
  loadBalancerIP: ""
```

##### ingress (not tested)
```console
```
#### Joomla probes (default)
```console
  startupProbe
  livenessProbe (enabled)
  readinessProbe
```
##### tolerations (default enabled)
```console
    - key: "key1"
      operator: "Equal"
      value: "gray"
      effect: "NoSchedule"
    - key: "key1"
      operator: "Equal"
      value: "orange"
      effect: "NoSchedule"
```

##### affinity (default enabled)
```console
Enable/Disable
Both preferred and required. 
preferred (+) required (-) : preferred
preferred (-) required (+) : required
preferred (+) required (+) : preferred
preferred (-) required (-) : preferred

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
##### MySQL (default)
```console
```

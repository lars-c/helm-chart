<!--- app-name: Joomla! -->
<!-- markdownlint-disable-next-line MD026 -->
# Basic test chart for Joomla

[Joomla!](http://www.joomla.org/)

## For testing and educational purpose only

```txt
Chart properly include configuration errors and omissions. Documentation is incomplete and/or misleading. Purpose of this chart is testing only.
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://REGISTRY_NAME/REPOSITORY_NAME/joomla
```

> Note: You need to substitute the placeholders `REGISTRY_NAME` and `REPOSITORY_NAME` with a reference to your Helm chart registry and repository. For example, in the case of Bitnami, you need to use `REGISTRY_NAME=registry-1.docker.io` and `REPOSITORY_NAME=bitnamicharts`.

The command deploys Joomla! on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.
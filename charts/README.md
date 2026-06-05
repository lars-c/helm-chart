# Homelab Helm Charts

This repository contains a collection of Helm charts used for learning, testing, and running small homelab deployments.

The charts are built with the goal of understanding my own Kubernetes deployments better: how the resources fit together, how values are passed into templates, how persistence works, and how applications can be deployed in a controlled and documented way.

These charts are made with best effort and are intended to be readable, documented, and useful in a small lab environment. They should not be considered production-ready without careful review and testing.

## Charts

| Chart             | Purpose                                                                                                        |
| ----------------- | -------------------------------------------------------------------------------------------------------------- |
| `busybox`         | Simple test/debug chart for basic Kubernetes behavior.                                                         |
| `mysql-basic`     | Basic MySQL deployment with persistence and secrets.                                                           |
| `joomla-basic`    | Basic Joomla + MySQL chart.                                                                                    |
| `joomla-codex`    | Joomla + MySQL chart developed/refactored with help from Codex, with more structured values and documentation. |
| `joomla-inetpub`  | Joomla-related chart variant for further testing and experimentation.                                          |
| `mongodb-basic`   | Basic MongoDB deployment.                                                                                      |
| `mongodb-backup`  | MongoDB backup helper chart.                                                                                   |
| `mongodb-restore` | MongoDB restore helper chart.                                                                                  |

## Goals

The main goals of this repository are:

* learning Helm chart structure and templating
* documenting how my own deployments work
* testing Kubernetes resources in a homelab environment
* experimenting with persistence, secrets, services, probes, and values
* building small charts that are understandable rather than overly generic

## Not Production Ready

These charts are primarily intended for personal homelab use.

Before using them in a more serious environment, review at least:

* security settings
* password and secret handling
* resource requests and limits
* storage configuration
* backup and restore procedures
* update strategy
* image versions
* network exposure
* application-specific hardening

## Storage Assumptions

Several charts assume that a suitable Kubernetes `StorageClass` exists.

In my own lab this is often `local-path`, but the correct value depends on the cluster.

Check each chart’s `values.yaml` before installation.

## Usage

Example:

```bash
helm install my-release ./chart-name
```

Example with custom values:

```bash
helm install my-release ./chart-name -f values.yaml
```

Render templates locally before installing:

```bash
helm template my-release ./chart-name
```

Run linting:

```bash
helm lint ./chart-name
```

Run Helm tests, if the chart includes them:

```bash
helm test my-release
```

## Feedback

Comments, ideas, corrections, and suggestions are welcome.

These charts are part of an ongoing learning process, so practical feedback about structure, security, maintainability, or better Helm/Kubernetes patterns is appreciated.

I’d maybe add a `Status` column later if some charts are “working”, “experimental”, or “archived”.

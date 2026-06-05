{{/*
Expand the name of the chart.
*/}}
{{- define "joomla-codex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "joomla-codex.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "joomla-codex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "joomla-codex.labels" -}}
helm.sh/chart: {{ include "joomla-codex.chart" . }}
{{ include "joomla-codex.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "joomla-codex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "joomla-codex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Secret name for Joomla database credentials.
*/}}
{{- define "joomla-codex.secretName" -}}
{{- printf "%s-secret" (include "joomla-codex.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
PVC name for Joomla persistent files.
*/}}
{{- define "joomla-codex.pvcName" -}}
{{- printf "%s-data" (include "joomla-codex.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Joomla database host.
Resolve the MySQL Service name from the parent chart.

The mysql.serviceName helper belongs to the mysql subchart and expects
a subchart-like context where .Values points to .Values.mysql.
*/}}
{{- define "joomla-codex.dbHost" -}}
{{- $mysqlContext := dict "Chart" (dict "Name" "mysql") "Values" .Values.mysql "Release" .Release -}}
{{- include "mysql.serviceName" $mysqlContext -}}
{{- end -}}

{{/*
Joomla database password.
*/}}
{{- define "joomla-codex.dbPassword" -}}
{{- /* Prefer global.dbPassword, then joomla.dbPassword, then mysql.mysql.password. */ -}}
{{- default .Values.mysql.mysql.password (default .Values.joomla.dbPassword .Values.global.dbPassword) -}}
{{- end -}}

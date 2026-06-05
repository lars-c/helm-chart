{{/*
Expand the name of the chart.
*/}}
{{- define "mysql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mysql.fullname" -}}
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
Service name for MySQL.
*/}}
{{- define "mysql.serviceName" -}}
{{- include "mysql.fullname" . -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mysql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "mysql.labels" -}}
helm.sh/chart: {{ include "mysql.chart" . }}
{{ include "mysql.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mysql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Secret name for MySQL credentials.
*/}}
{{- define "mysql.secretName" -}}
{{- printf "%s-secret" (include "mysql.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
PVC name for MySQL data.
*/}}
{{- define "mysql.pvcName" -}}
{{- printf "%s-data" (include "mysql.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

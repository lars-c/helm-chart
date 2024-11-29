{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "joomla.mysql.fullname" -}}
{{- printf "%s-%s" .Release.Name "mysql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the MySQL Hostname
*/}}
{{- define "joomla.mysql.databaseHost" -}}
{{- if .Values.mysql.enabled }}
    {{- printf "%s" (include "joomla.mysql.fullname" .) -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the joomla db user password
*/}}
{{- define "mysql.password" -}}
{{- if .Values.auth.password }}
    {{- printf .Values.auth.password | b64enc | quote -}}
{{- else -}}
    {{- $password := randAlphaNum 16 -}}
    {{- printf $password | quote -}}
{{- end -}}
{{- end -}}
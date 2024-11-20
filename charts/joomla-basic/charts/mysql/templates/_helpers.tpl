
{{/*
Return the MySQL root password
*/}}
{{- define "mysql.rootPassword" -}}
{{- if .Values.auth.rootpassword }}
    {{- printf .Values.auth.rootpassword | b64enc | quote -}}
{{- else -}}
    {{- $rootpassword := randAlphaNum 16 -}}
    {{- printf $rootpassword | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL user password
*/}}
{{- define "mysql.password" -}}
{{- if .Values.auth.password }}
    {{- printf .Values.auth.password | b64enc | quote -}}
{{- else -}}
    {{- $password := randAlphaNum 16 -}}
    {{- printf $password | quote -}}
{{- end -}}
{{- end -}}
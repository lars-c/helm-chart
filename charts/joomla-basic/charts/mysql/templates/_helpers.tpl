
{{/*
Return the MySQL root password (not used)
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
Return the MySQL user password (not used)
*/}}
{{- define "mysql.password" -}}
{{- if .Values.auth.password }}
    {{- printf .Values.auth.password | b64enc | quote -}}
{{- else -}}
    {{- $password := randAlphaNum 16 -}}
    {{- printf $password | quote -}}
{{- end -}}
{{- end -}}


{{/*
Return the MySQL port 
If match in deployment and service
*/}}
{{- define "mysql.port" -}}
{{- if .Values.port }}
    {{- printf .Values.port -}}
{{- else -}}
    {{- printf 3306 -}}
{{- end -}}
{{- end -}}
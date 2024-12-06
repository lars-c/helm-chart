{{/*
Return MYSQL_ROOT_PASSWORD value
*/}}
{{- define "common.mysql.rootpassword" -}}
{{- if .Values.global.dbpassword }}
    {{- printf .Values.global.dbpassword | b64enc -}}
{{- else -}}
    {{- printf (randAlphaNum 16) | quote -}}
{{- end -}}
{{- end -}}
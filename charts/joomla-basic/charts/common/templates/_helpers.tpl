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

{{/*
Return DBHOST NAME value (JOOMLA_DB_HOST / MYSQL_HOST)
*/}}
{{- define "common.db.hostname" -}}
{{- if .Values.global.joomlaDbHost }}
    {{- printf .Values.global.joomlaDbHost | quote -}}
{{- else -}}
    {{- printf "joomla-mysql" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return DB NAME value (JOOMLA_DB_NAME MYSQL_DATABASE)
*/}} 
{{- define "common.dbname" -}}
{{- if .Values.global.dbname }}
    {{- printf .Values.global.dbname | quote -}}
{{- else -}}
    {{- printf "joomla-cms" | quote -}}
{{- end -}}
{{- end -}}
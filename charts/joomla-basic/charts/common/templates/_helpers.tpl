{{/*
Return MYSQL_ROOT_PASSWORD value
*/}}
{{- define "common.mysql.rootpassword" -}}
{{- if .Values.auth.rootdbpassword }}
    {{- printf .Values.auth.rootdbpassword | b64enc -}}
{{- else -}}
    {{- printf (randAlphaNum 16) | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return JOOMLA_DB_PASSWOR / MYSQL_PASSWORD value
*/}}
{{- define "common.global.dbpassword" -}}
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
    {{- printf "joomla-db" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return DB USER value (JOOMLA_DB_USER)
*/}} 
{{- define "common.dbuser" -}}
{{- if .Values.global.dbuser }}
    {{- printf .Values.global.dbuser | quote -}}
{{- else -}}
    {{- printf "joomla" | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return MYSQL PORT (MYSQL_TCP_PORT)
*/}} 
{{- define "common.joomlaDbPort" -}}
{{- $dbport := toString .Values.global.joomlaDbPort -}}
{{- if not (regexMatch "^[0-9]+$" $dbport) -}}
    {{- fail "Error: global.joomlaDbPort must be an integer value." -}}
{{- else -}}
    {{- printf "%s" $dbport | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return preferred or required node Affinity
*/}} 
{{- define "common.affinity" -}}
{{- if and .Values.affinity.preferred (not .Values.affinity.required) -}}
preferredDuringSchedulingIgnoredDuringExecution
{{- else if and (not .Values.affinity.preferred) .Values.affinity.required -}}
requiredDuringSchedulingIgnoredDuringExecution
{{- else -}}
preferredDuringSchedulingIgnoredDuringExecution
{{- end -}}
{{- end -}}
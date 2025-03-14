{{/*
Return DBHOST NAME value (JOOMLA_DB_HOST / MYSQL_HOST)
*/}}
{{- define "common.dbhostname" -}}
{{- if .Values.global.joomlaDbHost }}
    {{- printf .Values.global.joomlaDbHost -}}
{{- else -}}
    {{- printf "joomla-mysql" -}}
{{- end -}}
{{- end -}}

{{/*
Return DB NAME value (JOOMLA_DB_NAME MYSQL_DATABASE)
*/}} 
{{- define "common.dbname" -}}
{{- if .Values.global.dbname }}
    {{- printf .Values.global.dbname -}}
{{- else -}}
    {{- printf "joomla-db" -}}
{{- end -}}
{{- end -}}

{{/*
Return MYSQL_ROOT_PASSWORD value
*/}}
{{- define "common.rootpassword" -}}
{{- if .Values.auth.rootdbpassword }}
    {{- printf .Values.auth.rootdbpassword | b64enc -}}
{{- else -}}
    {{- printf (randAlphaNum 16) | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return JOOMLA_DB_PASSWOR / MYSQL_PASSWORD value
For CLI installation
*/}}
{{- define "common.dbpassword" -}}
{{- if .Values.global.dbpassword }}
    {{- printf .Values.global.dbpassword -}}
{{- else -}}
    {{- printf (randAlphaNum 16) -}}
{{- end -}}
{{- end -}}

{{/*
Return base64 JOOMLA_DB_PASSWOR / MYSQL_PASSWORD value
*/}}
{{- define "common.dbpassword.secret" -}}
{{- if .Values.global.dbpassword }}
    {{- printf .Values.global.dbpassword | b64enc -}}
{{- else -}}
    {{- printf (randAlphaNum 16) | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return DB USER value (JOOMLA_DB_USER)
*/}} 
{{- define "common.dbuser" -}}
{{- if .Values.global.dbuser }}
    {{- printf .Values.global.dbuser -}}
{{- else -}}
    {{- printf "joomla" -}}
{{- end -}}
{{- end -}}

{{/*
Validate and return the MYSQL port as a string
*/}}
{{- define "common.validateDbPort" -}}
{{- $dbport := toString .Values.global.joomlaDbPort -}}
{{- if not (regexMatch "^[0-9]+$" $dbport) -}}
    {{- fail "Error: global.joomlaDbPort must be an integer value." -}}
{{- else -}}
    {{- $dbport -}}
{{- end -}}
{{- end -}}

{{/*
Return MYSQL PORT (containerPort) as an integer
*/}}
{{- define "common.joomlaDbPort" -}}
{{- include "common.validateDbPort" . | int -}}
{{- end -}}

{{/*
Return MYSQL PORT (MYSQL_TCP_PORT) as a quoted string
*/}}
{{- define "common.joomlaDbPortStr" -}}
{{- include "common.validateDbPort" . | quote -}}
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
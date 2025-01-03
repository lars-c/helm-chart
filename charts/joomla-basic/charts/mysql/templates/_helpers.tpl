{{/*
Return MYSQL PORT (MYSQL_TCP_PORT)
*/}} 
{{- define "mysql.joomlaDbPort" -}}
{{- $dbport := toString .Values.global.joomlaDbPort -}}
{{- if not (regexMatch "^[0-9]+$" $dbport) -}}
    {{- fail "Error: global.joomlaDbPort must be an integer value." -}}
{{- else -}}
    {{- printf "%s" $dbport }}
{{- end -}}
{{- end -}}
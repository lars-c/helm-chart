{{/*
Return joomla service port
*/}} 
{{- define "joomla.service.port" -}}
{{- $serviceport := toString .Values.service.port -}}
{{- if not (regexMatch "^[0-9]+$" $serviceport) -}}
    {{- fail "Error: service.port must be an integer value." -}}
{{- else -}}
    {{- printf "%s" $serviceport -}}
{{- end -}}
{{- end -}}


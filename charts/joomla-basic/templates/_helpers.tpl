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

{{/*
Return Joomla database prefix.
If a manual prefix is provided, use it. Otherwise, generate a random one.
*/}} 
{{- define "joomla.dbprefix" -}}
{{- $dbPrefix := toString .Values.cli.dbPrefix -}}
{{- if $dbPrefix | trim | eq "" -}}
    {{- $prefix := randAlphaNum 5 -}}
    {{- printf "%s_" $prefix -}}
{{- else -}}
    {{- printf "%s" $dbPrefix -}}
{{- end -}}
{{- end -}}
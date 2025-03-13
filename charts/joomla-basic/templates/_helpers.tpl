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

{{/*
Return db encryption value
Test if cli.dbEncryption er 1, 2 or 3
*/}} 
{{- define "joomla.dbencryption" -}}
{{- $dbencryption := toString .Values.cli.dbEncryption -}}
{{- if has $dbencryption (list "0" "1" "2") -}}
    {{- printf "%s" $dbencryption -}}
{{- else -}}
    {{- fail  (printf "Invalid value '%s': must be one of '0', '1', or '2'" .Values.cli.dbEncryption) -}}
{{- end -}}
{{- end -}}
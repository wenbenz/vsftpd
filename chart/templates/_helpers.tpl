{{- define "pureftpd.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pureftpd.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{ include "pureftpd.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "pureftpd.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Returns the TLS secret name, or empty string when TLS is disabled. */}}
{{- define "pureftpd.tlsSecretName" -}}
{{- if .Values.tls.certManager.enabled -}}
{{ include "pureftpd.fullname" . }}-tls
{{- else -}}
{{ .Values.tls.certSecret }}
{{- end }}
{{- end }}

{{/* True when TLS is enabled by either mechanism. */}}
{{- define "pureftpd.tlsEnabled" -}}
{{- if or .Values.tls.certManager.enabled .Values.tls.certSecret -}}true{{- end }}
{{- end }}

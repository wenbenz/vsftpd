{{- define "vsftpd.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "vsftpd.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{ include "vsftpd.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "vsftpd.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Returns the TLS secret name, or empty string when TLS is disabled. */}}
{{- define "vsftpd.tlsSecretName" -}}
{{- if .Values.tls.certManager.enabled -}}
{{ include "vsftpd.fullname" . }}-tls
{{- else -}}
{{ .Values.tls.certSecret }}
{{- end }}
{{- end }}

{{/* True when TLS is enabled by either mechanism. */}}
{{- define "vsftpd.tlsEnabled" -}}
{{- if or .Values.tls.certManager.enabled .Values.tls.certSecret -}}true{{- end }}
{{- end }}

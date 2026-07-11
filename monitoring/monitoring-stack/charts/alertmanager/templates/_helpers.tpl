{{- define "alertmanager.fullname" -}}
alertmanager
{{- end -}}

{{- define "alertmanager.labels" -}}
app.kubernetes.io/name: alertmanager
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-monitoring
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "alertmanager.selectorLabels" -}}
app.kubernetes.io/name: alertmanager
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

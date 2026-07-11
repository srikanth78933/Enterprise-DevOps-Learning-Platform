{{- define "enterprise-app.labels" -}}
app.kubernetes.io/part-of: enterprise-devops-platform
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

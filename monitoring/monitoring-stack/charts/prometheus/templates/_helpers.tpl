{{- define "prometheus.fullname" -}}
prometheus
{{- end -}}

{{- define "prometheus.labels" -}}
app.kubernetes.io/name: prometheus
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-monitoring
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "prometheus.selectorLabels" -}}
app.kubernetes.io/name: prometheus
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

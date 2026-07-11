{{- define "grafana.fullname" -}}
grafana
{{- end -}}

{{- define "grafana.labels" -}}
app.kubernetes.io/name: grafana
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-monitoring
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "grafana.selectorLabels" -}}
app.kubernetes.io/name: grafana
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

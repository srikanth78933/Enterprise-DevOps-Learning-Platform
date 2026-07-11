{{- define "node-exporter.fullname" -}}
node-exporter
{{- end -}}

{{- define "node-exporter.labels" -}}
app.kubernetes.io/name: node-exporter
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-monitoring
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "node-exporter.selectorLabels" -}}
app.kubernetes.io/name: node-exporter
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

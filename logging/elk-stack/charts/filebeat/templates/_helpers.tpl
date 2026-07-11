{{- define "filebeat.fullname" -}}
filebeat
{{- end -}}

{{- define "filebeat.labels" -}}
app.kubernetes.io/name: filebeat
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-logging
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "filebeat.selectorLabels" -}}
app.kubernetes.io/name: filebeat
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

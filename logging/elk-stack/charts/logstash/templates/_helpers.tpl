{{- define "logstash.fullname" -}}
logstash
{{- end -}}

{{- define "logstash.labels" -}}
app.kubernetes.io/name: logstash
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-logging
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "logstash.selectorLabels" -}}
app.kubernetes.io/name: logstash
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

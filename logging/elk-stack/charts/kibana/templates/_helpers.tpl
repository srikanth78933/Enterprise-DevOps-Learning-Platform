{{- define "kibana.fullname" -}}
kibana
{{- end -}}

{{- define "kibana.labels" -}}
app.kubernetes.io/name: kibana
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-logging
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "kibana.selectorLabels" -}}
app.kubernetes.io/name: kibana
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

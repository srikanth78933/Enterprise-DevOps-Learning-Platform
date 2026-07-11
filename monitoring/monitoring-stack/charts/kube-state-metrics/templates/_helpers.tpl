{{- define "kube-state-metrics.fullname" -}}
kube-state-metrics
{{- end -}}

{{- define "kube-state-metrics.labels" -}}
app.kubernetes.io/name: kube-state-metrics
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-monitoring
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "kube-state-metrics.selectorLabels" -}}
app.kubernetes.io/name: kube-state-metrics
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Fixed name rather than release-prefixed (the usual Helm "fullname" pattern)
because backend/values.yaml hardcodes DB_URL to jdbc:mysql://mysql:3306/...
This chart is meant for exactly one release per namespace - the same
one-instance assumption Project 2's raw manifests already made. Document
this tradeoff rather than hide it: a truly reusable chart would template
this and thread it through backend's values instead.
*/}}
{{- define "mysql.fullname" -}}
mysql
{{- end -}}

{{- define "mysql.labels" -}}
app.kubernetes.io/name: mysql
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: enterprise-devops-platform
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "mysql.selectorLabels" -}}
app.kubernetes.io/name: mysql
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

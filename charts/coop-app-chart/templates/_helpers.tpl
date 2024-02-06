{{/*
Expand the name of the chart.
*/}}
{{- define "coop-app-chart.name" -}}
{{- if ge (len .Values.name) 63 -}}
{{- fail ".Values.name has more than 63 charracters" -}}
{{- end -}}
{{ .Values.name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.:wrap()
*/}}
{{- define "coop-app-chart.chart" -}}
{{- printf "coop-app-chart-%s" .Chart.Version }}
{{- end }}

{{/*:
Common labels
*/}}
{{- define "coop-app-chart.labels" -}}
helm.sh/chart: {{ include "coop-app-chart.chart" . }}
{{ include "coop-app-chart.selectorLabels" . }}
{{- end }}

{{/*:
Pod labels
*/}}
{{- define "coop-app-chart.podLabels" -}}
{{ include "coop-app-chart.selectorLabels" . }}
tags.datadoghq.com/env: {{ .Values.environment }}
tags.datadoghq.com/service: {{ .Values.name }}
tags.datadhoghq.com/version: {{ .Values.image.tag }}
{{- end }}

{{/*:
Deployment labels
*/}}
{{- define "coop-app-chart.deploymentLabels" -}}
helm.sh/chart: {{ include "coop-app-chart.chart" . }}
{{ include "coop-app-chart.selectorLabels" . }}
tags.datadoghq.com/env: {{ .Values.environment }}
tags.datadoghq.com/service: {{ .Values.name }}
tags.datadhoghq.com/version: {{ .Values.image.tag }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "coop-app-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "coop-app-chart.name" . }}
{{- end }}

{{/*
Port-naming
*/}}
{{- define "coop-app-chart.portName" -}}
{{- $name := .Values.name -}}
{{- if .Values.connectivity.gRPC.enabled -}}
{{- $name = print "grpc-" $name -}}
{{- end }}
{{- if gt (len $name) 15 -}}
{{- $name = substr 0 15 $name -}}
{{- end -}}
{{ $name }}
{{- end }}

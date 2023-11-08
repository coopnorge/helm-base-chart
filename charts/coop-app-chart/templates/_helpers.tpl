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
{{- printf "%s-%s" ( .Chart.Name | trunc (int (sub 63 (len .Chart.Version))) ) .Chart.Version | replace "+" "_" | trimSuffix "-" }}
{{- end }}

{{/*:wrap()
Common labels
*/}}
{{- define "coop-app-chart.labels" -}}
helm.sh/chart: {{ include "coop-app-chart.chart" . }}
{{ include "coop-app-chart.selectorLabels" . }}
tags.datadoghq.com/env: {{ .Values.environment }}
tags.datadoghq.com/service: {{ .Values.name }}
tags.datadhoghq.com/version: {{ last (splitList ":" .Values.image) }}
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
{{- if .Values.connectivity.gRPC.enabled -}}
grpc-{{ .Values.name }}
{{- else -}}
{{ .Values.name }}
{{- end }}
{{- end }}

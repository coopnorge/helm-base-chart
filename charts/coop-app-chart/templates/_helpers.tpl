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
tags.datadoghq.com/version: {{ .Values.image.tag }}
{{- end }}

{{/*
Deployment labels
*/}}
{{- define "coop-app-chart.deploymentLabels" -}}
helm.sh/chart: {{ include "coop-app-chart.chart" . }}
{{ include "coop-app-chart.selectorLabels" . }}
tags.datadoghq.com/env: {{ .Values.environment }}
tags.datadoghq.com/service: {{ .Values.name }}
tags.datadoghq.com/version: {{ .Values.image.tag }}
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
{{- if gt (len .Values.name ) 15 }}
{{- substr 0 15 .Values.name -}}
{{- else -}}
{{- .Values.name -}}
{{- end }}
{{- end }}

{{/*
App-Protocol
*/}}
{{- define "coop-app-chart.appProtocol" -}}
{{- if .Values.connectivity.gRPC.enabled -}}
grpc
{{- else -}}
http
{{- end }}
{{- end }}


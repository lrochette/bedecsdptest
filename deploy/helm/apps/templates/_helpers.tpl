{{/* vim: set filetype=mustache: */}}
{{/*
Application Name
*/}}
{{- define "dashboard-application.name" -}}
{{- required "A Valid .Values.app.name is required!" .Values.app.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Application Labels
*/}}
{{- define "dashboard-application.labels" -}}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "dashboard-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "dashboard-application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dashboard-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.bedegaming.com/inMaintenance: "false"
{{- end -}}

{{/*
Metadata
*/}}
{{- define "dashboard-application.metadata" -}}
name: {{ include "dashboard-application.name" . }}
namespace: {{ .Release.Namespace }}
labels:
  {{- include "dashboard-application.labels" . | nindent 4 }}
annotations:
  maintainer: {{ default "Bede" .Values.app.maintainer }}
  slackChannel: {{ default "guild-fabric" .Values.app.slackChannel }}
  gitRepo: {{ default "http://github.com/bedegaming" .Values.app.repository }}
{{- end -}}

{{/*
Image Name in the form <repo>/<image_name>:<image_tag>
*/}}
{{- define "dashboard-application.image" -}}
{{- $repo := required ".Values.container.repository is required!" .Values.container.repository -}}
{{- $name := required ".Values.container.imageName is required!" .Values.container.imageName -}}
{{- $version := default .Chart.AppVersion .Values.app.version -}}
{{- printf "%s/%s:%s" $repo $name $version -}}
{{- end -}}

{{/*
Ingress host
*/}}
{{- define "dashboard-application.ingressHost" -}}
{{- if or (empty .Values.ingress.hostname) (empty .Values.ingress.domain) -}}
{{- required "A valid .Values.ingress.host is required!" .Values.ingress.host -}}
{{- else -}}
{{- printf "%s.%s.%s" .Values.ingress.hostname .Release.Namespace .Values.ingress.domain -}}
{{- end -}}
{{- end -}}

{{/*
Ingress TLS host
*/}}
{{- define "dashboard-application.ingressTlsHost" -}}
{{- if empty .Values.ingress.domain -}}
{{- include "dashboard-application.ingressHost" . -}}
{{- else -}}
{{- printf "*.%s.%s" .Release.Namespace .Values.ingress.domain | quote -}}
{{- end -}}
{{- end -}}

{{/*
Ingress TLS secret
*/}}
{{- define "dashboard-application.ingressTlsSecret" -}}
{{- if empty .Values.ingress.domain -}}
{{- printf "%s-ingress-tls" (include "dashboard-application.name" .) -}}
{{- else -}}
{{- printf "%s-wildcard-ingress-tls" .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Ingress target service 
*/}}
{{- define "bede-application.ingressTargetService.name" -}}
{{- if .Values.ingress.targetService -}}
{{ .Values.ingress.targetService.name | default (include "dashboard-application.name" .) }}
{{- else -}}
{{- include "dashboard-application.name" . -}}
{{- end -}}
{{- end -}}

{{/*
Ingress target service 
*/}}
{{- define "bede-application.ingressTargetService.port" -}}
{{- if .Values.ingress.targetService -}}
{{ .Values.ingress.targetService.port | default .Values.service.port  }}
{{- else -}}
{{- .Values.service.port -}}
{{- end -}}
{{- end -}}
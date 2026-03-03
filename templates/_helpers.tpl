{{/*
Expand the name of the chart.
*/}}
{{- define "citadel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "citadel.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "citadel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "citadel.labels" -}}
helm.sh/chart: {{ include "citadel.chart" . }}
{{ include "citadel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "citadel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "citadel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "citadel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "citadel.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the name of the Secret to use.
If existingSecret is set, use that; otherwise use release-name-secrets.
*/}}
{{- define "citadel.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret }}
{{- else }}
{{- printf "%s-secrets" .Release.Name }}
{{- end }}
{{- end }}

{{/*
Build the DATABASE_URL.
When the Bitnami PostgreSQL subchart is enabled, construct the URL from its values.
Otherwise fall back to externalDatabase.url.
*/}}
{{- define "citadel.databaseUrl" -}}
{{- if .Values.postgresql.enabled }}
{{- $host := printf "%s-postgresql" .Release.Name }}
{{- $port := "5432" }}
{{- $user := .Values.postgresql.auth.username }}
{{- $db   := .Values.postgresql.auth.database }}
{{- printf "postgresql://%s:$(DATABASE_PASSWORD)@%s:%s/%s" $user $host $port $db }}
{{- else }}
{{- .Values.externalDatabase.url }}
{{- end }}
{{- end }}

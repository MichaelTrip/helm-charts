{{- define "journiv.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "journiv.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "journiv.labels" -}}
helm.sh/chart: {{ include "journiv.chart" . }}
app.kubernetes.io/name: {{ include "journiv.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/version: {{ .Chart.Version | quote }}
{{- end -}}

{{- define "journiv.selectorLabels" -}}
app.kubernetes.io/name: {{ include "journiv.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "journiv.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "journiv.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- include "journiv.fullname" . -}}
{{- end -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "journiv.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{- define "journiv.postgresSecretName" -}}
{{- if .Values.config.postgres.existingSecret -}}
{{- .Values.config.postgres.existingSecret -}}
{{- else -}}
{{- printf "%s-postgres" (include "journiv.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "journiv.appSecretName" -}}
{{- if .Values.config.existingSecret -}}
{{- .Values.config.existingSecret -}}
{{- else -}}
{{- printf "%s-app" (include "journiv.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "journiv.appSecretValue" -}}
{{- required "Set config.secretKey or config.existingSecret; credentials must be stable across Helm renders (reuse the current SECRET_KEY when upgrading)." .Values.config.secretKey -}}
{{- end -}}

{{- define "journiv.postgresPasswordValue" -}}
{{- required "Set postgresql.auth.password or config.postgres.existingSecret; credentials must be stable across Helm renders (reuse the current POSTGRES_PASSWORD when upgrading)." .Values.postgresql.auth.password -}}
{{- end -}}

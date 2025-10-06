{{/*
Expand the name of the chart.
*/}}
{{- define "hello-world-example.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hello-world-example.fullname" -}}
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
{{- define "hello-world-example.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hello-world-example.labels" -}}
helm.sh/chart: {{ include "hello-world-example.chart" . }}
{{ include "hello-world-example.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hello-world-example.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hello-world-example.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hello-world-example.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hello-world-example.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the HTML content with custom values
*/}}
{{- define "hello-world-example.htmlContent" -}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ .Values.app.message }}</title>
    <style>
{{ .Values.html.customCSS | indent 8 }}
    </style>
</head>
<body>
    <div class="container">
        <h1>{{ .Values.app.message }}</h1>
        <p>{{ .Values.app.greeting }}</p>
        <div class="info">
            <p><strong>Environment:</strong> {{ .Values.app.environment }}</p>
            <p><strong>Version:</strong> {{ .Values.app.version }}</p>
            <p><strong>Namespace:</strong> {{ .Release.Namespace }}</p>
            <p><strong>Release:</strong> {{ .Release.Name }}</p>
            <p><strong>Chart Version:</strong> {{ .Chart.Version }}</p>
            {{- if .Values.extraEnvVars }}
            <p><strong>Extra Variables:</strong></p>
            <ul>
                {{- range .Values.extraEnvVars }}
                <li>{{ .name }}: {{ .value }}</li>
                {{- end }}
            </ul>
            {{- end }}
        </div>
    </div>
</body>
</html>
{{- end }}

{{/*
OpenShift compatibility check
*/}}
{{- define "hello-world-example.isOpenShift" -}}
{{- if .Capabilities.APIVersions.Has "route.openshift.io/v1" -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

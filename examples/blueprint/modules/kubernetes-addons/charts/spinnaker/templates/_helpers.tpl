{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "spinnaker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spinnaker.fullname" -}}
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
Common labels for metadata.
*/}}
{{- define "spinnaker.standard-labels-base" -}}
app: {{ include "spinnaker.fullname" . | quote }}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
{{- end -}}
{{- define "spinnaker.standard-labels" -}}
{{ include "spinnaker.standard-labels-base" . }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end -}}

{{/*
A set of common selector labels for resources.
*/}}
{{- define "spinnaker.standard-selector-labels" -}}
app: {{ include "spinnaker.fullname" . | quote }}
release: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create comma separated list of namespaces in Kubernetes
*/}}
{{- define "nameSpaces" -}}
{{- join "," .Values.kubeConfig.nameSpaces }}
{{- end -}}

{{/*
Create comma separated list of omitted namespaces in Kubernetes
*/}}
{{- define "omittedNameSpaces" -}}
{{- join "," .Values.kubeConfig.omittedNameSpaces }}
{{- end -}}

{{- define "omittedKinds" -}}
{{- join "," .Values.kubeConfig.omittedKinds }}
{{- end -}}

{{- define "k8sKinds" -}}
{{- join "," .Values.kubeConfig.kinds }}
{{- end -}}

{{/*
Create name of kubeconfig file to use when setting up kubernetes provider
*/}}
{{- define "spinnaker.kubeconfig" -}}
{{- if .Values.kubeConfig.encryptedKubeconfig }}
{{- printf .Values.kubeConfig.encryptedKubeconfig | toString -}}
{{- else }}
{{- printf "/opt/kube/%s" .Values.kubeConfig.secretKey  | toString -}}
{{- end }}
{{- end }}

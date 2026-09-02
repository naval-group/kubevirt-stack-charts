{{/*
Chart name.
*/}}
{{- define "kubevirt-stack.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "kubevirt-stack.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: kubevirt-stack
{{- end }}

{{/*
Resolve image with optional global registry override.
*/}}
{{- define "kubevirt-stack.image" -}}
{{- $registry := "" -}}
{{- if and .global .global.imageRegistry -}}
  {{- $registry = .global.imageRegistry -}}
{{- end -}}
{{- if $registry -}}
  {{- $parts := splitList "/" .repository -}}
  {{- $repoPath := join "/" (rest $parts) -}}
  {{- printf "%s/%s:%s" $registry $repoPath .tag -}}
{{- else -}}
  {{- printf "%s:%s" .repository .tag -}}
{{- end -}}
{{- end }}

{{/*
Global imagePullSecrets.
*/}}
{{- define "kubevirt-stack.imagePullSecrets" -}}
{{- if and .Values.global .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Resolve namespace.
*/}}
{{- define "kubevirt-stack.namespace" -}}
{{- if .Values.namespace -}}
  {{- .Values.namespace -}}
{{- else -}}
  kube-system
{{- end -}}
{{- end }}

{{/*
Merge global and local nodeSelector.
*/}}
{{- define "kubevirt-stack.nodeSelector" -}}
{{- $merged := dict "kubernetes.io/os" "linux" -}}
{{- if .global -}}
  {{- $merged = merge $merged .global -}}
{{- end -}}
{{- if .local -}}
  {{- $merged = merge $merged .local -}}
{{- end -}}
{{- toYaml $merged -}}
{{- end }}

{{/*
Merge global and local tolerations.
*/}}
{{- define "kubevirt-stack.tolerations" -}}
{{- $result := list -}}
{{- if .global -}}
  {{- $result = .global -}}
{{- end -}}
{{- if .local -}}
  {{- $result = concat $result .local -}}
{{- end -}}
{{- if $result -}}
{{- toYaml $result -}}
{{- end -}}
{{- end }}

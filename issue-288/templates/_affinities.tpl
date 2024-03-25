{{/*
Return a nodeAffinity definition
{{ include "common.affinities.nodes" . -}}
*/}}
{{- define "common.affinities.nodes" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: topology.kubernetes.io/zone
      operator: In
      values:
      - antarctica-east1
      - antarctica-west1
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    preference:
      matchExpressions:
      - key: another-node-label-key
        operator: In
        values:
        - another-node-label-value
{{- end -}}

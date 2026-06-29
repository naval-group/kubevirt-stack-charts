#!/usr/bin/env bash
set -euo pipefail

# update-crds.sh — Fetches upstream CRDs for each chart's crds/ directory.
#
# Downloads CRDs from upstream GitHub releases/repos and places them
# in each chart's crds/ directory for Helm to install on first deploy.
#
# Usage:
#   ./scripts/update-crds.sh              # Download + update crds/
#   ./scripts/update-crds.sh --skip-download  # Only copy from upstream-crds/ to crds/

CHART_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKIP_DOWNLOAD=false
[ "${1:-}" = "--skip-download" ] && SKIP_DOWNLOAD=true

# Upstream CRD sources
# Format: chart_name|version|source_type|url_or_pattern[|extra]
#   source_type: "release" = extract CRDs from operator release YAML
#                "raw"     = direct CRD file URL
#                "dir"     = clone repo + copy directory
SOURCES=(
  "kubevirt|v1.8.1|release|https://github.com/kubevirt/kubevirt/releases/download/v1.8.1/kubevirt-operator.yaml"
  "cdi|v1.65.0|release|https://github.com/kubevirt/containerized-data-importer/releases/download/v1.65.0/cdi-operator.yaml"
  "multus|main|raw|https://raw.githubusercontent.com/k8snetworkplumbingwg/network-attachment-definition-client/master/artifacts/networks-crd.yaml"
  "ipam-controller|main|raw|https://raw.githubusercontent.com/k8snetworkplumbingwg/ipamclaims/main/artifacts/k8s.cni.cncf.io_ipamclaims.yaml"
  "butane-operator|main|raw|https://raw.githubusercontent.com/Naval-Group/butane-operator/main/config/crd/bases/butane.operators.naval-group.com_butaneconfigs.yaml"
  "aaq|v1.7.0|release|https://github.com/kubevirt/application-aware-quota/releases/download/v1.7.0/aaq-operator.yaml"
  "forklift|release-2.12|dir|https://github.com/kubev2v/forklift.git|operator/config/crd/bases"
  "hostpath-provisioner|v0.25.0|raw|https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/release-v0.25/deploy/hostpathprovisioner_crd.yaml"
)

download_crds() {
  local chart="$1" version="$2" source_type="$3" url="$4" extra="${5:-}"
  local outdir="${CHART_ROOT}/charts/${chart}/upstream-crds"
  mkdir -p "$outdir"

  case "$source_type" in
    release)
      echo "    Fetching from release YAML..."
      curl -sL "$url" | python3 -c "
import sys, yaml
for doc in yaml.safe_load_all(sys.stdin):
    if doc and doc.get('kind') == 'CustomResourceDefinition':
        name = doc['metadata']['name']
        with open('${outdir}/' + name + '.yaml', 'w') as f:
            yaml.dump(doc, f, default_flow_style=False)
        print(f'      {name}')
"
      ;;
    raw)
      echo "    Fetching raw CRD..."
      local filename
      filename=$(basename "$url")
      curl -sL "$url" -o "${outdir}/${filename}"
      if head -1 "${outdir}/${filename}" | grep -q "^404"; then
        echo "      ERROR: 404 Not Found"
        rm -f "${outdir}/${filename}"
        return 1
      fi
      echo "      ${filename}"
      ;;
    dir)
      echo "    Cloning repo for CRD dir..."
      local tmpdir
      tmpdir=$(mktemp -d)
      git clone --depth=1 --branch "$version" "$url" "$tmpdir" 2>/dev/null
      cp "$tmpdir"/${extra}/*.yaml "$outdir/" 2>/dev/null
      local count
      count=$(ls "$outdir"/*.yaml 2>/dev/null | wc -l)
      echo "      ${count} CRD file(s)"
      rm -rf "$tmpdir"
      ;;
  esac
}

copy_to_crds() {
  local chart="$1"
  local srcdir="${CHART_ROOT}/charts/${chart}/upstream-crds"
  local dstdir="${CHART_ROOT}/charts/${chart}/crds"

  if [ ! -d "$srcdir" ] || [ -z "$(ls "$srcdir"/*.yaml 2>/dev/null)" ]; then
    echo "    SKIP (no upstream-crds/)"
    return
  fi

  mkdir -p "$dstdir"
  local count=0

  for src in "$srcdir"/*.yaml; do
    local dst="${dstdir}/$(basename "$src")"
    # Copy and strip trailing --- (causes Helm to skip the file)
    python3 -c "
with open('$src') as f:
    content = f.read().rstrip()
while content.endswith('---'):
    content = content[:-3].rstrip()
with open('$dst', 'w') as f:
    f.write(content + '\n')
"
    count=$((count + 1))
  done

  echo "    OK ${count} file(s) -> crds/"
}

echo "============================================"
echo "  KubeVirt Stack — CRD Update"
echo "============================================"
echo ""

for entry in "${SOURCES[@]}"; do
  IFS='|' read -r chart version source_type url extra <<< "$entry"
  echo "  ${chart} (${version}):"

  if [ "$SKIP_DOWNLOAD" = false ]; then
    download_crds "$chart" "$version" "$source_type" "$url" "$extra"
  else
    echo "    Skipping download (using existing upstream-crds/)"
  fi

  copy_to_crds "$chart"
  echo ""
done

echo "Done."

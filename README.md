# KubeVirt Stack Charts

[![Lint](https://github.com/naval-group/kubevirt-stack-charts/actions/workflows/lint.yml/badge.svg)](https://github.com/naval-group/kubevirt-stack-charts/actions/workflows/lint.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/naval-group/kubevirt-stack-charts/badge)](https://scorecard.dev/viewer/?uri=github.com/naval-group/kubevirt-stack-charts)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/kubevirt-stack-charts)](https://artifacthub.io/packages/search?repo=kubevirt-stack-charts)
[![License](https://img.shields.io/github/license/naval-group/kubevirt-stack-charts)](https://github.com/naval-group/kubevirt-stack-charts/blob/main/LICENSE)

Community Helm charts for [KubeVirt](https://kubevirt.io) on vanilla Kubernetes. Each chart is independent and can be installed individually — pick only what you need.

> **Disclaimer:** This project provides community-maintained Helm charts for deploying KubeVirt ecosystem components. We are not affiliated with or endorsed by the upstream projects. Each component is developed and maintained by its respective project. We only maintain the Helm chart packaging.

## Charts

| Chart | Upstream Project | Description | Version |
|---|---|---|---|
| [kubevirt](charts/kubevirt) | [kubevirt/kubevirt](https://github.com/kubevirt/kubevirt) | Core virtualization platform | v1.8.4 |
| [cdi](charts/cdi) | [kubevirt/containerized-data-importer](https://github.com/kubevirt/containerized-data-importer) | Disk image management | v1.65.0 |
| [multus](charts/multus) | [k8snetworkplumbingwg/multus-cni](https://github.com/k8snetworkplumbingwg/multus-cni) | Multi-network CNI (standalone or RKE2 HelmChartConfig) | v4.1.4 |
| [kubemacpool](charts/kubemacpool) | [k8snetworkplumbingwg/kubemacpool](https://github.com/k8snetworkplumbingwg/kubemacpool) | MAC address allocation for VMs | v0.45.0 |
| [butane-operator](charts/butane-operator) | [Naval-Group/butane-operator](https://github.com/Naval-Group/butane-operator) | Butane/Ignition transpiler for CoreOS VMs | v0.1.1-rc2 |
| [vm-console-proxy](charts/vm-console-proxy) | [kubevirt/vm-console-proxy](https://github.com/kubevirt/vm-console-proxy) | Token-based VNC/serial console proxy | v0.8.0 |
| [ipam-controller](charts/ipam-controller) | [kubevirt/ipam-extensions](https://github.com/kubevirt/ipam-extensions) | Persistent VM IP addresses | v0.6.1 |
| [delete-protection](charts/delete-protection) | — | Prevent accidental VM deletion (ValidatingAdmissionPolicy) | v1.8.1 |
| [monitoring](charts/monitoring) | — | ServiceMonitors and PrometheusRules for KubeVirt/CDI | v1.8.1 |
| [hostpath-provisioner](charts/hostpath-provisioner) | [kubevirt/hostpath-provisioner-operator](https://github.com/kubevirt/hostpath-provisioner-operator) | HostPath CSI storage for dev/test environments | v0.25.0 |
| [aaq](charts/aaq) | [kubevirt/application-aware-quota](https://github.com/kubevirt/application-aware-quota) | Application-Aware Quota for VM resource management | v1.7.0 |
| [forklift](charts/forklift) | [kubev2v/forklift](https://github.com/kubev2v/forklift) | VM migration from external platforms (with inventory proxy) | release-2.12 |
| [cloud-provider-kubevirt](charts/cloud-provider-kubevirt) | [kubevirt/cloud-provider-kubevirt](https://github.com/kubevirt/cloud-provider-kubevirt) | Kubernetes cloud provider for KubeVirt | v0.6.0 |
| [vm-templates](charts/vm-templates) | [kubevirt/virt-template](https://github.com/kubevirt/virt-template) | Common VM templates (Fedora, Ubuntu, CentOS, Windows) | v1.8.1 |

## Prerequisites

- Kubernetes >= 1.30
- Helm >= 3.x
- [cert-manager](https://cert-manager.io) (required by KubeMacPool, IPAM Controller, HostPath Provisioner)

Optional:
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) (for monitoring)
- An Ingress controller with backend HTTPS support (for CDI upload proxy and Forklift export proxy)

## Quick Start

```bash
# Required prerequisite
helm install cert-manager jetstack/cert-manager \
  -n cert-manager --create-namespace --set crds.enabled=true

# Core KubeVirt
helm install kubevirt charts/kubevirt -n kubevirt --create-namespace
helm install cdi charts/cdi -n cdi --create-namespace

# Networking
helm install multus charts/multus -n kube-system --set rke2.enabled=true  # for RKE2
helm install kubemacpool charts/kubemacpool -n kubemacpool-system --create-namespace

# Essentials
helm install butane-operator charts/butane-operator -n butane-operator-system --create-namespace
helm install vm-console-proxy charts/vm-console-proxy -n kubevirt
helm install ipam-controller charts/ipam-controller -n kubevirt-ipam-controller-system --create-namespace
helm install delete-protection charts/delete-protection -n kubevirt
```

Add optional components as needed:

```bash
# Storage (dev/test)
helm install hostpath-provisioner charts/hostpath-provisioner \
  -n hostpath-provisioner --create-namespace

# Monitoring (requires kube-prometheus-stack)
helm install monitoring charts/monitoring -n kubevirt

# Application-Aware Quota
helm install aaq charts/aaq -n aaq --create-namespace

# VM Migration (Forklift)
helm install forklift charts/forklift -n konveyor-forklift --create-namespace
```

Verify:

```bash
kubectl get kubevirt -n kubevirt    # Should show "Deployed"
kubectl get cdi                     # Should show "Deployed"
kubectl get storageprofile          # Should show "hostpath-csi" (if HPP installed)
```

## Configuration

Each chart has its own `values.yaml` and `values.schema.json` for full validation. Run `helm show values charts/<name>` to see all options.

### Custom Namespaces

Every chart supports custom namespaces:

```bash
helm install kubevirt charts/kubevirt -n my-kubevirt --create-namespace \
  --set namespace=my-kubevirt
```

### RKE2 Clusters

RKE2 ships Multus built-in. Use HelmChartConfig mode instead of standalone deployment:

```bash
helm install multus charts/multus -n kube-system --set rke2.enabled=true
```

This configures the existing RKE2 Multus with thick plugin + dynamic networks controller.

### Software Emulation (dev/CI)

For environments without hardware virtualization (nested VMs, CI runners):

```bash
helm install kubevirt charts/kubevirt -n kubevirt --create-namespace \
  --set cr.configuration.developerConfiguration.useEmulation=true
```

### GPU Passthrough (vGPU)

```yaml
cr:
  configuration:
    mediatedDevicesConfiguration:
      mediatedDeviceTypes:
        - nvidia-222
        - nvidia-228
```

### Expose CDI Upload Proxy

For `virtctl image-upload` without port-forwarding:

```bash
helm upgrade cdi charts/cdi -n cdi \
  --set uploadProxy.externalMode.enabled=true \
  --set uploadProxy.externalMode.hostname=upload.mycluster.example.com \
  --set uploadProxy.externalMode.ingressClassName=nginx
```

### Expose KubeVirt Export Proxy (for Forklift)

Required on **source** clusters for cross-cluster VM migration:

```bash
helm upgrade kubevirt charts/kubevirt -n kubevirt \
  --set exportProxy.externalMode.enabled=true \
  --set exportProxy.externalMode.hostname=export.mycluster.example.com \
  --set exportProxy.externalMode.ingressClassName=nginx
```

## Forklift Inventory Proxy

When Forklift is installed, the chart deploys an OpenResty-based inventory proxy that exposes the Forklift inventory API through the Kubernetes API service proxy. This is required on vanilla Kubernetes where kubeconfigs use client certificates (RKE2, kubeadm, k3s) instead of bearer tokens.

### How it works

```
Client → k8s API service proxy → kube RBAC gate → OpenResty → forklift-inventory
                                  (services/proxy   (injects SA    (returns cached
                                   permission)       token per      inventory data)
                                                     request)
```

The proxy reads a projected `forklift-controller` ServiceAccount token on every request (auto-rotated by kubelet, no restart needed). For OIDC users, the bearer token is forwarded as-is to forklift-inventory for per-user, per-provider RBAC.

### Security

Access is controlled by a namespaced `Role` named `forklift-inventory-proxy-access`. Only users with a `RoleBinding` to this role can reach the proxy through the k8s API service proxy.

| Auth method | What happens | RBAC enforcement |
|---|---|---|
| **OIDC bearer token** | Token forwarded to forklift-inventory as-is | forklift-inventory checks per-user, per-provider RBAC |
| **Client cert** (RKE2/kubeadm) | SA token injected by proxy | k8s API checks `services/proxy` via Role |

Grant access to non-admin users:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team-forklift-access
  namespace: konveyor-forklift
roleRef:
  kind: Role
  name: forklift-inventory-proxy-access
subjects:
  - kind: Group
    name: infra-team
```

### API endpoint

For tools like [headlamp-kubevirt](https://github.com/naval-group/headlamp-kubevirt):

```
/api/v1/namespaces/<forklift-ns>/services/forklift-inventory-proxy:8080/proxy/providers/openshift
```

## Uninstall

Each chart can be uninstalled independently:

```bash
helm uninstall kubevirt -n kubevirt
helm uninstall cdi -n cdi
helm uninstall forklift -n konveyor-forklift
# etc.
```

Uninstall in reverse order of install to avoid webhook/finalizer issues. Operators clean up their own CRs when they shut down.

## Prerequisite Checks

Charts that depend on external CRDs include built-in validation and fail with a clear error message if prerequisites are missing:

- **kubemacpool, ipam-controller, hostpath-provisioner**: require cert-manager
- **monitoring**: requires kube-prometheus-stack (Prometheus Operator)
- **kubevirt, cdi**: export/upload proxy features check for cert-manager only when enabled

## Values Schema

All values are validated via `values.schema.json` (every chart). Run `helm lint charts/<name>` to validate your configuration. Invalid MAC addresses, unknown fields, wrong types — all caught at lint time.

## UI

This chart collection pairs with [headlamp-kubevirt](https://github.com/naval-group/headlamp-kubevirt), a [Headlamp](https://headlamp.dev) plugin for web-based KubeVirt management on vanilla Kubernetes.

## For Maintainers

### Updating CRDs

When bumping upstream component versions, update the version numbers in `scripts/update-crds.sh` and run:

```bash
./scripts/update-crds.sh
```

This downloads CRDs from upstream GitHub repositories and places them in each chart's `crds/` directory. Commit the updated files.

### Chart Structure

Each chart follows a consistent structure:

```
charts/<name>/
  Chart.yaml
  values.yaml
  values.schema.json
  templates/
    _helpers.tpl
    namespace.yaml
    serviceaccount.yaml
    rbac.yaml
    deployment.yaml
    cr.yaml          # operator CR (if applicable)
    webhook.yaml     # webhooks (if applicable)
  crds/              # CRDs installed by Helm on first install
  upstream-crds/     # raw upstream CRD files (script input)
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All commits must be signed off (DCO).

## License

Apache-2.0. See [LICENSE](LICENSE).

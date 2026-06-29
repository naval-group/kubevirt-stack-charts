# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 0.x     | Yes       |

## Reporting a Vulnerability

If you discover a security issue, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, use [GitHub Security Advisories](https://github.com/naval-group/kubevirt-stack-charts/security/advisories/new) to report privately.

You should receive a response within 48 hours.

## Security Practices

This Helm chart follows security best practices:

- All containers run as non-root with minimal capabilities
- Pod Security Admission labels (`privileged` only where required by KubeVirt)
- RBAC follows least-privilege principle per component
- CRDs use `helm.sh/resource-policy: keep` to prevent accidental deletion
- Forklift inventory proxy uses k8s RBAC (`services/proxy`) as security gate
- No secrets are generated or stored by the chart itself
- cert-manager integration for TLS certificate lifecycle

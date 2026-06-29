# Contributing to KubeVirt Stack Charts

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Developer Certificate of Origin (DCO)

This project uses the [Developer Certificate of Origin](https://developercertificate.org/) (DCO). All commits must be signed off to certify that you wrote or have the right to submit the code.

Sign off your commits with:

```bash
git commit -s -m "Your commit message"
```

This adds a `Signed-off-by` line to your commit message.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch: `git checkout -b my-feature`
4. Make your changes
5. Validate: `helm lint .` and `helm template kubevirt-stack .`
6. Commit with sign-off: `git commit -s -m "feat: description"`
7. Push and open a Pull Request

## Development

```bash
# Lint the chart
helm lint .

# Lint with all components enabled
helm lint . --set aaq.enabled=true --set forklift.enabled=true --set hostpath-provisioner.enabled=true --set monitoring.enabled=true

# Template and inspect output
helm template kubevirt-stack .

# Diff against a running cluster
helm diff upgrade kubevirt-stack . --namespace kubevirt

# Regenerate CRD templates after updating upstream-crds/
./scripts/update-crds.sh
```

### Adding a new subchart

1. Create `charts/<name>/` with `Chart.yaml`, `values.yaml`, `values.schema.json`, and `templates/`
2. Copy `_helpers.tpl` from an existing subchart (shared helpers)
3. Add the dependency in the root `Chart.yaml`
4. Add the toggle in the root `values.yaml`
5. If the component has CRDs, place raw upstream CRDs in `upstream-crds/` and run `./scripts/update-crds.sh`

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature or component
- `fix:` bug fix
- `docs:` documentation
- `refactor:` code refactoring
- `chore:` maintenance (version bumps, CI)

## Pull Request Process

1. Ensure `helm lint .` passes
2. Ensure `helm template kubevirt-stack .` succeeds
3. Update `values.schema.json` if values changed
4. Update documentation if needed
5. Fill in the PR template
6. All commits must have DCO sign-off
7. At least one maintainer approval is required

## Reporting Issues

- Use the GitHub issue templates for bug reports and feature requests
- Check existing issues before creating a new one

## License

By contributing, you agree that your contributions will be licensed under the Apache-2.0 License.

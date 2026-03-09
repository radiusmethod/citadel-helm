# Contributing to Citadel Helm Chart

Thank you for your interest in contributing to the Citadel Helm chart.

## Getting Started

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) 3.10+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured for a cluster
- [ct](https://github.com/helm/chart-testing) (optional, for running chart tests locally)

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/radiusmethod/citadel-helm.git
   cd citadel-helm
   ```

2. Update chart dependencies:
   ```bash
   helm dependency update
   ```

3. Lint the chart:
   ```bash
   helm lint .
   ```

4. Test template rendering:
   ```bash
   helm template test-release .
   ```

## Bug Reports

Open a [GitHub issue](https://github.com/radiusmethod/citadel-helm/issues/new) with:

- Chart version and Kubernetes version
- `values.yaml` overrides used (redact secrets)
- Expected vs actual behavior
- Relevant logs or error messages

## Pull Requests

1. Fork the repository and create a feature branch from `main`
2. Make your changes
3. Ensure `helm lint .` passes
4. Test with `helm template` for common scenarios
5. Update documentation if adding/changing values
6. Submit a PR with a clear description of the change

### PR Guidelines

- Keep changes focused — one feature or fix per PR
- Follow existing patterns in templates and values
- Add comments for non-obvious template logic
- Update `CHANGELOG.md` under an `[Unreleased]` section

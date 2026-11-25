#!/usr/bin/env bash
# Run kubectl in a container with Podman.
set -euo pipefail

KUBECTL_VERSION="${KUBECTL_VERSION:-v1.31.0}"
IMAGE="registry.k8s.io/kubectl:${KUBECTL_VERSION}"
KUBECONFIG_FILE="${KUBECONFIG:-$HOME/.kube/config}"

if [[ ! -f $KUBECONFIG_FILE ]]; then
  echo "kubeconfig not found at $KUBECONFIG_FILE" >&2
  exit 1
fi

tty_flags=(-i)
[[ -t 0 && -t 1 ]] && tty_flags=(-it)

exec podman run --rm "${tty_flags[@]}" \
  --network host \
  -v "$KUBECONFIG_FILE:/kubeconfig:ro" \
  -e KUBECONFIG=/kubeconfig \
  -v "$PWD:/work" -w /work \
  "$IMAGE" "$@"
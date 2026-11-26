#!/usr/bin/env bash
set -euo pipefail

#  TTY flags for interactive mode if stdin and stdout are a terminal.
tty_flags=(); [[ -t 0 && -t 1 ]] && tty_flags=(-it)

# Run Terraform in a container with Podman. The TTY component is needed to prevent unbound variable errors on empty arrays
# with bash 3.2 and `set -u` being set.
exec podman run --rm ${tty_flags[@]+"${tty_flags[@]}"} \
    -v "$(pwd)":/workspace:Z \
    -w /workspace \
    -v /run/podman/podman.sock:/run/podman/podman.sock \
    --security-opt label=disable \
    localhost/terraform-kind "$@"

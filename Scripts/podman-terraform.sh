#!/usr/bin/env bash
tty_flags=""; [ -t 0 ] && tty_flags="-it"

exec podman run --rm "${tty_flags[@]}" \
    -v "$(pwd)":/workspace:Z \
    -w /workspace \
    -v /run/podman/podman.sock:/run/podman/podman.sock \
    --security-opt label=disable \
    localhost/terraform-kind "$@"

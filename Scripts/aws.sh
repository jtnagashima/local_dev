#!/usr/bin/env bash
# Run kubectl in a container with Podman.
set -euo pipefail

AWS_CLI_VERSION="2.42.4"
AWS_PROFILE="${AWS_PROFILE:-default}"

exec podman run --rm -i \
    --network host \
    -v "$HOME/.aws/emulator/9297:/root/.aws:ro" \
    -e AWS_SHARED_CREDENTIALS_FILE=/root/.aws/emulator_credentials \
    -e AWS_CA_BUNDLE=/root/.aws/ca.pem \
    -e AWS_PROFILE="${AWS_PROFILE:-default}" \
    -e AWS_REGION="${AWS_REGION:-us-east-1}" \
    -e AWS_ENDPOINT_URL=https://127.0.0.1:9297 \
    "amazon/aws-cli:${AWS_CLI_VERSION:-latest}" "$@"
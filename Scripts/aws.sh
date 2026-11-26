#!/usr/bin/env bash
# Run kubectl in a container with Podman.
set -euo pipefail

AWS_CLI_VERSION="2.42.4"
AWS_PROFILE="${AWS_PROFILE:-default}"

exec podman run --rm \
    -v ~/.aws:/root/.aws \
    -v $(pwd):/aws \
    -e "AWS_PROFILE=$AWS_PROFILE" \
    amazon/aws-cli:$AWS_CLI_VERSION "$@"
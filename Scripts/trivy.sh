podman run --rm \
 --security-opt label=disable \
 -v "$PWD":/workspace:ro \
  -v trivy-cache:/root/.cache/trivy \
  -w /workspace \
  docker.io/aquasec/trivy:latest "$@"

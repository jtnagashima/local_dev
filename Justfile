# Check for installed dependencies and create a list to install if they are missing
import 'tf/Justfile'

# Dependencies needed for this project
dependencies := "podman"

# checks the files in Scripts/ are symlinked from /usr/local/bin
links := "terraform=podman-terraform.sh trivy=trivy.sh kubectl=kubectl.sh kind=kind.sh kustomize=kustomize.sh aws=aws.sh"

# path to the local bin directory where symlinks will be created
local_path := "/usr/local/bin"

# podman machine name to use for running containers
machine := "podman-machine-default"

# AWS Emulator port to use for running the AWS Emulator container
aws_emulator_port := "9297"
aws_emulator_port_range := "9298-9317"

# default recipe to display help information
default:
  @just --list

# Check for installed dependencies and create a list to install if they are missing
check_and_install_dependencies:
    #!/usr/bin/env bash
    set -euo pipefail
    missing=()
    green=$'\033[32m'; reset=$'\033[0m'
    red=$'\033[31m'
    for dep in {{dependencies}}; do
      if command -v "$dep" >/dev/null 2>&1; then
        echo "{{GREEN}}✔{{NORMAL}} $dep is already installed."
      else
        echo "{{RED}}✗{{NORMAL}} $dep is not installed. Adding to install list."
        missing+=("$dep")
      fi
    done
    # Request user confirmation before installing missing dependencies
    if [[ -z ${missing[*]+x} ]]; then
      echo "{{GREEN}}✔{{NORMAL}} All dependencies are installed."
      exit 0
    fi
    read -r -p "Install ${missing[*]} with Homebrew? [y/N] " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
      brew install "${missing[@]}"
    else
      echo "Skipped install."
    fi

check_symlinks:
    #!/usr/bin/env bash
    set -euo pipefail
    failed=0
    for pair in {{links}}; do
      name=${pair%%=*}; script=${pair#*=}
      link="{{local_path}}/$name"
      target="{{justfile_directory()}}/Scripts/$script"
      if [[ -L $link && $(readlink "$link") == "$target" ]]; then
        echo "{{GREEN}}✔{{NORMAL}} $link -> $target"
      elif [[ ! -e $link && ! -L $link ]]; then
        echo "{{GREEN}}Creating{{NORMAL}} $link -> $target"
        if [[ -w "{{local_path}}" ]]; then
          ln -s "$target" "$link"
        else
          sudo ln -s "$target" "$link"
        fi
        echo "{{GREEN}}✔{{NORMAL}} $link -> $target"
      else
        echo "{{RED}}✘{{NORMAL}} $link exists but doesn't point to $target, leaving it alone"
        failed=1
      fi
    done
    exit $failed

check_podman_machine:
    #!/usr/bin/env bash
    set -euo pipefail
    if podman machine inspect {{machine}} >/dev/null 2>&1; then
      echo "{{GREEN}}✔{{NORMAL}} {{machine}} is initialized"
    else
      echo "{{YELLOW}}{{machine}} not found, initializing...{{NORMAL}}"
      podman machine init {{machine}}
    fi
    if [[ $(podman machine inspect {{machine}} --format '{{{{.State}}') != running ]]; then
      podman machine start {{machine}}
    fi

setup_aws_emulator: 
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "$HOME/.aws/emulator"
    id=$(podman ps --filter "ancestor=localhost/aws-emulator" --format "{{{{.ID}}")
    if [[ -n $id ]]; then
      echo "{{GREEN}}✔{{NORMAL}} AWS Emulator is already running with container ID: $id"
      exit 0
    fi
    echo "Starting AWS Emulator container..."
    podman run -d --rm --name aws-emulator \
      --memory=2g \
      --memory-swap=2g \
      -p 127.0.0.1:{{aws_emulator_port}}:{{aws_emulator_port}} \
      -p 127.0.0.1:{{aws_emulator_port_range}}:{{aws_emulator_port_range}} \
      -e EMULATOR_LISTENER_PORT_RANGE={{aws_emulator_port_range}} \
      -e HOME="$HOME" -v "$HOME/.aws/emulator:$HOME/.aws/emulator" \
      localhost/aws-emulator -p {{aws_emulator_port}}

teardown_aws_emulator:
    #!/usr/bin/env bash
    set -euo pipefail
    id=$(podman ps --filter "ancestor=localhost/aws-emulator" --format "{{{{.ID}}")
    if [[ -n $id ]]; then
      echo "Stopping AWS Emulator container with ID: $id"
      podman stop "$id"
    else
      echo "{{YELLOW}}No running AWS Emulator container found.{{NORMAL}}"
    fi

setup:
    @just check_and_install_dependencies
    @just check_symlinks
    @just check_podman_machine
    @just setup_aws_emulator
    cd tf && terraform init && terraform apply
    @just tf_export_kubeconfig
    @just tf_env

teardown:
    @just tf_destroy
    @just teardown_aws_emulator

######## Images ########
build_all_images: build_aws_emulator_image build_terraform_image

build_aws_emulator_image: 
    @echo "Building AWS Emulator image with Podman..."
    cd aws-emulator/images && podman build \
        -t localhost/aws-emulator \
        -f Containerfile .

build_terraform_image: 
    @echo "Building Terraform image with Podman..."
    cd tf/images && podman build \
        -t localhost/terraform-kind \
        --build-arg PODMAN_VERSION=$(podman version --format '{{{{.Server.Version}}') \
        --build-arg TARGETARCH=amd64 \
        -f Containerfile .
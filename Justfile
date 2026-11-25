# Check for installed dependencies and create a list to install if they are missing
# default recipe to display help information
import 'tf/Justfile'

# Dependencies needed for this project
dependencies := "git podman"

# checks the files in Scripts/ are symlinked from /usr/local/bin
links := "terraform=podman-terraform.sh trivy=trivy.sh kubectl=kubectl.sh kind=kind.sh kustomize=kustomize.sh"

# path to the local bin directory where symlinks will be created
local_path := "/usr/local/bin"

# podman machine name to use for running containers
machine := "podman-machine-default"

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


setup:
    @just check_and_install_dependencies
    @just check_symlinks
    @just check_podman_machine
    cd tf && terraform init && terraform apply
    @just tf_export_kubeconfig
    @just tf_env
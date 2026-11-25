# Check for installed dependencies and create a list to install if they are missing
# default recipe to display help information
import 'tf/Justfile'

dependencies := "git podman"
local_path := "/usr/local/bin"

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

# checks the files in Scripts/ are symlinked from /usr/local/bin
links := "terraform=docker-terraform.sh trivy=trivy.sh"

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
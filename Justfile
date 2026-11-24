# Check for installed dependencies and create a list to install if they are missing
# default recipe to display help information
import 'tf/Justfile'

dependencies := "git podman"

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
        echo "${green}✔${reset} $dep is already installed."
      else
        echo "${red}✗${reset} $dep is not installed. Adding to install list."
        missing+=("$dep")
      fi
    done
    # Request user confirmation before installing missing dependencies
    if [[ -z ${missing[*]+x} ]]; then
      echo "${green}✔${reset} All dependencies are installed."
      exit 0
    fi
    read -r -p "Install ${missing[*]} with Homebrew? [y/N] " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
      brew install "${missing[@]}"
    else
      echo "Skipped install."
    fi
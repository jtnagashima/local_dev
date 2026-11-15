# Check for installed dependencies and create a list to install if they are missing
check_dependencies:
    @echo "Checking for dependencies..."
    @if ! command -v git &> /dev/null; then \
        echo "git is not installed. Adding to install list."; \
        DEPENDENCIES+=("git"); \
    fi
    @if ! command -v podman &> /dev/null; then \
        echo "podman is not installed. Adding to install list."; \
        DEPENDENCIES+=("podman"); \
    fi
    @echo "Dependency check complete"

install_dependencies: check_dependencies
    if [ "${#DEPENDENCIES[@]}" -eq 0 ]; then \
        echo "All dependencies are already installed."; \
    else \
        echo "Dependencies to install: ${DEPENDENCIES[@]}"; \
    fi
    @echo "Installing dependencies..."
    for pkg in "${DEPENDENCIES[@]}"; do \
        echo "Installing $pkg..."; \
        brew install "$pkg" || { echo "Failed to install $pkg"; exit 1; }; \
    done
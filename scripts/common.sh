# scripts/common.sh
#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RKCP_RUNTIME_DIR="/opt/rkcp"
RKCP_DATA_DIR="/srv/rkcp"
RKCP_LOG_DIR="/var/log/rkcp"

PORTAINER_COMPOSE_DIR="$PROJECT_ROOT/compose/portainer"
PORTAINER_DATA_DIR="$RKCP_DATA_DIR/portainer"

info() {
    echo -e "\033[1;34m[INFO]\033[0m $*"
}

success() {
    echo -e "\033[1;32m[ OK ]\033[0m $*"
}

warn() {
    echo -e "\033[1;33m[WARN]\033[0m $*"
}

error() {
    echo -e "\033[1;31m[FAIL]\033[0m $*" >&2
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        error "Please run RKCP with sudo:"
        echo "sudo ./install.sh"
        exit 1
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

pause_screen() {
    echo
    read -rp "Press Enter to continue..." _
}

create_rkcp_directories() {
    mkdir -p \
        "$RKCP_RUNTIME_DIR" \
        "$RKCP_DATA_DIR" \
        "$RKCP_LOG_DIR" \
        "$PORTAINER_DATA_DIR"
}

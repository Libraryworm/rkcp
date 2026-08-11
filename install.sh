# install.sh
#!/usr/bin/env bash

set -Eeuo pipefail

RKCP_VERSION="0.1.0"
RKCP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$RKCP_DIR/scripts/common.sh"
source "$RKCP_DIR/scripts/docker.sh"
source "$RKCP_DIR/scripts/portainer.sh"
source "$RKCP_DIR/scripts/health.sh"
source "$RKCP_DIR/scripts/system.sh"

require_root

while true; do
    clear
    echo "=========================================="
    echo " RKCP - RK3588 Personal Cloud Platform"
    echo " Version: $RKCP_VERSION"
    echo "=========================================="
    echo
    echo " 1) Install / Update Docker"
    echo " 2) Install / Update Portainer"
    echo " 3) Health Check"
    echo " 4) System Information"
    echo " 0) Exit"
    echo

    read -rp "Select an option: " choice

    case "$choice" in
        1)
            install_docker
            pause_screen
            ;;
        2)
            install_portainer
            pause_screen
            ;;
        3)
            health_check
            pause_screen
            ;;
        4)
            system_information
            pause_screen
            ;;
        0)
            echo
            info "Bye."
            exit 0
            ;;
        *)
            warn "Invalid option."
            sleep 1
            ;;
    esac
done

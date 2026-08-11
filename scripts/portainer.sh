# scripts/portainer.sh
#!/usr/bin/env bash

set -Eeuo pipefail

install_portainer() {
    echo

    if ! command_exists docker; then
        error "Docker is not installed."
        echo "Please install Docker first from menu option 1."
        return 1
    fi

    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running."
        return 1
    fi

    if ! docker compose version >/dev/null 2>&1; then
        error "Docker Compose plugin is unavailable."
        return 1
    fi

    create_rkcp_directories

    if [[ ! -f "$PORTAINER_COMPOSE_DIR/compose.yaml" ]]; then
        error "Compose file not found:"
        echo "$PORTAINER_COMPOSE_DIR/compose.yaml"
        return 1
    fi

    info "Preparing Portainer data directory..."

    mkdir -p "$PORTAINER_DATA_DIR"

    info "Pulling latest Portainer CE LTS image..."

    docker compose \
        -f "$PORTAINER_COMPOSE_DIR/compose.yaml" \
        pull

    info "Starting Portainer..."

    docker compose \
        -f "$PORTAINER_COMPOSE_DIR/compose.yaml" \
        up -d

    sleep 3

    if docker ps \
        --filter "name=^/portainer$" \
        --filter "status=running" \
        --format '{{.Names}}' | grep -qx portainer; then

        success "Portainer is running."

        LOCAL_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"

        echo
        echo "Portainer:"
        echo "https://${LOCAL_IP:-RK3588-IP}:9443"
        echo
        warn "The first visit may show a browser certificate warning."
        warn "This is expected because Portainer initially uses its own HTTPS certificate."
    else
        error "Portainer failed to start."
        docker logs --tail 50 portainer 2>/dev/null || true
        return 1
    fi
}

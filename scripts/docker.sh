# scripts/docker.sh
#!/usr/bin/env bash

set -Eeuo pipefail

install_docker() {
    echo
    info "Checking Ubuntu environment..."

    if [[ ! -f /etc/os-release ]]; then
        error "/etc/os-release not found."
        return 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    if [[ "${ID:-}" != "ubuntu" ]]; then
        error "RKCP v0.1.0 currently supports Ubuntu only."
        echo "Detected OS: ${PRETTY_NAME:-unknown}"
        return 1
    fi

    ARCH="$(dpkg --print-architecture)"

    if [[ "$ARCH" != "arm64" && "$ARCH" != "amd64" ]]; then
        error "Unsupported architecture: $ARCH"
        return 1
    fi

    info "Detected: ${PRETTY_NAME}"
    info "Architecture: ${ARCH}"

    create_rkcp_directories

    info "Removing conflicting Docker packages if present..."

    CONFLICTING_PACKAGES=(
        docker.io
        docker-compose
        docker-compose-v2
        docker-doc
        docker-buildx
        podman-docker
        containerd
        runc
    )

    for pkg in "${CONFLICTING_PACKAGES[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            apt-get remove -y "$pkg"
        fi
    done

    info "Installing prerequisites..."

    apt-get update
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg

    info "Configuring Docker official APT repository..."

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc

    chmod a+r /etc/apt/keyrings/docker.asc

    cat >/etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt-get update

    info "Installing Docker Engine and Docker Compose..."

    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    info "Enabling Docker..."

    systemctl enable --now docker

    if ! docker info >/dev/null 2>&1; then
        error "Docker service is installed but not responding."
        return 1
    fi

    success "Docker installed successfully."

    echo
    docker --version
    docker compose version

    echo
    info "Testing Docker with hello-world..."

    if docker run --rm hello-world >/dev/null 2>&1; then
        success "Docker runtime test passed."
    else
        warn "Docker installed, but hello-world test failed."
    fi
}

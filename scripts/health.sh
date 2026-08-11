# scripts/health.sh
#!/usr/bin/env bash

set -Eeuo pipefail

check_item() {
    local name="$1"
    local result="$2"

    printf "%-24s %s\n" "$name" "$result"
}

health_check() {
    echo
    echo "=========================================="
    echo " RKCP Health Check"
    echo "=========================================="
    echo

    if command_exists docker; then
        check_item "Docker CLI" "✓ $(docker --version | sed 's/,.*//')"
    else
        check_item "Docker CLI" "✗ Not installed"
    fi

    if systemctl is-active --quiet docker 2>/dev/null; then
        check_item "Docker daemon" "✓ Running"
    else
        check_item "Docker daemon" "✗ Not running"
    fi

    if docker compose version >/dev/null 2>&1; then
        check_item "Docker Compose" "✓ $(docker compose version --short)"
    else
        check_item "Docker Compose" "✗ Not available"
    fi

    if docker ps \
        --filter "name=^/portainer$" \
        --filter "status=running" \
        --format '{{.Names}}' 2>/dev/null | grep -qx portainer; then

        check_item "Portainer" "✓ Running"
    else
        check_item "Portainer" "✗ Not running"
    fi

    if ss -lnt 2>/dev/null | awk '{print $4}' | grep -q ':9443$'; then
        check_item "Portainer :9443" "✓ Listening"
    else
        check_item "Portainer :9443" "✗ Not listening"
    fi

    ROOT_USE="$(df -h / | awk 'NR==2 {print $5}')"
    check_item "Root filesystem" "$ROOT_USE used"

    MEMORY="$(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    check_item "Memory" "$MEMORY"

    LOAD="$(awk '{print $1", "$2", "$3}' /proc/loadavg)"
    check_item "Load average" "$LOAD"

    if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
        RAW_TEMP="$(cat /sys/class/thermal/thermal_zone0/temp)"
        TEMP="$(awk "BEGIN {printf \"%.1f°C\", $RAW_TEMP/1000}")"
        check_item "CPU temperature" "$TEMP"
    else
        check_item "CPU temperature" "N/A"
    fi

    echo
}

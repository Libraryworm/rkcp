# scripts/system.sh
#!/usr/bin/env bash

set -Eeuo pipefail

system_information() {
    echo
    echo "=========================================="
    echo " RKCP System Information"
    echo "=========================================="
    echo

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo "OS           : ${PRETTY_NAME:-Unknown}"
    fi

    echo "Kernel       : $(uname -r)"
    echo "Architecture : $(uname -m)"
    echo "Hostname     : $(hostname)"

    if command_exists lscpu; then
        echo "CPU cores    : $(nproc)"
        CPU_MODEL="$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"

        if [[ -n "$CPU_MODEL" ]]; then
            echo "CPU model    : $CPU_MODEL"
        fi
    fi

    if [[ -r /proc/device-tree/model ]]; then
        BOARD_MODEL="$(tr -d '\0' </proc/device-tree/model)"
        echo "Board        : $BOARD_MODEL"
    fi

    echo "Memory       : $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Root disk    : $(df -h / | awk 'NR==2 {print $2}')"
    echo "Root used    : $(df -h / | awk 'NR==2 {print $3 " (" $5 ")"}')"

    IP_ADDRESS="$(hostname -I 2>/dev/null | awk '{print $1}')"
    echo "LAN IP       : ${IP_ADDRESS:-Unknown}"

    if command_exists docker; then
        echo "Docker       : $(docker --version | sed 's/,.*//')"
    else
        echo "Docker       : Not installed"
    fi

    if docker compose version >/dev/null 2>&1; then
        echo "Compose      : $(docker compose version --short)"
    else
        echo "Compose      : Not installed"
    fi

    if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
        RAW_TEMP="$(cat /sys/class/thermal/thermal_zone0/temp)"
        awk "BEGIN {printf \"Temperature  : %.1f°C\n\", $RAW_TEMP/1000}"
    fi

    echo
    echo "Block devices:"
    echo "------------------------------------------"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
    echo
}

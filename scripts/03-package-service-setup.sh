#!/usr/bin/env bash
# ==============================================================================
# Script Name : 03-package-service-setup.sh
# Description : Demonstrates idempotent package management (APT) and systemd
#               service administration: installs packages, verifies service status,
#               and manages daemon lifecycle (start, enable, status, reload).
# Target OS   : Linux (Ubuntu 20.04/22.04 LTS, Debian)
# Usage       : sudo ./scripts/03-package-service-setup.sh [--dry-run|--execute]
# ==============================================================================

set -euo pipefail

CLR_RESET="\033[0m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_BLUE="\033[34m"

MODE="${1:---dry-run}"

# Standard packages required on a modern DevOps Linux VM
REQUIRED_PACKAGES=(
    "curl"
    "wget"
    "git"
    "unzip"
    "htop"
    "net-tools"
    "nginx"
)

log_info() {
    echo -e "${CLR_BLUE}[INFO]${CLR_RESET} $1"
}

log_success() {
    echo -e "${CLR_GREEN}[SUCCESS]${CLR_RESET} $1"
}

echo "=================================================================="
echo "      DEVOPS PACKAGE & SYSTEMD SERVICE MANAGEMENT AUTOMATION      "
echo "=================================================================="
echo "Execution Mode: ${MODE}"
echo ""

# 1. Update APT Repositories & Install Packages
log_info "Step 1: Inspecting required DevOps packages..."
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if dpkg -s "${pkg}" >/dev/null 2>&1; then
        echo " - [INSTALLED] ${pkg} is already installed."
    else
        echo " - [MISSING]   ${pkg} needs to be installed."
        if [[ "${MODE}" == "--execute" ]]; then
            # DEBIAN_FRONTEND=noninteractive suppresses interactive dialog prompts
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -y -q
            apt-get install -y -q "${pkg}"
            log_success "Successfully installed ${pkg}."
        else
            echo "   [DRY-RUN] Would run: apt-get install -y ${pkg}"
        fi
    fi
done
echo ""

# 2. Systemd Service Lifecycle Inspection
log_info "Step 2: Inspecting systemd service management for 'nginx'..."
SERVICE_NAME="nginx"

if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet "${SERVICE_NAME}" 2>/dev/null; then
        log_success "Service '${SERVICE_NAME}' is currently ACTIVE and running."
    else
        echo "Service '${SERVICE_NAME}' is INACTIVE or not yet installed."
        if [[ "${MODE}" == "--execute" ]]; then
            systemctl enable "${SERVICE_NAME}"
            systemctl start "${SERVICE_NAME}"
            log_success "Enabled and started service '${SERVICE_NAME}'."
        else
            echo " [DRY-RUN] Would run: sudo systemctl enable --now ${SERVICE_NAME}"
        fi
    fi
else
    echo "systemctl is not running on this host (common in standard containers or WSL)."
fi
echo ""

# 3. Port Listening & Process Verification
log_info "Step 3: Checking network socket binding (Port 80 HTTP)..."
if command -v ss >/dev/null 2>&1; then
    echo "Checking open TCP listening sockets via 'ss -tulpn':"
    ss -tlpn 2>/dev/null | grep -E ":(80|443|22)" || echo "No standard HTTP/SSH sockets visible or elevated permissions needed."
elif command -v netstat >/dev/null 2>&1; then
    netstat -tulpn 2>/dev/null | grep -E ":(80|443|22)" || echo "No listening sockets found."
fi
echo ""

log_info "Package and service administration verification finished."

#!/usr/bin/env bash
# ==============================================================================
# Script Name : 05-network-connectivity-check.sh
# Description : Verifies essential Linux network connectivity: DNS resolution,
#               default gateway, local open ports, and remote service endpoints.
# Target OS   : Linux (Ubuntu 20.04/22.04 LTS, Debian, RHEL)
# Usage       : ./scripts/05-network-connectivity-check.sh
# ==============================================================================

set -euo pipefail

CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_RED="\033[31m"
CLR_BLUE="\033[34m"

# Remote test endpoints (FQDNs and public DNS resolvers)
TARGET_HOSTS=(
    "github.com"
    "archive.ubuntu.com"
    "1.1.1.1"
)

# Common internal ports to verify on localhost
LOCAL_PORTS=(
    "22"   # SSH
    "80"   # HTTP
    "443"  # HTTPS
)

log_ok() {
    echo -e " ${CLR_GREEN}[PASS]${CLR_RESET} $1"
}

log_fail() {
    echo -e " ${CLR_RED}[FAIL]${CLR_RESET} $1"
}

log_warn() {
    echo -e " ${CLR_YELLOW}[INFO]${CLR_RESET} $1"
}

echo -e "${CLR_BLUE}${CLR_BOLD}==================================================================${CLR_RESET}"
echo -e "${CLR_BLUE}${CLR_BOLD}             LINUX NETWORK CONNECTIVITY DIAGNOSTIC                ${CLR_RESET}"
echo -e "${CLR_BLUE}${CLR_BOLD}==================================================================${CLR_RESET}"
echo "Host      : $(hostname)"
echo "Timestamp : $(date -u +'%Y-%m-%dT%H:%M:%SZ') (UTC)"
echo ""

# 1. Default Network Gateway Inspection
echo -e "${CLR_BOLD}1. Default Network Route / Gateway:${CLR_RESET}"
if command -v ip >/dev/null 2>&1; then
    gateway_info=$(ip route show default 2>/dev/null || echo "No default route found")
    echo "  ${gateway_info}"
else
    echo "  'ip' tool not found."
fi
echo ""

# 2. DNS Resolution Verification
echo -e "${CLR_BOLD}2. DNS Resolution Checks:${CLR_RESET}"
TEST_DOMAIN="github.com"
if command -v getent >/dev/null 2>&1; then
    if getent ahosts "${TEST_DOMAIN}" >/dev/null 2>&1; then
        resolved_ip=$(getent ahosts "${TEST_DOMAIN}" | awk 'NR==1 {print $1}')
        log_ok "DNS resolved '${TEST_DOMAIN}' to ${resolved_ip}"
    else
        log_fail "DNS failed to resolve '${TEST_DOMAIN}'"
    fi
elif command -v nslookup >/dev/null 2>&1; then
    if nslookup "${TEST_DOMAIN}" >/dev/null 2>&1; then
        log_ok "DNS resolution succeeded for '${TEST_DOMAIN}'"
    else
        log_fail "nslookup failed for '${TEST_DOMAIN}'"
    fi
else
    log_warn "Neither 'getent' nor 'nslookup' available."
fi
echo ""

# 3. Remote Endpoint Ping / Reachability Checks
echo -e "${CLR_BOLD}3. Remote Host ICMP / Reachability Checks:${CLR_RESET}"
for host in "${TARGET_HOSTS[@]}"; do
    if command -v ping >/dev/null 2>&1; then
        # -c 1 : 1 packet
        # -W 2 : timeout of 2 seconds
        if ping -c 1 -W 2 "${host}" >/dev/null 2>&1; then
            log_ok "Host '${host}' responded to ICMP echo"
        else
            log_warn "Host '${host}' did not respond to ICMP (ICMP may be filtered by firewall)"
        fi
    elif command -v curl >/dev/null 2>&1; then
        if curl -s --head --connect-timeout 2 "https://${host}" >/dev/null 2>&1; then
            log_ok "Host '${host}' reached successfully via HTTPS"
        else
            log_warn "Host '${host}' unreachable via HTTP/HTTPS"
        fi
    fi
done
echo ""

# 4. Local TCP Listening Sockets
echo -e "${CLR_BOLD}4. Local Port Availability (22/80/443):${CLR_RESET}"
for port in "${LOCAL_PORTS[@]}"; do
    if command -v ss >/dev/null 2>&1; then
        if ss -tln | grep -q ":${port} "; then
            log_ok "Local port ${port} is open and listening"
        else
            log_warn "Local port ${port} is not listening (Service may be stopped)"
        fi
    fi
done
echo ""

echo -e "${CLR_GREEN}[INFO] Network diagnostic check completed.${CLR_RESET}"

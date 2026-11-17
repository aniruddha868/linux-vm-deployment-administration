#!/usr/bin/env bash
# ==============================================================================
# Script Name : 01-system-info.sh
# Description : Collects and displays essential Linux host metrics:
#               OS distribution, kernel version, uptime, CPU, memory, and disk.
# Target OS   : Linux (Ubuntu 20.04/22.04 LTS, Debian, RHEL)
# Usage       : ./scripts/01-system-info.sh
# ==============================================================================

# Enable strict execution mode:
# -e : Exit immediately if a command exits with a non-zero status.
# -u : Treat unset variables as an error when substituting.
# -o pipefail : The return value of a pipeline is the status of the last command to fail.
set -euo pipefail

# ANSI Color Codes for terminal readability
CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_BLUE="\033[34m"
CLR_CYAN="\033[36m"

print_header() {
    local title="$1"
    echo -e "${CLR_BLUE}${CLR_BOLD}=== ${title} ===${CLR_RESET}"
}

echo -e "${CLR_CYAN}${CLR_BOLD}==================================================================${CLR_RESET}"
echo -e "${CLR_CYAN}${CLR_BOLD}           LINUX SYSTEM ADMINISTRATION - HOST AUDIT REPORT        ${CLR_RESET}"
echo -e "${CLR_CYAN}${CLR_BOLD}==================================================================${CLR_RESET}"
echo "Generated On: $(date -u +'%Y-%m-%dT%H:%M:%SZ') (UTC)"
echo ""

# 1. Operating System & Kernel Details
print_header "1. Operating System & Kernel"
if [[ -f /etc/os-release ]]; then
    # Source /etc/os-release for standard distribution variables
    # shellcheck source=/dev/null
    source /etc/os-release
    echo "Distribution : ${PRETTY_NAME:-Linux}"
else
    echo "Distribution : $(uname -s)"
fi
echo "Kernel       : $(uname -r)"
echo "Architecture : $(uname -m)"
echo "Hostname     : $(hostname)"
echo "System Uptime: $(uptime -p 2>/dev/null || uptime)"
echo ""

# 2. CPU Information & Load Average
print_header "2. CPU & Processor Metrics"
if command -v lscpu >/dev/null 2>&1; then
    cpu_model=$(lscpu | grep "Model name:" | sed 's/Model name:[ \t]*//')
    cpu_cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    echo "CPU Model    : ${cpu_model:-Generic x86_64}"
    echo "Total Cores  : ${cpu_cores:-1}"
elif [[ -r /proc/cpuinfo ]]; then
    echo "CPU Model    : $(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')"
fi

if [[ -r /proc/loadavg ]]; then
    read -r load1 load5 load15 _ < /proc/loadavg
    echo "Load Average : 1m: ${load1}, 5m: ${load5}, 15m: ${load15}"
fi
echo ""

# 3. Memory & Swap Utilization
print_header "3. Memory & Swap Utilization"
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "Command 'free' unavailable; check /proc/meminfo directly."
fi
echo ""

# 4. Storage & Filesystem Disk Space
print_header "4. Primary Filesystems Usage"
if command -v df >/dev/null 2>&1; then
    df -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || df -h
else
    echo "Command 'df' not found."
fi
echo ""

# 5. Network Interfaces & IP Configuration
print_header "5. Network Interfaces"
if command -v ip >/dev/null 2>&1; then
    ip -br addr show 2>/dev/null || ip addr show
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a
else
    echo "No standard IP tool found."
fi
echo ""

echo -e "${CLR_GREEN}[INFO] System information collection completed successfully.${CLR_RESET}"

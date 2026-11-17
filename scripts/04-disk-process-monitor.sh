#!/usr/bin/env bash
# ==============================================================================
# Script Name : 04-disk-process-monitor.sh
# Description : Proactively monitors Linux disk space partitions and high-resource
#               processes (CPU & Memory hogs). Issues warnings if thresholds
#               exceed defined limits.
# Target OS   : Linux (Ubuntu, Debian, RHEL, CentOS)
# Usage       : ./scripts/04-disk-process-monitor.sh [--threshold <pct>]
# ==============================================================================

set -euo pipefail

CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_RED="\033[31m"
CLR_BLUE="\033[34m"

# Default disk alert percentage
DISK_ALERT_THRESHOLD=80
TOP_PROCESS_COUNT=5

# Parse optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --threshold|-t)
            DISK_ALERT_THRESHOLD="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--threshold <pct>]"
            echo "  --threshold, -t   Alert threshold percentage for disk usage (default: 80)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${CLR_BLUE}${CLR_BOLD}==================================================================${CLR_RESET}"
echo -e "${CLR_BLUE}${CLR_BOLD}       LINUX DISK UTILIZATION & PROCESS RESOURCE MONITOR          ${CLR_RESET}"
echo -e "${CLR_BLUE}${CLR_BOLD}==================================================================${CLR_RESET}"
echo "Alert Threshold : ${DISK_ALERT_THRESHOLD}%"
echo "Timestamp       : $(date -u +'%Y-%m-%dT%H:%M:%SZ') (UTC)"
echo ""

# 1. Disk Space Inspection across mounted partitions
echo -e "${CLR_BOLD}1. Partition Usage Audit:${CLR_RESET}"
echo "------------------------------------------------------------------"
printf "%-22s %-8s %-8s %-8s %-6s %-15s\n" "Filesystem" "Size" "Used" "Avail" "Use%" "Mounted on"
echo "------------------------------------------------------------------"

ALERT_TRIGGERED=false

# Read output of df excluding virtual / pseudo filesystems
while read -r fs size used avail usepct mountpoint; do
    # Extract numeric percentage value removing the '%' character
    numeric_pct="${usepct%%%}"

    if [[ "${numeric_pct}" =~ ^[0-9]+$ ]]; then
        if [[ "${numeric_pct}" -ge "${DISK_ALERT_THRESHOLD}" ]]; then
            printf "${CLR_RED}%-22s %-8s %-8s %-8s %-6s %-15s [ALERT]${CLR_RESET}\n" \
                "${fs}" "${size}" "${used}" "${avail}" "${usepct}" "${mountpoint}"
            ALERT_TRIGGERED=true
        else
            printf "%-22s %-8s %-8s %-8s %-6s %-15s\n" \
                "${fs}" "${size}" "${used}" "${avail}" "${usepct}" "${mountpoint}"
        fi
    fi
done < <(df -h -P -x tmpfs -x devtmpfs -x squashfs 2>/dev/null | awk 'NR>1 {print $1, $2, $3, $4, $5, $6}')
echo "------------------------------------------------------------------"

if [[ "${ALERT_TRIGGERED}" == true ]]; then
    echo -e "${CLR_RED}[WARNING] One or more partitions exceeded the ${DISK_ALERT_THRESHOLD}% warning threshold!${CLR_RESET}"
else
    echo -e "${CLR_GREEN}[OK] All monitored filesystems are healthy and below ${DISK_ALERT_THRESHOLD}% usage.${CLR_RESET}"
fi
echo ""

# 2. Top CPU-Consuming Processes
echo -e "${CLR_BOLD}2. Top ${TOP_PROCESS_COUNT} CPU-Consuming Processes:${CLR_RESET}"
echo "------------------------------------------------------------------"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu 2>/dev/null | head -n "$((TOP_PROCESS_COUNT + 1))" || ps aux | head -n "$((TOP_PROCESS_COUNT + 1))"
echo ""

# 3. Top Memory-Consuming Processes
echo -e "${CLR_BOLD}3. Top ${TOP_PROCESS_COUNT} Memory-Consuming Processes:${CLR_RESET}"
echo "------------------------------------------------------------------"
ps -eo pid,user,%mem,%cpu,comm --sort=-%mem 2>/dev/null | head -n "$((TOP_PROCESS_COUNT + 1))" || ps aux | head -n "$((TOP_PROCESS_COUNT + 1))"
echo ""

echo -e "${CLR_GREEN}[INFO] Disk and process monitoring audit completed successfully.${CLR_RESET}"

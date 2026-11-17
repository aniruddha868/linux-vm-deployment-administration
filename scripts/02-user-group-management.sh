#!/usr/bin/env bash
# ==============================================================================
# Script Name : 02-user-group-management.sh
# Description : Demonstrates best-practice Linux user and group administration:
#               creates groups, adds system accounts, sets standard shells,
#               and assigns sudo / group memberships with full safety checks.
# Target OS   : Linux (Ubuntu 20.04/22.04 LTS, Debian)
# Usage       : sudo ./scripts/02-user-group-management.sh [--dry-run|--execute]
# ==============================================================================

set -euo pipefail

CLR_RESET="\033[0m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_RED="\033[31m"
CLR_BLUE="\033[34m"

# Default execution mode: dry-run ensures safety for learners
MODE="${1:---dry-run}"

# Standard DevOps engineering groups to establish
DEPLOY_GROUPS=("devops" "developers" "monitors")

# Sample project service accounts: (username primary_group shell)
declare -A TARGET_USERS=(
    ["devops-intern"]="devops:/bin/bash"
    ["app-deployer"]="developers:/bin/bash"
    ["metric-collector"]="monitors:/usr/sbin/nologin"
)

log_info() {
    echo -e "${CLR_BLUE}[INFO]${CLR_RESET} $1"
}

log_success() {
    echo -e "${CLR_GREEN}[SUCCESS]${CLR_RESET} $1"
}

log_warn() {
    echo -e "${CLR_YELLOW}[WARN]${CLR_RESET} $1"
}

print_help() {
    echo "Usage: $0 [--dry-run | --execute | --help]"
    echo ""
    echo "Options:"
    echo "  --dry-run   (Default) Simulates user and group provisioning without modifying system state."
    echo "  --execute   Executes actual useradd / groupadd commands (requires sudo/root privileges)."
    echo "  --help      Displays this usage reference."
}

if [[ "${MODE}" == "--help" || "${MODE}" == "-h" ]]; then
    print_help
    exit 0
fi

echo "=================================================================="
echo "      LINUX USER & GROUP MANAGEMENT PROVISIONING AUTOMATION       "
echo "=================================================================="
echo "Execution Mode: ${MODE}"
echo ""

# 1. Group Provisioning Loop
log_info "Step 1: Checking and creating Linux groups..."
for grp in "${DEPLOY_GROUPS[@]}"; do
    if getent group "${grp}" >/dev/null 2>&1; then
        log_info "Group '${grp}' already exists."
    else
        if [[ "${MODE}" == "--execute" ]]; then
            groupadd "${grp}"
            log_success "Group '${grp}' successfully created."
        else
            echo " [DRY-RUN] Would execute: groupadd ${grp}"
        fi
    fi
done
echo ""

# 2. User Accounts Provisioning Loop
log_info "Step 2: Checking and provisioning Linux service accounts..."
for user in "${!TARGET_USERS[@]}"; do
    user_config="${TARGET_USERS[${user}]}"
    primary_group="${user_config%%:*}"
    login_shell="${user_config##*:}"

    if id -u "${user}" >/dev/null 2>&1; then
        log_warn "User '${user}' already exists on this host."
    else
        if [[ "${MODE}" == "--execute" ]]; then
            # useradd options explained:
            # -m : Create home directory (/home/<username>)
            # -g : Assign primary group
            # -s : Specify user login shell
            # -c : Add user comment/description field (GECOS)
            useradd -m -g "${primary_group}" -s "${login_shell}" -c "Managed by DevOps Automation" "${user}"
            log_success "Created user '${user}' (Group: ${primary_group}, Shell: ${login_shell})."
        else
            echo " [DRY-RUN] Would execute: useradd -m -g ${primary_group} -s ${login_shell} -c 'Managed by DevOps Automation' ${user}"
        fi
    fi
done
echo ""

# 3. Permissions and Sudoers Review
log_info "Step 3: Verification guidelines for Sudoers..."
echo "To grant restricted sudo access safely, never edit /etc/sudoers directly."
echo "Instead, drop a validated drop-in file in /etc/sudoers.d/ using visudo:"
echo "  Example command: echo '%devops ALL=(ALL) NOPASSWD: /bin/systemctl status *' | sudo EDITOR='tee' visudo -f /etc/sudoers.d/devops-ops"
echo ""

log_info "User and group administration workflow complete."

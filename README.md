# 🐧 Linux VM Deployment & Administration

> **linux-vm-deployment-administration** — Linux System Administration and Bash Automation for DevOps Portfolio

[![Linux](https://img.shields.io/badge/OS-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04_LTS-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Systemd](https://img.shields.io/badge/Init-systemd-CC0000?logo=redhat&logoColor=white)](https://systemd.io/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)

> **Repository:** [https://github.com/aniruddha868/linux-vm-deployment-administration](https://github.com/aniruddha868/linux-vm-deployment-administration)  
> **Author:** Aniruddha ([@aniruddha868](https://github.com/aniruddha868))  
> **Target Role:** Entry-Level DevOps Engineer / DevOps Intern

A comprehensive, production-oriented DevOps portfolio project demonstrating practical **Linux System Administration**, **Bash Automation**, **Service & Process Management**, and **CI/CD Script Validation**.

---

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Repository Structure](#-repository-structure)
- [Key Learning Domains](#-key-learning-domains)
- [Bash Automation Scripts](#-bash-automation-scripts)
- [Sample Configurations](#-sample-configurations)
- [Prerequisites & Setup](#-prerequisites--setup)
- [Quick Start Guide](#-quick-start-guide)
- [GitHub Actions CI Pipeline](#-github-actions-ci-pipeline)
- [Troubleshooting Common Linux Issues](#-troubleshooting-common-linux-issues)
- [Documentation & References](#-documentation--references)

---

## 🎯 Project Overview

Every Cloud, Container, and DevOps platform (AWS EC2, Azure VMs, Kubernetes Nodes, Docker containers) relies fundamentally on Linux. This project provides a structured learning and administration reference covering:

1. **Host & Telemetry Audit**: Querying kernel, CPU, RAM, and storage architecture.
2. **User & Identity Security**: Creating least-privilege groups, service accounts, and sudo delegations.
3. **Package & Service Orchestration**: Idempotent APT package installation and systemd daemon management.
4. **Capacity & Resource Monitoring**: Proactive disk space alerting and top-process resource tracking.
5. **Networking Diagnostics**: Verifying default gateways, DNS resolution, and TCP listening sockets.
6. **Automated CI Quality Gate**: Automated bash syntax validation using `bash -n` on every commit.

---

## 📂 Repository Structure

```text
linux-vm-deployment-administration/
│
├── .github/
│   └── workflows/
│       └── shell-validation.yml         # GitHub Actions CI workflow (bash -n validation)
│
├── docs/
│   ├── architecture.md                  # System architecture, Mermaid diagrams & IAM design
│   └── linux-commands.md                # Comprehensive handbook of essential Linux commands
│
├── sample-configs/
│   ├── sample-systemd.service           # Production systemd unit file with security hardening
│   ├── sshd_config_example              # Hardened SSH daemon configuration (key-only auth)
│   └── sudoers_example                  # Granular, least-privilege sudoers drop-in configuration
│
├── scripts/
│   ├── 01-system-info.sh                # Host telemetry, OS, kernel, CPU, RAM & disk inspection
│   ├── 02-user-group-management.sh      # Idempotent user & group provisioning with dry-run support
│   ├── 03-package-service-setup.sh      # APT package management & systemd service orchestration
│   ├── 04-disk-process-monitor.sh       # Threshold-based disk capacity & top process resource monitor
│   └── 05-network-connectivity-check.sh # Default gateway, DNS resolution & TCP port diagnostic
│
├── .gitignore                           # Excludes logs, runtime reports, and credentials
└── README.md                            # Comprehensive project guide & documentation
```

---

## 🧠 Key Learning Domains

| Domain | Concepts Covered | Scripts / Configs |
| :--- | :--- | :--- |
| **Directory & Filesystem** | FHS standards (`/etc`, `/var`, `/opt`, `/proc`), inode usage, file search | `01-system-info.sh`, `docs/linux-commands.md` |
| **Users & Permissions** | `useradd`, `groupadd`, octal permissions (`chmod 755`), ownership (`chown`) | `02-user-group-management.sh`, `sample-configs/sudoers_example` |
| **Package Management** | APT updates, non-interactive installations, repository querying | `03-package-service-setup.sh` |
| **Service Lifecycle** | `systemctl` (start, stop, enable, restart), sandboxed unit files | `sample-configs/sample-systemd.service` |
| **System Monitoring** | CPU load averages, memory consumption ratios, disk usage (`df`, `ps`) | `04-disk-process-monitor.sh` |
| **Networking & DNS** | IP addressing, default routes, DNS queries (`getent`, `nslookup`), listening sockets (`ss`) | `05-network-connectivity-check.sh` |
| **Security Hardening** | Disabling SSH root login, enforcing key authentication, visudo rules | `sample-configs/sshd_config_example` |

---

## 📜 Bash Automation Scripts

All scripts are written adhering to DevOps best practices:
- Shebang: `#!/usr/bin/env bash`
- Strict execution mode: `set -euo pipefail`
- Non-destructive `--dry-run` or `--help` support
- Colorized terminal output for easy readability

### 1. `01-system-info.sh`
Collects and displays OS release, kernel version, hostname, CPU cores, load averages, memory metrics, and mounted filesystems.

### 2. `02-user-group-management.sh`
Idempotently establishes DevOps groups (`devops`, `developers`, `monitors`) and service accounts with designated shells (`/bin/bash` or `/usr/sbin/nologin`). Default `--dry-run` allows safe previewing.

### 3. `03-package-service-setup.sh`
Automates installation of standard DevOps utilities (`curl`, `git`, `htop`, `nginx`) and audits service status.

### 4. `04-disk-process-monitor.sh`
Scans mounted partitions against a configurable warning threshold (default: 80%) and prints top 5 CPU and Memory consuming processes.

### 5. `05-network-connectivity-check.sh`
Verifies network connectivity: retrieves the default route, validates DNS resolution against public FQDNs (`github.com`), tests reachability, and audits local listening ports (22, 80, 443).

---

## ⚙️ Prerequisites & Setup

### Requirements
- Any Linux host (Ubuntu 20.04/22.04 LTS recommended), WSL on Windows, or macOS terminal.
- Bash shell v4.0 or higher.
- Git installed.

### Setup Instructions
```bash
# 1. Clone the repository
git clone https://github.com/aniruddha868/linux-vm-deployment-administration.git
cd linux-vm-deployment-administration

# 2. Grant execute permissions to automation scripts
chmod +x scripts/*.sh
```

---

## 🚀 Quick Start Guide

Run scripts directly from your terminal:

```bash
# Run system diagnostics
./scripts/01-system-info.sh

# Preview user & group provisioning safely (dry-run mode)
./scripts/02-user-group-management.sh --dry-run

# Inspect package requirements & service status
./scripts/03-package-service-setup.sh --dry-run

# Check disk space with custom 85% threshold
./scripts/04-disk-process-monitor.sh --threshold 85

# Test network routing and DNS resolution
./scripts/05-network-connectivity-check.sh
```

---

## 🔄 GitHub Actions CI Pipeline

The project includes an automated Continuous Integration pipeline in [shell-validation.yml](.github/workflows/shell-validation.yml) that automatically runs on every push and pull request:
1. **Static Syntax Checking**: Runs `bash -n` on all `.sh` scripts to verify syntax without executing commands.
2. **Non-Destructive Test Execution**: Runs each script with dry-run flags on an `ubuntu-latest` runner to guarantee runtime safety.

---

## 🛠️ Troubleshooting Common Linux Issues

### 1. "Permission denied" on script execution
- **Cause**: The execute (`+x`) bit is missing.
- **Fix**: Run `chmod +x scripts/<script-name>.sh`.

### 2. "syntax error near unexpected token"
- **Cause**: Windows CRLF line endings instead of Linux LF line endings.
- **Fix**: Convert line endings using `dos2unix scripts/*.sh` or configure git with `git config core.autocrlf input`.

### 3. High CPU Load Average but low CPU usage %
- **Cause**: Processes may be blocked waiting on disk I/O (uninterruptible sleep state `D`).
- **Diagnosis**: Run `vmstat 1` and check the `b` (blocked) and `wa` (iowait) columns.

### 4. Service fails to start (`Job for nginx.service failed`)
- **Diagnosis**: Check the system journal for exact error reasons:
  ```bash
  sudo systemctl status nginx
  sudo journalctl -xeu nginx --no-pager
  ```

---

## 📚 Documentation & References

- [System Architecture & IAM Design](docs/architecture.md)
- [Essential Linux Commands Reference](docs/linux-commands.md)
- [Hardened SSH Configuration](sample-configs/sshd_config_example)
- [Custom Systemd Service](sample-configs/sample-systemd.service)
- [Least-Privilege Sudoers](sample-configs/sudoers_example)

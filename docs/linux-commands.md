# 🐧 Linux Command Reference & Administration Guide

This reference handbook documents the essential Linux commands and system concepts every entry-level DevOps engineer must know. All commands are validated on **Ubuntu 20.04 / 22.04 LTS**.

---

## 1. Directory Structure Navigation & Inspection

The Linux Filesystem Hierarchy Standard (FHS) structures all data from the single root `/`.

| Directory | Purpose | DevOps Relevance |
| :--- | :--- | :--- |
| `/etc` | Host-specific system configuration files | Editing `sshd_config`, `sudoers`, nginx configs |
| `/var/log` | System and service log files | Troubleshooting app crashes, auditing access |
| `/opt` | Optional or third-party add-on software | Housing custom scripts, CI agents, deployment artifacts |
| `/home` | User home directories | Storing user SSH authorized keys (`~/.ssh/authorized_keys`)|
| `/proc` | Virtual filesystem exposing kernel & process metrics | Checking `/proc/cpuinfo`, `/proc/meminfo`, `/proc/loadavg` |
| `/bin` / `/usr/bin` | Standard user command binaries | Location of `curl`, `git`, `bash`, `python3` |

### Core Navigation Commands
```bash
# Print current working directory
pwd

# List files with long listing, hidden files, and human-readable sizes
ls -lah

# Search for files by name from the root directory
sudo find / -name "*.conf" 2>/dev/null

# Tree-view directory structure (depth 2)
tree -L 2
```

---

## 2. File Operations & Search

```bash
# View file content with line numbers
cat -n /etc/os-release

# Paginate large text files (space to advance, q to exit)
less /var/log/syslog

# View last 50 lines of an application log and follow updates in real-time
sudo tail -f -n 50 /var/log/nginx/access.log

# Search for patterns in files ignoring case
grep -rnI "error" /var/log/

# Count lines, words, and characters
wc -l /etc/passwd

# Compare differences between two config files
diff -u /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

---

## 3. Users, Groups & Permission Management

Linux implements POSIX file permissions: **Read (4)**, **Write (2)**, **Execute (1)** across **User (Owner)**, **Group**, and **Others**.

### Permission Representation
```text
-  r w x  r - x  r - -
^  \___/  \___/  \___/
|    |      |      |
|    |      |      +---> Others (4: Read)
|    |      +----------> Group  (5: Read + Execute)
|    +-----------------> Owner  (7: Read + Write + Execute)
+----------------------> File type (- regular, d directory, l symlink)
```

### User & Group Administration Commands
```bash
# Create a new system group
sudo groupadd devops

# Create a new user with home directory, primary group, and bash shell
sudo useradd -m -g devops -s /bin/bash -c "DevOps Deployer" app-deployer

# Add an existing user to a secondary group (e.g. docker or sudo)
sudo usermod -aG sudo app-deployer

# Change file ownership (user:group)
sudo chown -R app-deployer:devops /opt/app

# Set permissions using octal notation (755: rwxr-xr-x)
chmod 755 scripts/*.sh

# Set restrictive permissions on private keys (600: rw-------)
chmod 600 ~/.ssh/id_rsa

# Validate sudoers file before saving
sudo visudo -cf /etc/sudoers.d/devops-engineers
```

---

## 4. Package Management (APT on Ubuntu/Debian)

```bash
# Resynchronize package index files from remote repositories
sudo apt-get update -y

# Upgrade all currently installed packages to latest versions
sudo apt-get upgrade -y

# Search for a package in the official repository
apt-cache search nginx

# Install packages non-interactively
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget git htop nginx

# Inspect installed package details and version
dpkg -s nginx

# Remove package and purge configuration files
sudo apt-get purge -y nginx
sudo apt-get autoremove -y
```

---

## 5. Systemd Service Lifecycle & Daemon Management

`systemd` is the standard init system and service manager on modern Linux.

```bash
# Check status of a service
sudo systemctl status nginx

# Start, stop, and restart a service
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# Reload service configuration without stopping active connections
sudo systemctl reload nginx

# Enable service to start automatically on system boot
sudo systemctl enable nginx

# Inspect system logs for a specific service unit
sudo journalctl -u nginx -n 100 --no-pager

# View real-time logs for a unit
sudo journalctl -u nginx -f
```

---

## 6. Process Monitoring & System Performance

```bash
# Interactive real-time process viewer
top
# or interactive colorized viewer (if installed)
htop

# Snapshot of currently running processes with CPU and memory sort
ps aux --sort=-%cpu | head -n 10
ps aux --sort=-%mem | head -n 10

# Find Process ID (PID) by process name
pgrep -l nginx

# Gracefully terminate a process (SIGTERM = 15)
kill -15 <PID>

# Forcefully kill a hung process (SIGKILL = 9)
kill -9 <PID>

# View system uptime and load average
uptime

# View free and used memory in megabytes/gigabytes
free -m
free -h
```

---

## 7. Storage, Filesystems & Disk Inspection

```bash
# Human-readable disk space usage across all mounted filesystems
df -h -x tmpfs -x devtmpfs

# Show disk space used by a specific directory and subdirectories
du -sh /var/log/*

# Find the 10 largest directories on the root filesystem
sudo du -xh / 2>/dev/null | sort -rh | head -n 10

# List block storage devices and partitions
lsblk -f
```

---

## 8. Networking Diagnostics & Port Verification

```bash
# Display IP addresses assigned to network interfaces
ip -br addr show

# Display the default routing gateway
ip route show default

# Display active TCP and UDP listening ports with associated process IDs
sudo ss -tulpn

# Verify DNS resolution for a domain
getent hosts github.com
# or
nslookup github.com

# Test network endpoint reachability (send 3 packets)
ping -c 3 8.8.8.8

# Test HTTP/HTTPS reachability and response headers
curl -I https://github.com
```

---

## 9. Bash Scripting Best Practices for DevOps

1. **Always use a modern Shebang**: `#!/usr/bin/env bash`
2. **Enable strict execution mode**:
   ```bash
   set -euo pipefail
   ```
   - `-e`: Exit immediately on command failure.
   - `-u`: Treat unset variables as errors.
   - `-o pipefail`: Detect failures in piped commands.
3. **Always quote variables**: `"${variable}"` prevents unexpected word splitting or glob expansion.
4. **Use functions for modularity**: Break complex scripts into testable single-responsibility functions.
5. **Implement Dry-Run capabilities**: Allow operators to preview changes before modifying system state.

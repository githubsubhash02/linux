#!/bin/bash

# ----------------------------------------
# Linux Hardening Rollback Script
# Reverts settings made by Ansible hardening roles
# Author: Subhash Chandra :)
# ----------------------------------------

LOG_FILE="../logs/rollback_$(date +%Y%m%d_%H%M%S).log"
echo "[*] Rollback started at $(date)" | tee -a "$LOG_FILE"

# Restore sysctl settings
echo "[*] Reverting sysctl kernel parameters..." | tee -a "$LOG_FILE"
sysctl -w kernel.randomize_va_space=1
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w kernel.sysrq=1
sysctl -w fs.suid_dumpable=1

# Remove custom sysctl config if any(like in my case is /etc/sysctl.d/99-kernel-hardening.conf)
if [ -f /etc/sysctl.d/99-kernel-hardening.conf ]; then
    echo "[*] Removing custom sysctl config..." | tee -a "$LOG_FILE"
    rm -f /etc/sysctl.d/99-kernel-hardening.conf
    sysctl --system
fi

# Revert file permissions
echo "[*] Restoring sensitive file permissions..." | tee -a "$LOG_FILE"
chmod 0666 /etc/passwd 2>/dev/null
chmod 0666 /etc/group 2>/dev/null
chmod 0644 /etc/shadow 2>/dev/null
chmod 0644 /etc/gshadow 2>/dev/null

# Re-enable disabled services
echo "[*] Re-enabling disabled services..." | tee -a "$LOG_FILE"
for svc in cups rpcbind avahi-daemon ; do
    systemctl unmask $svc 2>/dev/null
    systemctl enable $svc 2>/dev/null
    systemctl start $svc 2>/dev/null
    echo "    -> $svc enabled and started" | tee -a "$LOG_FILE"
done

# Optional: Restore default logrotate
echo "[*] Restoring default logrotate config..." | tee -a "$LOG_FILE"
cp /usr/share/logrotate/default /etc/logrotate.conf 2>/dev/null || echo "    -> Skipped: default logrotate not found" | tee -a "$LOG_FILE"

# Logging complete
echo "[*] Rollback completed at $(date)" | tee -a "$LOG_FILE"


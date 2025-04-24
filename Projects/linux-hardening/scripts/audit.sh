#!/bin/bash


REPORT="../logs/audit_report.txt"
mkdir -p logs

echo "Linux Security Audit Report - $(date)" > $REPORT

# 1. Check for world-writable files
echo -e "\n[+] World-writable files:" >> $REPORT
find / -xdev -type f -perm -0002 -ls 2>/dev/null >> $REPORT

# 2. Check for SUID/SGID files
echo -e "\n[+] SUID/SGID files:" >> $REPORT
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null >> $REPORT

# 3. Password policy
echo -e "\n[+] Password policy (PASS_MAX_DAYS, PASS_MIN_DAYS, etc.):" >> $REPORT
grep ^PASS_ /etc/login.defs >> $REPORT

# 4. SSH root login and settings
echo -e "\n[+] SSH configuration:" >> $REPORT
grep -Ei "^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config >> $REPORT

# 5. Running services
echo -e "\n[+] Running services:" >> $REPORT
systemctl list-units --type=service --state=running >> $REPORT

# 6. Firewall status
echo -e "\n[+] Firewall status:" >> $REPORT
if command -v ufw &>/dev/null; then
    ufw status verbose >> $REPORT
elif command -v firewall-cmd &>/dev/null; then
    firewall-cmd --list-all >> $REPORT
else
    echo "Firewall not found." >> $REPORT
fi

echo -e "\nAudit complete. Report saved to $REPORT"
exit 0


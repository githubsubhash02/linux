#!/bin/bash

# Email Configuration
EMAIL="dep_team@xyz.com"
SUBJECT_SUCCESS="APP and DB Backup Completed Successfully - $(date +'%d-%m-%Y')"
SUBJECT_FAILURE="APP and DB Backup Failed - $(date +'%d-%m-%Y')"
LOG_FILE="/var/log/backup.log"

# Delete old backup
rm -rf /root/app_and_db_backup/*
mkdir -p /root/app_and_db_backup

# Backup MySQL Databases
DATABASES=("ERPProd" "functional_db" "report_db")
for DB in "${DATABASES[@]}"; do
    mysqldump "$DB" > "/root/app_and_db_backup/${DB}_$(date +%d%m%Y).sql" 2>>"$LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "Database backup failed for $DB" >> "$LOG_FILE"
        echo "Backup FAILED for $DB. Check logs." | mailx -s "$SUBJECT_FAILURE" "$EMAIL"
        exit 1
    fi
done


# Backup Important Folders
declare -A FILES
FILES["datadisk_tomcat_backup"]="/datadisk/tomcat"
FILES["var_www_backup"]="/var/www"
FILES["httpd_conf"]="/etc/httpd/conf"
FILES["app_and_db_backup.sh_backup"]="/root/app_and_db_backup.sh"

for FILE in "${!FILES[@]}"; do
    tar -czf "/root/app_and_db_backup/${FILE}_$(date +%d_%m_%Y).tar.gz" "${FILES[$FILE]}" 2>>"$LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "Compression failed for ${FILES[$FILE]}" >> "$LOG_FILE"
        echo "Backup FAILED for ${FILES[$FILE]}. Check logs." | mailx -s "$SUBJECT_FAILURE" "$EMAIL"
        exit 1
    fi
done

# Create Tar File of All Backups
TAR_FILENAME="/root/app_and_db_backup_$(date +%d_%m_%Y).tar.gz"
tar -czf "$TAR_FILENAME" /root/app_and_db_backup 2>>"$LOG_FILE"

if [ $? -ne 0 ]; then
    echo "Final backup archive creation failed." >> "$LOG_FILE"
    echo "Final backup archive creation FAILED. Check logs." | mailx -s "$SUBJECT_FAILURE" "$EMAIL"
    exit 1
fi

# Upload Backup to FTP
FTP_SERVER="ftp://dep-user:Password%402025@192.168.10.10/DEV%20Backup/ERP/"
curl --upload-file "$TAR_FILENAME" "$FTP_SERVER" 2>>"$LOG_FILE"

if [ $? -ne 0 ]; then
    echo "FTP upload failed." >> "$LOG_FILE"
    echo "Backup upload to FTP FAILED. Check logs." | mailx -s "$SUBJECT_FAILURE" "$EMAIL"
    exit 1
fi

# Cleanup
rm -rf "$TAR_FILENAME"

# Send Success Email
echo "Backup completed successfully on $(date)" | mailx -s "$SUBJECT_SUCCESS" "$EMAIL"
 

#!/bin/bash

# Define the source directory and the S3 bucket
SOURCE_DIR="/opt/app-data/DOCUMENTS"
S3_BUCKET="s3://your-app-bucket/"

# Email Configuration
TO_EMAIL="dev_team@xyx.com"   # Change this to the recipient's email
FROM_EMAIL="deployment@xyz.com"  # Change this to your email
SUBJECT_SUCCESS="App's AWS S3 Sync Completed Successfully for docs folder"
SUBJECT_FAIL="App's AWS S3 Sync failed for docs folder"
LOG_FILE="/var/log/s3_sync.log"

# Function to send email notification
send_email() {
    local subject="$1"
    local message="$2"
    echo -e "$message" | mailx -s "$subject" -S sendmail="/usr/bin/msmtp" "$TO_EMAIL"
}

# Start Logging
echo "Sync started at $(date)" > "$LOG_FILE"

# Sync the directory to S3 using the AWS CLI
aws s3 sync "$SOURCE_DIR" "$S3_BUCKET" >> "$LOG_FILE" 2>&1

# Check if the sync was successful
if [[ $? -eq 0 ]]; then
    echo "Sync completed at $(date)" >> "$LOG_FILE"
    send_email "$SUBJECT_SUCCESS" "S3 sync completed successfully.\nCheck logs at $LOG_FILE."
else
    echo "Sync failed at $(date)" >> "$LOG_FILE"
    send_email "$SUBJECT_FAIL" "S3 sync failed. Check logs at $LOG_FILE for details."
    exit 1
fi

echo "----------------------------------------" >> "$LOG_FILE"



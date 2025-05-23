# 📂 AWS S3 Sync Script with Email Notifications

This script automates the synchronization of a local directory to an AWS S3 bucket and sends email notifications upon success or failure.

---

## 🛠️ Script Overview

**File Name:** `s3_sync.sh`  
**Purpose:**  
- Syncs contents of `/opt/app-data/DOCUMENTS` to an AWS S3 bucket  
- Logs the process to `/var/log/s3_sync.log`  
- Sends an email notification to the development team on success or failure  

---

## 📦 Requirements

Ensure the following dependencies are installed and configured:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- `mailx` (with `msmtp` configured for sending mail)
- Valid AWS credentials (`~/.aws/credentials` or environment variables)

---

## 🔧 Configurationn

Update the following variables in the script:

```bash
SOURCE_DIR="/opt/app-data/DOCUMENTS"       # Local folder to sync
S3_BUCKET="s3://your-app-bucket/"          # Target S3 bucket

TO_EMAIL="dev_team@xyx.com"                # Email recipient
FROM_EMAIL="deployment@xyz.com"            # Sender email (used by msmtp)
LOG_FILE="/var/log/s3_sync.log"            # Log file location

#add in cronjob
59 23 * * * /root/s3_synch.sh


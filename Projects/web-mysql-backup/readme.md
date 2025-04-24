# Web & MySQL Backup Tool

A robust Bash script to automate the backup of critical web server configurations, application folders, and MySQL databases — with logging, compression, email alerts, and FTP upload support.

---

## 🚀 Features

- Backs up multiple MySQL databases
- Archives important directories (e.g., `/var/www`, `/etc/httpd/conf`)
- Sends email notifications on success or failure
- Compresses all backups into a single tarball
- Uploads the final archive to an FTP server
- Maintains detailed logs for traceability

---

## 🛠️ Prerequisites

- Bash shell (`/bin/bash`)
- `mysqldump` installed and available in `$PATH`
- `mailx` for email notifications
- `curl` for FTP upload
- Permissions to access the backup directories and send emails

---

## 📁 Backup Targets

### 🔹 MySQL Databases
- `ERPProd`
- `functional_db`
- `report_db`


### 🔹 Config & Application Files
- `/datadisk/tomcat`
- `/var/www`
- `/etc/httpd/conf`
- `/root/app_and_db_backup.sh` (the script itself)

---

## 📦 Backup Outputt

All files are stored in `/root/app_and_db_backup`



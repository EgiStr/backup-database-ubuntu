#!/bin/bash

# Load environment variables
source .env

# Variables
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backup"
BACKUP_FILENAME="supabase_backup_${TIMESTAMP}.sql"
COMPRESSED_FILENAME="${BACKUP_FILENAME}.gz"
ENCRYPTED_FILENAME="${COMPRESSED_FILENAME}.enc"
GDRIVE_REMOTE="gdrive"
GDRIVE_FOLDER="supabase_backups"
LOG_FILE="./path/backup/backup.log"

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform database dump
log "Starting database backup"
if PGPASSWORD="$DB_PASSWORD" pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_DIR/$BACKUP_FILENAME"; then
    log "Database backup successful"
else
    log "Error: Database backup failed"
    exit 1
fi

# Compress the backup
log "Compressing backup"
gzip -9 "$BACKUP_DIR/$BACKUP_FILENAME"

# Encrypt the compressed backup
log "Encrypting backup"
openssl enc -aes-256-cbc -salt -in "$BACKUP_DIR/$COMPRESSED_FILENAME" -out "$BACKUP_DIR/$ENCRYPTED_FILENAME" -k "$ENCRYPTION_KEY"

# Upload to Google Drive
log "Uploading to Google Drive"
if rclone copy "$BACKUP_DIR/$ENCRYPTED_FILENAME" "$GDRIVE_REMOTE:$GDRIVE_FOLDER/"; then
    log "Upload to Google Drive successful"
else
    log "Error: Google Drive upload failed"
    exit 1
fi

# Clean up local files
log "Cleaning up local files"
rm "$BACKUP_DIR/$COMPRESSED_FILENAME" "$BACKUP_DIR/$ENCRYPTED_FILENAME"

# Implement retention policy (e.g., keep last 7 days of backups)
log "Applying retention policy"
rclone delete "$GDRIVE_REMOTE:$GDRIVE_FOLDER" --min-age 7d --include "supabase_backup_*.enc"

# Verify backup integrity
log "Verifying backup integrity"
LATEST_BACKUP=$(rclone lsl "$GDRIVE_REMOTE:$GDRIVE_FOLDER" | sort -k2 | tail -n1 | awk '{print $NF}')
if rclone copy "$GDRIVE_REMOTE:$GDRIVE_FOLDER/$LATEST_BACKUP" "$BACKUP_DIR/" && 
   openssl enc -d -aes-256-cbc -in "$BACKUP_DIR/$LATEST_BACKUP" -out "$BACKUP_DIR/${LATEST_BACKUP%.enc}" -k "$ENCRYPTION_KEY" &&
   gzip -t "$BACKUP_DIR/${LATEST_BACKUP%.enc}"; then
    log "Backup integrity verified"
else
    log "Error: Backup integrity check failed"
fi

rm -f "$BACKUP_DIR/$LATEST_BACKUP" "$BACKUP_DIR/${LATEST_BACKUP%.enc}"

log "Backup process completed"

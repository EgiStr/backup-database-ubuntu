#!/bin/bash

# Load environment variables
source .env

# Variables
BACKUP_DIR="./backup"
GDRIVE_REMOTE="gdrive"
GDRIVE_FOLDER="supabase_backups"
LOG_FILE="./backup/restore.log"

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Check if backup file is provided
if [ $# -eq 0 ]; then
    log "Error: No backup file specified"
    echo "Usage: $0 <backup_file_name>"
    exit 1
fi

BACKUP_FILE="$1"
ENCRYPTED_FILENAME="$BACKUP_FILE"
COMPRESSED_FILENAME="${ENCRYPTED_FILENAME%.enc}"
BACKUP_FILENAME="${COMPRESSED_FILENAME%.gz}"

# Download the backup from Google Drive
log "Downloading backup from Google Drive"
if rclone copy "$GDRIVE_REMOTE:$GDRIVE_FOLDER/$ENCRYPTED_FILENAME" "$BACKUP_DIR/"; then
    log "Download from Google Drive successful"
else
    log "Error: Failed to download backup from Google Drive"
    exit 1
fi

# Decrypt the backup
log "Decrypting backup"
if openssl enc -d -aes-256-cbc -in "$BACKUP_DIR/$ENCRYPTED_FILENAME" -out "$BACKUP_DIR/$COMPRESSED_FILENAME" -k "$ENCRYPTION_KEY"; then
    log "Decryption successful"
else
    log "Error: Failed to decrypt backup"
    exit 1
fi

# Decompress the backup
log "Decompressing backup"
gzip -d "$BACKUP_DIR/$COMPRESSED_FILENAME"

# Restore the database
log "Restoring database"
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$BACKUP_DIR/$BACKUP_FILENAME"; then
    log "Database restoration successful"
else
    log "Error: Database restoration failed"
    exit 1
fi

# Clean up local files
log "Cleaning up local files"
rm "$BACKUP_DIR/$ENCRYPTED_FILENAME" "$BACKUP_DIR/$BACKUP_FILENAME"

log "Restore completed successfully"

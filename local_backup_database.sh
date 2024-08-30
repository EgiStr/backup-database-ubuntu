#!/bin/bash

# Load environment variables
source .env

# Variables
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="${LOCAL_BACKUP_DIR}"
BACKUP_FILENAME="supabase_backup_${TIMESTAMP}.sql"
COMPRESSED_FILENAME="${BACKUP_FILENAME}.gz"
LOG_FILE="${BACKUP_DIR}/backup.log"

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

# Implement retention policy (e.g., keep last 7 days of backups)
log "Applying retention policy"
find "$BACKUP_DIR" -name "supabase_backup_*.gz" -type f -mtime +7 -delete

log "Backup process completed"

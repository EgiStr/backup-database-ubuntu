#!/bin/bash

# Load environment variables
source .env

# Variables
BACKUP_DIR="${LOCAL_BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR}/restore.log"

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Check if a backup file is provided
if [ $# -eq 0 ]; then
    log "Error: No backup file specified"
    echo "Usage: $0 <backup_file.sql.gz>"
    exit 1
fi

BACKUP_FILE="$1"

# Check if the backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    log "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Decompress the backup file
log "Decompressing backup file"
gunzip -c "$BACKUP_FILE" > "${BACKUP_FILE%.gz}"

# Perform database restore
log "Starting database restore"
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "${BACKUP_FILE%.gz}"; then
    log "Database restore successful"
else
    log "Error: Database restore failed"
    exit 1
fi

# Clean up
rm "${BACKUP_FILE%.gz}"
log "Restore process completed"1~#!/bin/bash

# Load environment variables
source .env

# Variables
BACKUP_DIR="${LOCAL_BACKUP_DIR}"
LOG_FILE="${BACKUP_DIR}/restore.log"

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Check if a backup file is provided
if [ $# -eq 0 ]; then
    log "Error: No backup file specified"
    echo "Usage: $0 <backup_file.sql.gz>"
    exit 1
fi

BACKUP_FILE="$1"

# Check if the backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    log "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Decompress the backup file
log "Decompressing backup file"
gunzip -c "$BACKUP_FILE" > "${BACKUP_FILE%.gz}"

# Perform database restore
log "Starting database restore"
if PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "${BACKUP_FILE%.gz}"; then
    log "Database restore successful"
else
    log "Error: Database restore failed"
    exit 1
fi

# Clean up
rm "${BACKUP_FILE%.gz}"
log "Restore process completed"

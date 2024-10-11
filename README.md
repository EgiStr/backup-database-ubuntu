# Supabase Local Backup Solution

This repository contains a script for backing up Supabase databases to a local directory.

## Requirements

- PostgreSQL client

## Setup

1. Install required tools:
   ```bash
   sudo apt update
   sudo apt install -y postgresql-client
```
2. Set up the .env file:
Copy the .env.example file to .env and fill in your Supabase details:

```bash
cp .env.example .env
nano .env
```

3. Make the script executable:
```bash
chmod +x backup_supabase.sh
chmod +x local_restore_database.sh

```
4. Set up a cron job to run the backup script regularly:
```bash
crontab -e
# Add the following line to run the backup daily at 2 AM
0 2 * * * /path/to/backup_supabase.sh
0 2 * * * /path/to/local_restore_database.sh
```

Usage
To run a backup manually:
```bash
./backup_supabase.sh
# or
./local_restore_database.sh
```

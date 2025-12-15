#!/bin/bash
set -e

# Config - adjust these if needed
PGHOST="${PGHOST:-db}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-odoo}"
PGPASSWORD="${PGPASSWORD:-odoo}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
FILESTORE_VOLUME="${FILESTORE_VOLUME:-/var/lib/odoo/filestore}"

export PGPASSWORD=$PGPASSWORD

mkdir -p "$BACKUP_DIR"

# Hardcoded list of databases to backup
DATABASES=("autofit-11" "odoo_docker_test")  # <-- Replace with your DB names

for DB in "${DATABASES[@]}"; do
    echo "Backing up database $DB..."

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/${DB}_${TIMESTAMP}.zip"

    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    # Dump DB to SQL file
    pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$DB" -F p -f "$TMPDIR/dump.sql"

    # Create minimal manifest.json
    cat > "$TMPDIR/manifest.json" <<EOF
{
  "odoo_dump": "1",
  "db_name": "$DB",
  "version": "16.0",
  "major_version": "16.0",
  "pg_version": "$(psql -h $PGHOST -p $PGPORT -U $PGUSER -d $DB -c 'SHOW server_version;' -t | xargs)",
  "modules": {}
}
EOF

    # Copy filestore folder if exists
    if [ -d "${FILESTORE_VOLUME}/${DB}" ]; then
      cp -r "${FILESTORE_VOLUME}/${DB}" "$TMPDIR/filestore"
    else
      echo "Warning: filestore for DB '$DB' not found at ${FILESTORE_VOLUME}/${DB}. Backing up DB only."
    fi

    # Create zip archive with dump.sql, manifest.json, filestore/
    (cd "$TMPDIR" && zip -r "$BACKUP_PATH" dump.sql manifest.json filestore)

    echo "Backup saved to $BACKUP_PATH"

    # Clean tmp folder (trap will also remove)
    rm -rf "$TMPDIR"
done

echo "All backups completed."

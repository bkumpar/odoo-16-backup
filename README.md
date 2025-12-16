# Odoo 16 Backup Docker

This repository contains a Dockerized backup solution for Odoo 16 databases and filestore.

## Features

- Backup Odoo PostgreSQL databases using `pg_dump`
- Archive filestore directories together with database dump
- Configurable through environment variables
- Saves backups to host-mounted folder

## Prerequisites

- Docker
- Docker Compose

## Setup

1. Clone this repo:

   ```bash
   git clone git@github.com:bkumpar/odoo-16-backup.git
   cd odoo-16-backup

2. Create .env file for environment variables:

   cp .env.template .env

   Customize environment variables as needed

3. Configure backup.sh if you want to hardcode database names or change backup behavior.

    this is actually not true because script is moved into container. Script changes must be done on development machine and image must rebuilded

4. Run backup container:

    docker-compose up backup

5. Check backups in backup_output/ folder.

## Environment Variables

- PGHOST - PostgreSQL host

- PGPORT - PostgreSQL port

- PGUSER - PostgreSQL user

- PGPASSWORD - PostgreSQL password

- BACKUP_DIR - Directory inside container where backups are saved (default: /backup)

- FILESTORE_VOLUME - Path to filestore directory (default: /var/lib/odoo/filestore)

## License
MIT License

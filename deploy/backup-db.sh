#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_ROOT}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker belum tersedia."
    exit 1
fi

if [[ ! -f ".env" ]]; then
    echo ".env tidak ditemukan."
    exit 1
fi

backup_dir="${BACKUP_DIR:-/DATA/AppData/yudilahne-app/backups}"
retention_days="${BACKUP_RETENTION_DAYS:-7}"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_file="${backup_dir}/db-${timestamp}.sql.gz"

mkdir -p "${backup_dir}"
chmod 700 "${backup_dir}"

compose_args=(-f compose.yaml)

if [[ -f "deploy/certs/origin.crt" && -f "deploy/certs/origin.key" ]]; then
    compose_args+=(-f compose.prod.yaml)
else
    compose_args+=(-f compose.dev.yaml)
fi

echo "Membuat backup database ke ${backup_file}"
docker compose "${compose_args[@]}" exec -T db sh -lc \
    'exec mariadb-dump -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE"' \
    | gzip > "${backup_file}"

chmod 600 "${backup_file}"

find "${backup_dir}" -type f -name 'db-*.sql.gz' -mtime +"${retention_days}" -delete

echo "Backup selesai."

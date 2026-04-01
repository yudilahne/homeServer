#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRON_FILE="/tmp/yudilahne-db-backup.cron"

cat > "${CRON_FILE}" <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 2 * * * cd ${PROJECT_ROOT} && BACKUP_RETENTION_DAYS=14 bash deploy/backup-db.sh >> ${PROJECT_ROOT}/backups/backup.log 2>&1
EOF

crontab "${CRON_FILE}"
rm -f "${CRON_FILE}"

echo "Cron backup harian aktif jam 02:00 server time."

#!/bin/sh
set -e

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

if [ -z "${APP_KEY}" ]; then
    export APP_KEY="$(php artisan key:generate --show --no-ansi)"
    echo "APP_KEY tidak ditemukan di .env, memakai key sementara untuk container ini."
fi

if [ "${DB_CONNECTION}" = "mysql" ]; then
    until mariadb-admin ping -h "${DB_HOST}" -P "${DB_PORT:-3306}" -u"${DB_USERNAME}" -p"${DB_PASSWORD}" --silent; do
        echo "Menunggu database ${DB_HOST}:${DB_PORT:-3306} siap..."
        sleep 3
    done
fi

php artisan package:discover --ansi
php artisan storage:link || true
php artisan migrate --force

if [ "${RUN_DB_SEED}" = "true" ]; then
    php artisan db:seed --force
fi

exec "$@"

#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_ROOT}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker belum terpasang. Jalankan deploy/bootstrap-ubuntu.sh dulu di server Ubuntu."
    exit 1
fi

if [[ ! -f ".env" ]]; then
    echo ".env belum ada, menyalin dari .env.example"
    cp .env.example .env
    echo "Edit file .env lalu jalankan ulang script ini."
    exit 1
fi

app_url="$(grep '^APP_URL=' .env | tail -n 1 | cut -d '=' -f2-)"

compose_args=(-f compose.yaml)

if [[ -f "deploy/certs/origin.crt" && -f "deploy/certs/origin.key" ]]; then
    echo "Cloudflare origin certificate terdeteksi, mengaktifkan stack TLS produksi."
    compose_args+=(-f compose.prod.yaml)
    origin_health_scheme="https"

    if [[ -f "deploy/certs/cloudflare-origin-pull-ca.pem" ]]; then
        echo "Authenticated Origin Pulls aktif."
        compose_args+=(-f compose.aop.yaml)
    fi
else
    compose_args+=(-f compose.dev.yaml)
    origin_health_scheme="http"
fi

required_vars=(
    APP_URL
    DB_DATABASE
    DB_USERNAME
    DB_PASSWORD
    DB_ROOT_PASSWORD
    ADMIN_EMAIL
    ADMIN_PASSWORD
)

for key in "${required_vars[@]}"; do
    if ! grep -q "^${key}=" .env; then
        echo "Variabel ${key} belum ada di .env"
        exit 1
    fi

    value="$(grep "^${key}=" .env | tail -n 1 | cut -d '=' -f2-)"
    if [[ -z "${value}" ]]; then
        echo "Variabel ${key} masih kosong di .env"
        exit 1
    fi
done

if grep -q '^APP_KEY=$' .env; then
    echo "APP_KEY kosong, membuat key baru..."
    APP_KEY_VALUE="$(docker compose "${compose_args[@]}" run --rm --quiet-pull app php artisan key:generate --show --no-ansi | tail -n 1)"
    sed -i "s|^APP_KEY=$|APP_KEY=${APP_KEY_VALUE}|" .env
fi

echo "Build dan start container..."
docker compose "${compose_args[@]}" up -d --build

echo "Optimasi cache Laravel..."
docker compose "${compose_args[@]}" exec -T app php artisan config:cache
docker compose "${compose_args[@]}" exec -T app php artisan route:cache
docker compose "${compose_args[@]}" exec -T app php artisan view:cache

echo
echo "Deploy selesai."
if [[ " ${compose_args[*]} " == *" compose.prod.yaml "* ]]; then
    echo "Mode          : production TLS via Cloudflare Origin Certificate"
    echo "Origin health : ${origin_health_scheme}://SERVER_IP/up"
else
    echo "Mode          : standard HTTP origin"
    echo "Origin health : ${origin_health_scheme}://SERVER_IP/up"
fi
if [[ " ${compose_args[*]} " == *" compose.aop.yaml "* ]]; then
    echo "Origin access : restricted to Cloudflare mTLS"
fi
echo "Panel admin   : ${app_url%/}/admin"

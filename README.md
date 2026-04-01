# Yudilahne Web App

Starter project Laravel 13 + Filament 4 yang disiapkan untuk berjalan di Docker dan dideploy ke Ubuntu server di balik Cloudflare dengan domain `yudilahne.my.id`.

## API Flutter

Backend ini sudah menyiapkan API ringan berbasis Laravel Sanctum untuk aplikasi Flutter.

Base URL produksi:

```text
https://app.yudilahne.my.id/api/v1
```

Endpoint utama:

- `GET /health`
- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me`
- `PUT /auth/me`
- `PUT /auth/password`
- `POST /auth/logout`
- `POST /auth/logout-all`

Contoh login:

```json
{
  "email": "admin@yudilahne.my.id",
  "password": "your-password",
  "device_name": "flutter-android"
}
```

Response login akan mengembalikan bearer token. Untuk request berikutnya dari Flutter:

```text
Authorization: Bearer <token>
Accept: application/json
```

Contoh update profil:

```json
{
  "name": "Yudilahne",
  "email": "yudi@example.com"
}
```

Contoh ganti password:

```json
{
  "current_password": "Password123",
  "password": "Password456",
  "password_confirmation": "Password456"
}
```

## Struktur

- `laravel-app/`: source code Laravel + Filament
- `compose.yaml`: stack Docker untuk aplikasi, Nginx, dan MariaDB
- `compose.dev.yaml`: override lokal untuk membuka app langsung di port `80`
- `compose.prod.yaml`: override produksi untuk TLS origin di depan web container
- `compose.aop.yaml`: override tambahan untuk Authenticated Origin Pulls
- `docker/`: Dockerfile, entrypoint PHP, dan konfigurasi Nginx
- `deploy/`: script bootstrap Ubuntu dan script deploy/update aplikasi

## Quick Start Lokal

1. Salin env Docker:

   ```bash
   cp .env.example .env
   ```

2. Isi minimal variabel berikut di `.env`:

   ```env
   APP_KEY=
   DB_PASSWORD=super-rahasia
   DB_ROOT_PASSWORD=super-rahasia-root
   ADMIN_PASSWORD=super-rahasia-admin
   ```

3. Naikkan stack:

   ```bash
   docker compose -f compose.yaml -f compose.dev.yaml up -d --build
   ```

4. Buka:

   - App/admin: `http://localhost:8088/admin`
   - Health check: `http://localhost:8088/up`

Jika `APP_KEY` dibiarkan kosong, container akan membuat key sementara saat startup. Untuk environment yang stabil, isi `APP_KEY` permanen dengan hasil:

```bash
docker compose run --rm app php artisan key:generate --show
```

## Default Admin

Seeder akan membuat user admin dari variabel berikut jika `RUN_DB_SEED=true`:

```env
ADMIN_NAME="Yudilahne Admin"
ADMIN_EMAIL=admin@yudilahne.my.id
ADMIN_PASSWORD=change-this-admin-password
FILAMENT_ADMIN_EMAILS=admin@yudilahne.my.id
```

## Deploy ke Ubuntu Server

1. Salin repository ini ke Ubuntu server.
2. Jalankan bootstrap server:

   ```bash
   sudo bash deploy/bootstrap-ubuntu.sh
   ```

3. Buat env produksi:

   ```bash
   cp .env.example .env
   ```

4. Edit `.env`, lalu minimal isi:

   ```env
   APP_URL=https://app.yudilahne.my.id
   DB_PASSWORD=super-rahasia
   DB_ROOT_PASSWORD=super-rahasia-root
   ADMIN_EMAIL=admin@yudilahne.my.id
   ADMIN_PASSWORD=super-rahasia-admin
   ```

5. Jalankan deploy:

   ```bash
   bash deploy/deploy.sh
   ```

6. Verifikasi origin:

   ```bash
   curl http://SERVER_IP/up
   ```

7. Jika ada update code berikutnya, cukup jalankan lagi:

   ```bash
   git pull
   bash deploy/deploy.sh
   ```

## Konfigurasi Cloudflare

1. Buat record `A` untuk `yudilahne.my.id` ke IP publik Ubuntu server.
2. Aktifkan proxy Cloudflare pada record tersebut.
3. Set SSL/TLS mode ke `Full (strict)` setelah origin memakai Cloudflare Origin Certificate.
4. Set `APP_URL=https://yudilahne.my.id` di `.env`.

### Origin Certificate

Untuk mode produksi yang lebih rapi, project ini sekarang mendukung reverse proxy TLS berbasis `compose.prod.yaml`.

1. Di dashboard Cloudflare buka `SSL/TLS` lalu pilih `Origin Server`.
2. Buat `Origin Certificate` untuk:
   - `yudilahne.my.id`
   - `*.yudilahne.my.id`
3. Simpan file sertifikat dan private key dari Cloudflare ke server:

   ```bash
   mkdir -p deploy/certs
   nano deploy/certs/origin.crt
   nano deploy/certs/origin.key
   chmod 600 deploy/certs/origin.key
   ```

4. Deploy ulang:

   ```bash
   bash deploy/deploy.sh
   ```

Jika kedua file sertifikat tersedia, script deploy akan otomatis menambahkan [compose.prod.yaml](/Users/ngurahyudi/Documents/New%20project/compose.prod.yaml) dan menjalankan reverse proxy TLS di port `443`.
Jika tidak ada sertifikat origin, script deploy akan memakai [compose.dev.yaml](/Users/ngurahyudi/Documents/New%20project/compose.dev.yaml) agar origin tetap tersedia via HTTP.
Mode HTTP lokal/non-TLS default memakai port `8088` agar port `80` bisa dipakai service lain seperti CasaOS.

### Authenticated Origin Pulls

Jika Anda ingin origin hanya menerima request HTTPS dari Cloudflare:

1. Ambil sertifikat CA untuk `Authenticated Origin Pulls` dari dashboard atau dokumentasi resmi Cloudflare.
2. Simpan file tersebut sebagai:

   ```bash
   deploy/certs/cloudflare-origin-pull-ca.pem
   ```

3. Deploy ulang:

   ```bash
   bash deploy/deploy.sh
   ```

Jika file itu ada bersamaan dengan `origin.crt` dan `origin.key`, script deploy akan otomatis menambahkan [compose.aop.yaml](/Users/ngurahyudi/Documents/New%20project/compose.aop.yaml) dan proxy akan memverifikasi client certificate dari Cloudflare.

### Arsitektur Produksi

- `proxy`: terminasi TLS dengan Cloudflare Origin Certificate
- `web`: Nginx internal untuk melayani Laravel public directory
- `app`: PHP-FPM Laravel
- `db`: MariaDB

Untuk produksi penuh, saya tetap sarankan:

- backup volume database secara terjadwal
- tambah queue worker jika nanti memakai job asynchronous
- pertimbangkan Authenticated Origin Pulls jika ingin origin hanya menerima trafik dari Cloudflare

## Script Deploy

### `deploy/bootstrap-ubuntu.sh`

Script ini akan:

- install Docker Engine
- install Docker Compose plugin
- enable service Docker
- buka firewall untuk SSH, HTTP, dan HTTPS

### `deploy/deploy.sh`

Script ini akan:

- validasi `.env`
- generate `APP_KEY` jika masih kosong
- otomatis aktifkan stack TLS produksi jika `deploy/certs/origin.crt` dan `deploy/certs/origin.key` tersedia
- build image terbaru
- start/update semua service
- cache config, route, dan view Laravel

### `deploy/backup-db.sh`

Script ini akan:

- membuat dump MariaDB terkompresi ke folder `backups/`
- otomatis memilih mode compose yang sama seperti deploy
- menghapus backup lama sesuai `BACKUP_RETENTION_DAYS` (default `7`)
- mengunci permission backup directory dan file hasil dump

Contoh:

```bash
bash deploy/backup-db.sh
```

Atau dengan direktori dan retensi khusus:

```bash
BACKUP_DIR=/srv/backups BACKUP_RETENTION_DAYS=14 bash deploy/backup-db.sh
```

### `deploy/cron-backup.sh`

Script ini memasang cron harian jam `02:00` server time untuk menjalankan backup database otomatis dengan retensi `14` hari.

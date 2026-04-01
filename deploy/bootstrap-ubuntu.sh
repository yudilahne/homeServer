#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Jalankan script ini dengan sudo atau sebagai root."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/6] Update package index..."
apt-get update

echo "[2/6] Install dependensi dasar..."
apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    lsb-release \
    ufw

echo "[3/6] Tambah Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "[4/6] Tambah Docker repository..."
ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

echo "[5/6] Install Docker Engine + Compose plugin..."
apt-get update
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "[6/6] Aktifkan service dan buka firewall HTTP/HTTPS..."
systemctl enable --now docker

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo
echo "Bootstrap Ubuntu selesai."
echo "Verifikasi Docker:"
docker --version
docker compose version

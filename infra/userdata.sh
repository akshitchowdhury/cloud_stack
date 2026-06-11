#!/bin/bash
set -e
set -o pipefail
exec > >(tee /var/log/userdata.log) 2>&1

echo "=== Starting userdata script ==="

# ─── 1. System update ───────────────────────────────────────────
echo "=== Updating system packages ==="
apt-get update -y
apt-get upgrade -y

# ─── 2. Install Docker ──────────────────────────────────────────
echo "=== Installing Docker ==="
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker
docker --version
echo "=== Docker installed ==="

# ─── 3. Add ubuntu user to docker group ─────────────────────────
echo "=== Configuring docker permissions ==="
usermod -aG docker ubuntu

# ─── 4. Clone repo (we only need docker-compose.yml) ────────────
echo "=== Cloning repository ==="
cd /home/ubuntu
git clone ${github_repo} cloud_stack
chown -R ubuntu:ubuntu cloud_stack

# ─── 5. Create .env file for docker-compose ─────────────────────
echo "=== Writing environment variables ==="
cat > /home/ubuntu/cloud_stack/.env <<EOF
POSTGRES_DB=${db_name}
POSTGRES_USER=${db_user}
POSTGRES_PASSWORD=${db_password}
SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/${db_name}
SPRING_DATASOURCE_USERNAME=${db_user}
SPRING_DATASOURCE_PASSWORD=${db_password}
EOF
chmod 600 /home/ubuntu/cloud_stack/.env
chown ubuntu:ubuntu /home/ubuntu/cloud_stack/.env

# ─── 6. Pull images and start stack ─────────────────────────────
echo "=== Starting application stack ==="
cd /home/ubuntu/cloud_stack
docker compose pull          # pulls latest images from Docker Hub
docker compose up -d         # starts all 3 containers detached

echo "=== Userdata script complete ==="
echo "=== App should be live on port 80 ==="
#!/bin/bash
set -e
set -o pipefail
exec > >(tee /var/log/userdata.log) 2>&1

echo "=== Starting userdata script ==="

# ─── 1. System update ───────────────────────────────────────────
echo "=== Updating system packages ==="
apt-get update -y
apt-get upgrade -y

# ─── 2. Install Java 21 ─────────────────────────────────────────
echo "=== Installing Java 21 ==="
apt-get install -y openjdk-21-jdk
java -version

# ─── 3. Install Maven ───────────────────────────────────────────
echo "=== Installing Maven ==="
apt-get install -y maven
mvn -version

# ─── 4. Install Node.js 20 ──────────────────────────────────────
echo "=== Installing Node.js ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
node -v && npm -v

# ─── 5. Install Nginx ───────────────────────────────────────────
echo "=== Installing Nginx ==="
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# ─── 6. Install PostgreSQL ──────────────────────────────────────
echo "=== Installing PostgreSQL ==="
apt-get install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql

# ─── 7. Set up database ─────────────────────────────────────────
echo "=== Setting up database ==="
sudo -u postgres psql <<EOF
ALTER USER ${db_user} WITH PASSWORD '${db_password}';
CREATE DATABASE ${db_name};
GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_user};
\c ${db_name}
GRANT ALL ON SCHEMA public TO ${db_user};
EOF

# ─── 8. Fix home directory permissions for Nginx ────────────────
echo "=== Fixing permissions ==="
chmod o+x /home/ubuntu

# ─── 9. Clone the repo ──────────────────────────────────────────
echo "=== Cloning repository ==="
cd /home/ubuntu
git clone ${github_repo} cloud_stack
chown -R ubuntu:ubuntu cloud_stack

# ─── 10. Build the backend ──────────────────────────────────────
echo "=== Building Spring Boot backend ==="
cd /home/ubuntu/cloud_stack/cloud_stack_server
mvn clean package -DskipTests
echo "=== Backend build complete ==="

# ─── 11. Build the frontend ─────────────────────────────────────
echo "=== Building React frontend ==="
cd /home/ubuntu/cloud_stack/cloud_stack_ui
npm install
npm run build
echo "=== Frontend build complete ==="

# ─── 12. Configure Nginx ────────────────────────────────────────
echo "=== Configuring Nginx ==="
cat > /etc/nginx/sites-available/cloud_stack <<'NGINX'
server {
    listen 80;
    server_name _;

    root /home/ubuntu/cloud_stack/cloud_stack_ui/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/cloud_stack /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# ─── 13. Create environment file for Spring Boot ────────────────
echo "=== Creating environment file ==="
cat > /etc/cloud_stack.env <<EOF
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
EOF
chmod 600 /etc/cloud_stack.env

# ─── 14. Create systemd service ─────────────────────────────────
echo "=== Creating systemd service ==="
cat > /etc/systemd/system/cloud_stack.service <<'SERVICE'
[Unit]
Description=Cloud Stack Spring Boot App
After=network.target postgresql.service

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/cloud_stack/cloud_stack_server
ExecStart=java -jar target/test0-0.0.1-SNAPSHOT.jar
EnvironmentFile=/etc/cloud_stack.env
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable cloud_stack
systemctl start cloud_stack

echo "=== Userdata script complete ==="
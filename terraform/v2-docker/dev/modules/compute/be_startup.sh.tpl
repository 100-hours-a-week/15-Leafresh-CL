#!/bin/bash

# 이건 왜 색을 안받는데
sudo ufw allow ${port}/tcp
sudo ufw allow 22/tcp
echo "y" | sudo ufw enable

# Docker 설치
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Secret Manager에서 .env 불러오기
sudo mkdir -p /etc/app
gcloud secrets versions access latest --secret="${secret_name}" > /etc/app/.env

# 도메인 변수 정의
DOMAIN="${domain}"

# 인증서 폴더 준비
sudo mkdir -p /etc/letsencrypt /var/lib/letsencrypt

# 인증서 발급 (Certbot 컨테이너 사용)
sudo docker run --rm -p 80:80 \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
  certbot/certbot certonly --standalone --non-interactive --agree-tos \
  -m admin@${domain} -d ${domain}

# Compose 및 Nginx 설정 준비
sudo mkdir -p /opt/backend/nginx

# docker-compose.yml
cat > /opt/backend/docker-compose.yml <<EOF
${docker_compose}
EOF

# nginx/default.conf
cat > /opt/backend/nginx/default.conf <<EOF
${nginx_conf}
EOF

# 서비스 실행
cd /opt/backend
sudo docker compose up -d

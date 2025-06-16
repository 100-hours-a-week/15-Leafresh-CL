#!/bin/bash
# Time Set
sudo timedatectl set-timezone Asia/Seoul
sudo timedatectl set-ntp true

# 이건 왜 색을 안받는데
sudo ufw allow ${port}/tcp
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
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
sudo mkdir -p /home/ubuntu/backend/app
gcloud secrets versions access latest --secret="${secret_name}" > /home/ubuntu/backend/app/.env
sudo chown ubuntu:ubuntu /home/ubuntu/backend/app/.env

# Secret Manager에서 JSON 파일(gcp-key) 불러오기
gcloud secrets versions access latest --secret="${secret_name_json}" > /home/ubuntu/backend/app/leafresh-gcs.json
sudo chown ubuntu:ubuntu /home/ubuntu/backend/app/leafresh-gcs.json
sudo chmod 600 /home/ubuntu/backend/app/leafresh-gcs.json

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
sudo mkdir -p /home/ubuntu/backend/nginx

# docker-compose.yml
cat > /home/ubuntu/backend/docker-compose.yml <<EOF
${docker_compose}
EOF

# nginx/default.conf
cat > /home/ubuntu/backend/nginx/default.conf <<EOF
${nginx_conf}
EOF

# 서비스 실행
cd /home/ubuntu/backend
sudo docker compose pull
sudo docker compose up -d

# gcs 마운트
mkdir /home/ubuntu/logs
gcsfuse leafresh-gcs-logs /home/ubuntu/logs

nohup sudo docker logs -f ${container_name} > /home/ubuntu/logs/${container_name}_$(date +%Y%m%d).log &
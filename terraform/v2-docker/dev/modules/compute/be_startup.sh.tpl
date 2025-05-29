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

# Docker Hub에서 이미지 다운로드 및 실행
sudo docker run -d \
  --name ${container_name} \
  -p ${port}:${port} \
  --env-file /etc/app/.env \
  ${image}

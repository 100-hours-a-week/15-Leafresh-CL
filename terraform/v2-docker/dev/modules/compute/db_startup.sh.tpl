#!/bin/bash

# 내부 IP 가져오기
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

# 방화벽 설정
sudo ufw allow 3306/tcp
sudo ufw allow ${redis_port}/tcp
sudo ufw allow 8001/tcp
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

# .env 파일 생성
cat << ENV > /home/ubuntu/.env
MYSQL_ROOT_PASSWORD=${mysql_root_password}
MYSQL_DATABASE=${mysql_database}
docker_local_cache_host=${redis_host}
docker_local_cache_port=${redis_port}
ENV

# MySQL 설정 생성
sudo mkdir -p /home/ubuntu/mysql-conf
cat << CNF > /home/ubuntu/mysql-conf/custom.cnf
[mysqld]
bind-address = 0.0.0.0
CNF

# RedisBloom은 이미지 자체에 모듈 포함되어 있음

# docker-compose.yml 생성
cat << COMPOSE > /home/ubuntu/docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql-develop
    restart: always
    env_file:
      - /home/ubuntu/.env
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - /home/ubuntu/mysql-conf/custom.cnf:/etc/mysql/conf.d/custom.cnf:ro
    networks:
      - internal_network

  redis:
    image: redislabs/rebloom:2.8.1
    container_name: redis-develop
    restart: always
    ports:
      - "${redis_port}:${redis_port}"
      - "8001:8001"
    volumes:
      - redis_data:/data
    networks:
      - internal_network

volumes:
  mysql_data:
  redis_data:

networks:
  internal_network:
    driver: bridge
COMPOSE

# Docker Compose 실행
sudo docker compose -f /home/ubuntu/docker-compose.yml up -d

# gcs 마운트
mkdir /home/ubuntu/logs
gcsfuse leafresh-gcs-logs /home/ubuntu/logs

nohup sudo docker logs -f mysql-develop > /home/ubuntu/logs/mysql-develop_$(date +%Y%m%d).log &
nohup sudo docker logs -f redis-develop > /home/ubuntu/logs/redis-develop_$(date +%Y%m%d).log &
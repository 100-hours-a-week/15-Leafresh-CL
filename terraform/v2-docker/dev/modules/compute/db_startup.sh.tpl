#!/bin/bash

# 내부 IP Get
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
sudo mkdir -p /home/ubuntu/mysql_data
sudo mkdir -p /home/ubuntu/mysql-conf
cat << CNF > /home/ubuntu/mysql-conf/custom.cnf
[mysqld]
bind-address = 0.0.0.0
CNF

# gcs 마운트
mkdir -p /home/ubuntu/logs
gcsfuse leafresh-gcs-logs /home/ubuntu/logs

# Redis stack 적용
sudo mkdir -p /home/ubuntu/redis_data
cat << CNF > /home/ubuntu/redis-conf/redis-stack.conf
bind 0.0.0.0
protected-mode no
port 6379
daemonize no
loadmodule /opt/redis-stack/lib/redisbloom.so
save 900 1
save 300 10
save 60 10000
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
dir /data
CNF

# docker-compose.yml 생성
cat << COMPOSE > /home/ubuntu/docker-compose.yml
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
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
    image: redis/redis-stack:latest
    container_name: redis
    restart: always
    ports:
      - "${redis_port}:${redis_port}"
      - "8001:8001"
    volumes:
      - redis_data:/data
      - /home/ubuntu/redis-conf/redis-stack.conf:/etc/redis/redis-stack.conf
    networks:
      - internal_network
    command: ["redis-server", "/etc/redis/redis-stack.conf"]

volumes:
  mysql_data:
  redis_data:

networks:
  internal_network:
    driver: bridge
COMPOSE

# Docker Compose 실행
sudo docker compose -f /home/ubuntu/docker-compose.yml up -d
nohup sudo docker logs -f mysql-develop > /home/ubuntu/logs/mysql-develop_$(date +%Y%m%d).log &
nohup sudo docker logs -f redis-develop > /home/ubuntu/logs/redis-develop_$(date +%Y%m%d).log &

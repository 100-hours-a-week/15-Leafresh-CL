#!/bin/bash

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
MYSQL_USER=${mysql_user}
MYSQL_PASSWORD=${mysql_user_password}
docker_local_cache_host=${redis_host}
docker_local_cache_port=${redis_port}
ENV

# custom.cnf (MySQL) 생성
sudo mkdir -p /home/ubuntu/mysql-conf
cat << CNF > /home/ubuntu/mysql-conf/custom.cnf
[mysqld]
bind-address = ${mysql_bind_ip}
CNF

# redis.conf 생성
sudo mkdir -p /home/ubuntu/redis-conf
cat << RCNF > /home/ubuntu/redis-conf/redis.conf
bind ${redis_bind_ip}
port ${redis_port}
protected-mode yes
RCNF

# docker-compose.yml 생성
cat << COMPOSE > /home/ubuntu/docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: leafresh-mysql
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
    image: redis:7.2-alpine
    container_name: leafresh-redis
    restart: always
    ports:
      - "${redis_port}:${redis_port}"
      - "8001:8001"
    volumes:
      - redis_data:/data
      - /home/ubuntu/redis-conf/redis.conf:/usr/local/etc/redis/redis.conf:ro
    command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
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

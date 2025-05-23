#!/bin/bash
apt-get update
apt-get install -y redis-server mysql-server build-essential wget make

# RedisBloom
wget https://github.com/RedisBloom/RedisBloom/archive/refs/tags/v2.6.18.tar.gz
tar -xvf v2.6.18.tar.gz
cd RedisBloom-2.6.18/
make && make install
nohup redis-server --loadmodule RedisBloom-2.6.18/bin/linux-x64-release/redisbloom.so > /var/log/redis.log 2>&1 &

# MySQL 초기화
cat <<EOSQL | sudo mysql
UNINSTALL COMPONENT 'file://component_validate_password';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_root_password}';
FLUSH PRIVILEGES;
CREATE DATABASE ${mysql_database} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_user_password}';
GRANT ALL PRIVILEGES ON ${mysql_database}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
EOSQL


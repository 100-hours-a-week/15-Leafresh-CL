#!/bin/bash

# 내부 IP Get
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

# 방화벽 설정
# sudo ufw allow 3306/tcp
sudo ufw allow 3306/tcp
sudo ufw allow 8001/tcp
sudo ufw allow 22/tcp
echo "y" | sudo ufw enable


# Redis Dependencies 설치
apt-get update
apt-get install -y sudo
sudo apt-get install -y --no-install-recommends ca-certificates wget dpkg-dev gcc g++ libc6-dev libssl-dev make git python3 python3-pip python3-venv python3-dev unzip rsync clang automake autoconf gcc-10 g++-10 libtool

# GCC 10을 기본 컴파일러로 변경
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10

# CMake 설치
pip3 install cmake==3.31.6
sudo ln -sf /usr/local/bin/cmake /usr/bin/cmake
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
cmake --version

# Redis Github 레포 다운로드
cd /usr/src
sudo wget -O redis-8.0.0.tar.gz https://github.com/redis/redis/archive/refs/tags/8.0.0.tar.gz

# Redis 압축 해제
cd /usr/src
sudo tar xvf redis-8.0.0.tar.gz
rm redis-8.0.0.tar.gz

# Redis 설치
cd /usr/src/redis-8.0.0
export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
sudo make -j "$(nproc)" all

# RedisBloom 설치
cd /usr/src/redis-8.0.0/modules/redisbloom
make

# Redis 실행
cd /usr/src/redis-8.0.0
nohup /src/redis-server redis-full.conf > /home/ubuntu/logs/redis_server.log 2>&1 &


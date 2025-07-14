#! /bin/bash

# 기존 프로세스 종료
./kill_process.sh

# 조금 기다리다가
sleep 10;

# 다시 프로세스 시작
./start_servers.sh

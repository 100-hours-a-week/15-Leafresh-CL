#!/bin/bash

set -e
SERVICE="$1"
LOG_DIR="/home/deploy/logs"
mkdir -p "$LOG_DIR"

# 색상 상수
COLOR_SUCCESS=65280     # 초록
COLOR_FAILURE=16711680  # 빨강

check_pid() {
  sleep 3
  if ps aux | grep "$1" | grep -v grep > /dev/null; then
    echo "[$2] 실행 완료"
    return 0
  else
    echo "[$2] 실행 실패"
    return 1
  fi
}

start_be() {
  echo "[BE] 실행 중..."
  cd /home/deploy/be/
  nohup env $(grep -v '^#' .env.bigbang | xargs) java -jar backend-0.0.1-SNAPSHOT.jar > "$LOG_DIR/be.log" 2>&1 &
  if check_pid "backend-0.0.1-SNAPSHOT.jar" "BE"; then
    bash /home/deploy/discord_notify.sh "Leafresh BE 수동 재시작 완료!" $COLOR_SUCCESS
  else
    bash /home/deploy/discord_notify.sh "Leafresh BE 실행 실패!" $COLOR_FAILURE
  fi
}

start_ai() {
  echo "[AI] 실행 중..."
  cd /home/deploy/ai/
  # nohup env $(grep -vE '^\s*#|^\s*$' .env | sed 's/\s*#.*$//' | xargs) uvicorn main:app --host 0.0.0.0 --port 8000 > "$LOG_DIR/ai.log" 2>&1 &
  nohup bash -c "source /home/deploy/ai/.venv/bin/activate && cd /home/deploy/ai && env \$(grep -vE '^\s*#|    ^\s*$' .env | sed 's/\s*#.*$//' | xargs) uvicorn main:app --host 0.0.0.0 --port 8000" > "$LOG_DIR/ai.log" 2>&1 &
  if check_pid "uvicorn" "AI"; then
    bash /home/deploy/discord_notify.sh "Leafresh AI 수동 재시작 완료!" $COLOR_SUCCESS
  else
    bash /home/deploy/discord_notify.sh "Leafresh AI 실행 실패!" $COLOR_FAILURE
  fi
}

start_fe() {
  echo "[FE] 실행 중..."
  cd /home/deploy/fe/
  nohup pnpm run start > "$LOG_DIR/fe.log" 2>&1 &
  if check_pid "pnpm run start" "FE"; then
    bash /home/deploy/discord_notify.sh "Leafresh FE 수동 재시작 완료!" $COLOR_SUCCESS
  else
    bash /home/deploy/discord_notify.sh "Leafresh FE 실행 실패!" $COLOR_FAILURE
  fi
}

case "$SERVICE" in
  be)
    start_be
    ;;
  ai)
    start_ai
    ;;
  fe)
    start_fe
    ;;
  all|"")
    start_be
    start_ai
    start_fe
    echo "3개 스택 실행 완료!"
    ;;
  *)
    echo "사용법: $0 [be|ai|fe|all]"
    exit 1
    ;;
esac


#!/bin/bash

SERVICE="$1"

kill_be() {
  echo "[BE] 종료 시도..."
  pkill -f ".jar" || true
  sleep 2
  if pgrep -f ".jar" > /dev/null; then
    echo "[BE] 종료 실패"
  else
    echo "[BE] 종료 완료"
    bash /home/deploy/discord_notify.sh "Leafresh BE 종료 완료!" 16711680
  fi
}

kill_ai() {
  echo "[AI] 종료 시도..."
  pkill -f "uvicorn" || true
  sleep 2
  if pgrep -f "uvicorn" > /dev/null; then
    echo "[AI] 종료 실패"
  else
    echo "[AI] 종료 완료"
    bash /home/deploy/discord_notify.sh "Leafresh AI 종료 완료!" 16711680
  fi
}

kill_fe() {
  echo "[FE] 종료 시도..."
  pkill -f "next" || true
  sleep 2
  if pgrep -f "next" > /dev/null; then
    echo "[FE] 종료 실패"
  else
    echo "[FE] 종료 완료"
    bash /home/deploy/discord_notify.sh "Leafresh FE 종료 완료!" 16711680
  fi
}

case "$SERVICE" in
  be)
    kill_be
    ;;
  ai)
    kill_ai
    ;;
  fe)
    kill_fe
    ;;
  all|"")
    kill_be
    kill_ai
    kill_fe
    ;;
  *)
    echo "사용법: $0 [be|ai|fe|all]"
    exit 1
    ;;
esac


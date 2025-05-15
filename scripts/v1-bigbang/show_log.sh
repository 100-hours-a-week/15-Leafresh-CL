#!/bin/bash

# 인자가 없는 경우 메시지 출력 후 종료
if [ $# -eq 0 ]; then
  echo "사용법: ./show_log.sh [fe|be|ai]"
  exit 1
fi

for name in "$@"; do
  case "$name" in
    fe)
      LOG_PATH="/home/deploy/logs/fe.log"
      ;;
    be)
      LOG_PATH="/home/deploy/logs/be.log"
      ;;
    ai)
      LOG_PATH="/home/deploy/logs/ai.log"
      ;;
    *)
      echo "알 수 없는 서비스 이름: $name"
      continue
      ;;
  esac

  if [ -f "$LOG_PATH" ]; then
    echo "=== 최근 로그 60줄 ($name.log) ==="
    tail -n 60 "$LOG_PATH"
    echo ""
  else
    echo "$LOG_PATH 파일이 존재하지 않습니다."
  fi
done


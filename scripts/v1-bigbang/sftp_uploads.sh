#!/bin/bash

set -e

UPLOAD_DIR="/home/sftpuser/uploads"
LOG_DIR="/home/deploy/logs"
mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/deploy.log"
}

restart_be() {
  log "BE 서버 재시작"
  pkill -f '.jar' || true
  cd /home/deploy/be || exit 1
  nohup env $(grep -v '^#' .env.bigbang | xargs) java -jar backend-0.0.1-SNAPSHOT.jar > "$LOG_DIR/be.log" 2>&1 &
  log "BE 서버 시작 완료"
}

restart_ai() {
  log "AI 서버 재시작"
  pkill -f 'uvicorn' || true
  nohup bash -c "source /home/deploy/ai/.venv/bin/activate && cd /home/deploy/ai && env \$(grep -vE '^\s*#|^\s*$' .env | sed 's/\s*#.*$//' | xargs) uvicorn main:app --host 0.0.0.0 --port 8000" > "$LOG_DIR/ai.log" 2>&1 &
  log "AI 서버 시작 완료"
}

restart_fe() {
  log "FE 서버 재시작"
  pkill -f 'next' || true
  cd /home/deploy/fe || exit 1
  nohup pnpm run start > "$LOG_DIR/fe.log" 2>&1 &
  log "FE 서버 시작 완료"
}

log "업로드 디렉토리 감시 시작: $UPLOAD_DIR"

inotifywait -m -e close_write --format "%f" "$UPLOAD_DIR" | while read FILE; do
  log "업로드 감지: $FILE"

  case "$FILE" in
    backend*.jar)
      mv "$UPLOAD_DIR/$FILE" "/home/deploy/be/$FILE"
      log "$FILE → /home/deploy/be 로 이동됨"
      restart_be
      ;;

    frontend*.zip)
      TARGET_DIR="/home/deploy/fe"
      mv "$UPLOAD_DIR/$FILE" "$TARGET_DIR/$FILE"
      unzip -o "$TARGET_DIR/$FILE" -d "$TARGET_DIR"
      log "$FILE → $TARGET_DIR 에 압축 해제됨"
      restart_fe
      ;;

    AI*.zip)
      TARGET_DIR="/home/deploy"
      mv "$UPLOAD_DIR/$FILE" "$TARGET_DIR/$FILE"
      unzip -o "$TARGET_DIR/$FILE" -d "$TARGET_DIR"
      log "$FILE → $TARGET_DIR 에 압축 해제됨"
      restart_ai
      ;;

    *)
      log "$FILE: 인식되지 않음 → 처리하지 않음"
      ;;
  esac
done


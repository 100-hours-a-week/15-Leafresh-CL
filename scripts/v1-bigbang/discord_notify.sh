#!/bin/bash

# 사용법: ./discord_notify.sh "메시지 내용" 색상코드
# 예시: ./discord_notify.sh "FE 재시작 완료!" 65280

DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1367371557005037688/1PgdZJR6aAIpicBl17A4WzHIfWHxtwlaIqERVBqy2D2CNiaB3q27kKi8p4qBG73J4cc6i"
MESSAGE="$1"
COLOR="${2:-16777215}"  # 기본값: 흰색

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")  # ISO 8601 UTC 타임스탬프

read -r -d '' WEBHOOK_JSON <<EOF
{
  "embeds": [
    {
      "title": "$MESSAGE",
      "color": $COLOR,
      "timestamp": "$TIMESTAMP"
    }
  ]
}
EOF

RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d "$WEBHOOK_JSON" "$DISCORD_WEBHOOK_URL")

if [ "$RESPONSE_CODE" = "204" ]; then
  echo "Discord embed 알림 전송 성공"
else
  echo "Discord 알림 실패 (응답 코드: $RESPONSE_CODE)"
  echo "전송 JSON: $WEBHOOK_JSON"
  echo "웹훅 URL: $DISCORD_WEBHOOK_URL"
fi


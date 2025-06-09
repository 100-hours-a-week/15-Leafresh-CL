# 1단계: 빌드 스테이지
FROM gradle:8.5-jdk21 AS builder

WORKDIR /app

COPY --chown=gradle:gradle . .

RUN gradle build --no-daemon

# 2단계: 실행 스테이지
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

# 환경 변수는 외부에서 전달
ENTRYPOINT ["java", "-jar", "app.jar"]

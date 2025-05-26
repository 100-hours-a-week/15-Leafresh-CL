# Stage 1: Build the Java application using Gradle
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

# Copy Gradle wrapper, settings, and build files
COPY gradlew gradlew.bat settings.gradle ./
COPY build.gradle ./

# Download dependencies to leverage Docker cache
RUN ./gradlew dependencies --write-locks || true

# Copy the rest of the source code
COPY . .

# Build the Spring Boot application into a JAR
RUN ./gradlew bootJar

# Stage 2: Create the production-ready image with JRE only
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Expose port 8080 (Spring Boot default)
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]

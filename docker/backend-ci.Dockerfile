# Used by the Jenkins "Docker Build" stage.
#
# Unlike docker/backend.Dockerfile (used for local dev via docker-compose),
# this Dockerfile does NOT run Maven itself - the jar was already built and
# tested by the "Package Jar" stage on the Jenkins agent. Building it again
# inside Docker would duplicate work and drift from what Jenkins actually
# tested. This image just packages the artifact Jenkins already validated.
#
# Build context is the repo root (see Jenkinsfile "Docker Build" stage).

FROM eclipse-temurin:21-jre-alpine

RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app
COPY backend/target/enterprise-devops-backend.jar app.jar

USER spring:spring
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

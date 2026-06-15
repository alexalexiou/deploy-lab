# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy the POM first and resolve dependencies so this layer is cached
# and only re-runs when dependencies actually change.
COPY pom.xml .
RUN mvn -q dependency:go-offline

# Now copy the source and build the jar. Tests are skipped here because
# they need a Docker daemon (Testcontainers); they run in CI instead.
COPY src ./src
RUN mvn -q clean package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

# Run as a non-root user to reduce the blast radius if the app is compromised.
RUN addgroup -S app && adduser -S app -G app
USER app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

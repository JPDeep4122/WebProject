# Build the executable Spring Boot WAR with the same Java major version as the project.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace

COPY pom.xml ./

COPY src ./src
RUN mvn -B -DskipTests package

# Keep Maven and the JDK out of the runtime image.
FROM eclipse-temurin:21-jre
WORKDIR /app

RUN useradd --system --uid 10001 --create-home appuser
COPY --from=build /workspace/target/dienmay-shop-0.0.1-SNAPSHOT.war /app/app.war

USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.war"]

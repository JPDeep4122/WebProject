# Build the executable Spring Boot WAR with the same Java major version as the project.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace

COPY pom.xml ./

COPY src ./src
RUN mvn -B -DskipTests package

# Keep Maven and the JDK out of the runtime image.
FROM eclipse-temurin:21-jre
WORKDIR /app

# Leave room for class metadata, JSP compilation, threads and native libraries
# alongside the Java heap on a 512 MB instance. Render can override this variable.
ENV JAVA_TOOL_OPTIONS="-Xms64m -Xmx192m -Xss512k -XX:+UseSerialGC -XX:MaxMetaspaceSize=128m -XX:ReservedCodeCacheSize=32m -XX:MaxDirectMemorySize=16m -XX:ActiveProcessorCount=1 -XX:TieredStopAtLevel=1 -XX:+ExitOnOutOfMemoryError"
ENV SPRING_PROFILES_ACTIVE=render

RUN useradd --system --uid 10001 --create-home appuser
COPY --from=build /workspace/target/dienmay-shop-0.0.1-SNAPSHOT.war /app/app.war

USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.war"]

# ----------- Build Stage -----------
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom and download dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# Copy source and build
COPY src/ ./src/
RUN mvn clean package -DskipTests -B

# ----------- Run Stage -----------
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create a non-root user
RUN adduser -D minecraft

# Copy built jar from build stage
COPY --from=build /app/target/minestom-lobby-1.0.jar ./minestom-lobby.jar

# Set ownership to minecraft user
RUN chown minecraft:minecraft minestom-lobby.jar

# Expose Minestom port
EXPOSE 25565

# Set JVM options for Cloud Run
ENV JAVA_OPTS="-Xms128m -Xmx256m -XX:+UseG1GC -XX:+UseContainerSupport"

# Switch to minecraft user
USER minecraft

# Run the server
CMD ["sh", "-c", "java $JAVA_OPTS -jar minestom-lobby.jar"]
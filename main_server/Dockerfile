FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /minecraft

# Install dependencies: curl, jq, unzip, bash
RUN apk add --no-cache curl jq unzip bash

# Copy scripts
COPY latest_paper.sh .
RUN chmod +x latest_paper.sh

COPY start.sh .
RUN chmod +x start.sh

# Copy server.properties
COPY server.properties .

# Optionally copy plugins if you have them
COPY plugins ./plugins

# Expose default Minecraft port
EXPOSE 25565

# Write EULA file
RUN echo "eula=true" > eula.txt

# Declare /minecraft as a volume
VOLUME ["/minecraft"]

# Create a new user and switch to it
RUN adduser -D -h /minecraft minecraft

# Set ownership of all files in /minecraft to the minecraft user
RUN chown -R minecraft:minecraft /minecraft

USER minecraft

# Run update and start server using bash
CMD ["bash", "./start.sh"]
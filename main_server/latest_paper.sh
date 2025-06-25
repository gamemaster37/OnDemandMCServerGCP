#!/usr/bin/env sh

PROJECT="paper"
VERSION_LOG="version.log"

# Get the latest stable version (the last version with a stable build)
LATEST_STABLE_VERSION=""
LATEST_STABLE_BUILD=""

# Find the latest version with a stable build
for version in $(curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r '.versions[]' | tac); do
    build=$(curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${version}/builds | \
        jq '.builds | map(select(.channel == "default") | .build) | .[-1]')
    if [ "$build" != "null" ]; then
        LATEST_STABLE_VERSION="$version"
        LATEST_STABLE_BUILD="$build"
        break
    fi
done

echo "Latest stable version: $LATEST_STABLE_VERSION"
echo "Latest stable build: $LATEST_STABLE_BUILD"

# Read previous version/build from version.log if it exists
if [ -f "$VERSION_LOG" ]; then
    read -r PREV_VERSION PREV_BUILD < "$VERSION_LOG"
    if [ "$PREV_VERSION" = "$LATEST_STABLE_VERSION" ] && [ "$PREV_BUILD" = "$LATEST_STABLE_BUILD" ]; then
        echo "Already up to date ($PREV_VERSION build $PREV_BUILD). No download needed."
        exit 0
    fi
fi

# Download the latest stable build
DOWNLOAD_URL="https://api.papermc.io/v2/projects/${PROJECT}/versions/${LATEST_STABLE_VERSION}/builds/${LATEST_STABLE_BUILD}/downloads/paper-${LATEST_STABLE_VERSION}-${LATEST_STABLE_BUILD}.jar"
FILENAME="paper-${LATEST_STABLE_VERSION}-${LATEST_STABLE_BUILD}.jar"

echo "Downloading $FILENAME..."
if curl -L -o "$FILENAME" "$DOWNLOAD_URL"; then
    echo "Successfully downloaded: $FILENAME"
    if [ -f server.jar ]; then
        mv server.jar server_old.jar
    fi
    mv "$FILENAME" server.jar
    echo "$LATEST_STABLE_VERSION $LATEST_STABLE_BUILD" > "$VERSION_LOG"
    echo "Updated server.jar to the latest Paper build."
    exit 0
else
    echo "Failed to download the jar file"
    exit 1
fi
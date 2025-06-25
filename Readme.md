# OnDemandMCServerGCP

A Google Cloud Platform-based on-demand Minecraft server solution with a Minestom-powered lobby and automated PaperMC updates.

## Features

- **On-demand server startup** via Google Cloud Functions ([gcp/cloud_function.js](gcp/cloud_function.js))
- **Lobby server** using Minestom ([proxy_server/lobby](proxy_server/lobby)), acts as a waiting room while the main server starts
- **Main Minecraft server** with PaperMC auto-updater ([main_server/latest_paper.sh](main_server/latest_paper.sh))
- **Plugin support** (LoginSecurity, EmptyServerStopper)
- **Dockerized deployment** for both lobby and main server
- **Auto-start/stop scripts** for Docker containers/vm ([gcp/instance](gcp/instance))

> **Note:** Proxy functionality is planned but not yet implemented. The lobby is currently a standalone Minestom server.

## Directory Structure

```
gcp/                  # Google Cloud Function for VM control
  instance/           # Autostart/autostop scripts
main_server/          # Main Minecraft server (PaperMC)
  plugins/            # Plugins and configs
proxy_server/lobby/   # Minestom lobby server (not a proxy yet)
```

## Quick Start

### Main Server

1. Build and run with Docker:
    ```sh
    cd main_server
    docker build -t paper-mc .
    docker run -d --name paper-mc -p 25565:25565 paper-mc
    ```

2. The server auto-downloads the latest PaperMC build on startup.

### Lobby Server

1. Build and run with Docker:
    ```sh
    cd proxy_server/lobby
    docker build -t minestom-mc .
    docker run -d --name minestom-mc -p 25565:25565 minestom-mc
    ```

### Google Cloud Function

- Deploy [gcp/cloud_function.js](gcp/cloud_function.js) to Google Cloud Functions to control VM startup and DNS updates.

## Configuration

- **Minecraft server properties:** [main_server/server.properties](main_server/server.properties)
- **LoginSecurity plugin:** [main_server/plugins/LoginSecurity/config.yml](main_server/plugins/LoginSecurity/config.yml)
- **EmptyServerStopper plugin:** [main_server/plugins/EmptyServerStopper/config.yml](main_server/plugins/EmptyServerStopper/config.yml)

## License

This project is licensed under the [MIT License](LICENSE).
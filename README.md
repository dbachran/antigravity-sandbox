# Antigravity Sandbox

A Podman-based sandbox environment (with Docker fallback) for running **Antigravity Hub** and **Antigravity IDE** inside a container with full GUI support (Wayland / X11).

## Overview

This project packages Antigravity Hub and Antigravity IDE into an Ubuntu 24.04 container, forwarding the host's display server so that both applications can render their UIs natively. It also bundles Google Chrome for handling OAuth login flows via a custom `xdg-open` wrapper.

## Prerequisites

| Requirement | Details |
|---|---|
| **Podman / Docker** | Podman with Podman Compose (preferred), or Docker with Compose v2 |
| **Display server** | Wayland (preferred) or X11 |
| **GPU access** | `/dev/dri` must be available on the host |
| **Host OS** | Linux (tested on Wayland-based desktops) |

## Quick Start

```bash
# Clone the repository
git clone https://github.com/dbachran/antigravity-sandbox.git
cd antigravity-sandbox

# Create your local config (edit paths to match your system)
cp .env.example .env
# → Open .env and set WORKSPACE_DIR and HOST_FONTS_DIR

# Build and start the container
podman compose up -d --build

# Open a shell inside the sandbox
podman exec -it antigravity-sandbox bash
```

## Agentic AI Workspace Setup

This project is optimized for collaboration with autonomous AI agents (like Google Antigravity or Claude Code). We use a hybrid infrastructure approach:
The underlying container provides only the bare toolchain (Python, Node.js, sudo). **All project-specific dependencies are installed autonomously by the agent.**

To ensure the agents know how to behave in this repository, the following rules of conduct should be stored in the agent configuration (e.g., `AGENTS.md` in the project root):

### Template for `AGENTS.md`

Copy the following instructions into your agent's configuration file to activate the autonomous workflow:

> **System Permissions & Tooling**
> * You operate in an unprivileged Podman container but have passwordless `sudo` privileges for system tools.
> * If mandatory system packages (e.g., C libraries, `curl`, `jq`) are missing, use `sudo apt-get install -y <package>` to install them autonomously before aborting.
> 
> **Python Dependency Management**
> * This is a Python project. Never modify global Python packages.
> * Before executing code, starting tests, or importing modules, always check if the `.venv` directory exists.
> * If `.venv` does not exist: Create it (`python3 -m venv .venv`), activate it, and install dependencies via `pip install -r requirements.txt`.
> * If you need new external packages for a feature, install them in the virtual environment and immediately add them to `requirements.txt`.
> 
> **Testing & Validation (TDD)**
> * Before marking a task as completed or preparing a Git commit, always run the test suite via `pytest`.
> * If tests fail, analyze the traceback, correct the code, and run the tests again until they are green (Autonomous TDD loop).
> 
> **Architecture & Style**
> * Prefer pure, side-effect-free functions. 
> * Consistently use type hints for all function signatures.

## How to Update the Container

Check and copy download links from [Google Antigravity Download page for Linux](https://antigravity.google/download).

Update download links in [Dockerfile](Dockerfile)

Stop and rebuild the container, forcing all tools to get updated.

```bash
# Stop the container if running
podman compose down

# Renew container, thus updating all tools
podman compose build --no-cache
podman compose up -d --force-recreate
```

## Project Structure

```
.
├── .env.example     # Template — copy to .env and edit
├── .env             # Local config (git-ignored) with your paths
├── Dockerfile       # Container image: Ubuntu 24.04 + Chrome + Antigravity Hub & IDE
├── compose.yaml     # Compose service definition with display & volume mounts
└── README.md
```

## How It Works

### Dockerfile

1. **Base image** — Ubuntu 24.04 with essential tools (`wget`, `curl`, `git`, `fish`).
2. **Google Chrome** — Installed from the official APT repository, used for OAuth redirects.
3. **Antigravity Hub** — Downloaded and extracted to `/opt/antigravity-x86`.
4. **Antigravity IDE** — Downloaded and extracted to `/opt/antigravity-ide`.
5. **`xdg-open` wrapper** — A small script that intercepts URL-open calls, logs the URL to `/tmp/auth-url.log`, and opens it in Chrome with Ozone/Wayland support.

### Podman Compose / Docker Compose

The `compose.yaml` configures:

- **Host networking** (`network_mode: host`) for seamless localhost access.
- **GPU passthrough** via `/dev/dri`.
- **Display forwarding** by mounting the X11/Wayland sockets and setting `DISPLAY` / `WAYLAND_DISPLAY`.
- **Shared volumes** for fonts and the Antigravity working directory.
- **2 GB shared memory** (`shm_size`) for Chrome's rendering.

## Configuration

All user-specific paths are configured through a **`.env`** file (see [`.env.example`](.env.example)).

### `.env` Variables

| Variable | Description | Example |
|---|---|---|
| `WORKSPACE_DIR` | Antigravity workspace directory on the host. Mounted into the container and used as `HOME` and `working_dir`. | `/home/youruser/dev/antigravity` |
| `HOST_FONTS_DIR` | Path to your local fonts directory (mounted read-only). | `/home/youruser/.local/share/fonts` |

```bash
# Copy the template and edit it
cp .env.example .env
```

### Runtime Variables (inherited from host)

These are picked up automatically from your shell environment — no need to set them in `.env`:

| Variable | Purpose |
|---|---|
| `DISPLAY` | X11 display identifier |
| `WAYLAND_DISPLAY` | Wayland display socket name |
| `XDG_RUNTIME_DIR` | Runtime directory for Wayland/D-Bus sockets |

## Troubleshooting

| Issue | Fix |
|---|---|
| GUI apps don't appear | Ensure `DISPLAY` or `WAYLAND_DISPLAY` is set on the host and the corresponding socket is mounted. |
| Chrome crashes | Increase `shm_size` in `compose.yaml` (default is `2gb`). |
| Permission errors on volumes | This setup is optimized for Podman and uses `userns_mode: "keep-id"`. If using Docker, you may need to comment out or remove this line in `compose.yaml` to avoid validation errors, or adjust file ownership. |
| OAuth flow not completing | Inspect `/tmp/auth-url.log` inside the container for intercepted URLs. |

## License

Copyright (C) 2026 Daniel Bachran <daniel@bachran.de>

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Credits

* **Author:** Daniel Bachran <daniel@bachran.de>
* **Development Partner:** Built with the assistance of Antigravity, an AI coding assistant developed by Google DeepMind.

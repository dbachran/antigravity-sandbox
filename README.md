# Antigravity Sandbox

A Docker-based sandbox environment for running **Antigravity Hub** and **Antigravity IDE** inside a container with full GUI support (Wayland / X11).

## Overview

This project packages Antigravity Hub (2.1.4) and Antigravity IDE (2.0.4) into an Ubuntu 24.04 container, forwarding the host's display server so that both applications can render their UIs natively. It also bundles Google Chrome for handling OAuth login flows via a custom `xdg-open` wrapper.

## Prerequisites

| Requirement | Details |
|---|---|
| **Docker / Podman** | With Compose v2 (`docker compose`) |
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
docker compose up -d --build

# Open a shell inside the sandbox
docker exec -it antigravity-sandbox bash
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

### Docker Compose

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
| Permission errors on volumes | Check that `userns_mode: keep-id` is supported by your runtime, or adjust file ownership. |
| OAuth flow not completing | Inspect `/tmp/auth-url.log` inside the container for intercepted URLs. |

## License

This project does not currently include a license. Please add one before distributing.

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

# Build and start the container
docker compose up -d --build

# Open a shell inside the sandbox
docker exec -it antigravity-sandbox bash
```

## Project Structure

```
.
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

Key environment variables are inherited from the host via `compose.yaml`:

| Variable | Purpose |
|---|---|
| `DISPLAY` | X11 display identifier |
| `WAYLAND_DISPLAY` | Wayland display socket name |
| `XDG_RUNTIME_DIR` | Runtime directory for Wayland/D-Bus sockets |
| `HOME` | Set to `/home/g0ph3r/dev/antigravity` inside the container |

> **Tip:** If you need to customise paths, edit the `volumes` and `environment` sections in `compose.yaml`.

## Troubleshooting

| Issue | Fix |
|---|---|
| GUI apps don't appear | Ensure `DISPLAY` or `WAYLAND_DISPLAY` is set on the host and the corresponding socket is mounted. |
| Chrome crashes | Increase `shm_size` in `compose.yaml` (default is `2gb`). |
| Permission errors on volumes | Check that `userns_mode: keep-id` is supported by your runtime, or adjust file ownership. |
| OAuth flow not completing | Inspect `/tmp/auth-url.log` inside the container for intercepted URLs. |

## License

This project does not currently include a license. Please add one before distributing.

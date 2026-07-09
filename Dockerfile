# Copyright (C) 2026 Daniel Bachran <daniel@bachran.de>
# This file is part of Antigravity Sandbox and is licensed under the GPL-3.0 License.
# See LICENSE file in the project root for full license information.

FROM ubuntu:24.04


# Avoid interactive prompts during apt installation
ENV DEBIAN_FRONTEND=noninteractive

# Basic dependencies for downloads and Chrome (incl. sudo to allow agents to install necessary tools themselves)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    gnupg \
    apt-transport-https \
    fish \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Allow default user to run sudo without password
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_ubuntu_nopasswd && \
    chmod 0440 /etc/sudoers.d/99_ubuntu_nopasswd

# Install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Create directories for Antigravity
RUN mkdir -p /opt/antigravity-x86 /opt/antigravity-ide

# Download Antigravity 2.0 and extract
# Note: Adjust the tar command if the file has a different format (e.g. .deb or .zip)
RUN curl -L -o /tmp/ag2.tar.gz https://storage.googleapis.com/antigravity-public/antigravity-hub/2.2.1-5287492581195776/linux-x64/Antigravity.tar.gz \
    && tar -xzf /tmp/ag2.tar.gz -C /opt/antigravity-x86 --strip-components=1 \
    && rm /tmp/ag2.tar.gz

# Download Antigravity IDE and extract
RUN curl -L -o /tmp/ag-ide.tar.gz https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.1.1-6123990880747520/linux-x64/Antigravity%20IDE.tar.gz \
    && tar -xzf /tmp/ag-ide.tar.gz -C /opt/antigravity-ide --strip-components=1 \
    && rm /tmp/ag-ide.tar.gz

# xdg-open Wrapper for Wayland/Chrome to intercept OAuth logins
RUN printf '#!/bin/bash\n\
echo "$1" >> /tmp/auth-url.log\n\
if [ -n "$WAYLAND_DISPLAY" ]; then\n\
    google-chrome --enable-features=UseOzonePlatform --ozone-platform=wayland "$1" &\n\
else\n\
    google-chrome "$1" &\n\
fi\n' > /usr/local/bin/xdg-open \
    && chmod +x /usr/local/bin/xdg-open

# Keep the container running indefinitely to be able to run the GUI tools on demand
CMD ["sleep", "infinity"]

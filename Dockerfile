FROM ubuntu:24.04

# Vermeide interaktive Prompts während der apt-Installation
ENV DEBIAN_FRONTEND=noninteractive

# Grundlegende Abhängigkeiten für Downloads und Chrome
# Erweitert um LaTeX-Pakete (texlive, latexmk)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    gnupg \
    apt-transport-https \
    fish \
    git \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-lang-german \
    latexmk \
    && rm -rf /var/lib/apt/lists/*

# Google Chrome installieren
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Verzeichnisse für Antigravity vorbereiten
RUN mkdir -p /opt/antigravity-x86 /opt/antigravity-ide

# Antigravity 2.0 herunterladen und entpacken
# Hinweis: Passe den tar-Befehl an, falls die Datei ein anderes Format hat (z.B. .deb oder .zip)
RUN curl -L -o /tmp/ag2.tar.gz https://storage.googleapis.com/antigravity-public/antigravity-hub/2.2.1-5287492581195776/linux-x64/Antigravity.tar.gz \
    && tar -xzf /tmp/ag2.tar.gz -C /opt/antigravity-x86 --strip-components=1 \
    && rm /tmp/ag2.tar.gz

# Antigravity IDE herunterladen und entpacken
RUN curl -L -o /tmp/ag-ide.tar.gz https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.1.1-6123990880747520/linux-x64/Antigravity%20IDE.tar.gz \
    && tar -xzf /tmp/ag-ide.tar.gz -C /opt/antigravity-ide --strip-components=1 \
    && rm /tmp/ag-ide.tar.gz

# xdg-open Wrapper für Wayland/Chrome erstellen, um OAuth-Logins abzufangen
RUN printf '#!/bin/bash\n\
echo "$1" >> /tmp/auth-url.log\n\
if [ -n "$WAYLAND_DISPLAY" ]; then\n\
    google-chrome --enable-features=UseOzonePlatform --ozone-platform=wayland "$1" &\n\
else\n\
    google-chrome "$1" &\n\
fi\n' > /usr/local/bin/xdg-open \
    && chmod +x /usr/local/bin/xdg-open

# Standard-Kommando
CMD ["sleep", "infinity"]

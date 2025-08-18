# Base on Node LTS (includes npm)
FROM node:20-slim

# Install deps: sudo, python, git, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo python3 python3-pip git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user 'ubuntu' with sudo privileges
RUN useradd -ms /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Codex CLI globally
RUN npm install -g @openai/codex

# Optional: install Python client libs
RUN pip3 install --no-cache-dir openai tiktoken rich typer

# Set working dir and switch to user
WORKDIR /workspace
USER ubuntu

ENTRYPOINT ["/bin/bash"]

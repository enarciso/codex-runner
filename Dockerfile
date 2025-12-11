# Base on Node LTS (includes npm)
FROM ubuntu:latest

# steps to install docker to make ubuntu:dind
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install deps: sudo, python, git, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    npm sudo python3-full python3-pip git docker-ce docker-ce-cli \
    containerd.io docker-buildx-plugin docker-compose-plugin vim wget \
    iputils-ping dnsutils traceroute netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install Codex CLI globally
RUN npm install -g @openai/codex@0.69.0

# Create non-root user 'ubuntu' with sudo privileges
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add ubuntu to the docker group
RUN usermod -aG docker ubuntu

# Set working dir and switch to user
WORKDIR /workspace
USER ubuntu

ENTRYPOINT ["/usr/bin/bash", "-l", "-c"]

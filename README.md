# Codex Runner

Docker image and docker-compose for running the OpenAI Codex CLI inside a container.

This repository contains a small Ubuntu-based image that installs the `@openai/codex` CLI (via `npm`) and common development tools. It also includes a `docker-compose.yml` to make running the image easier.

**Contents**
- `Dockerfile` — builds the Ubuntu-based image and installs Docker, the Codex CLI, and utilities.
- `docker-compose.yml` — example compose configuration and environment variables.
- `LICENSE` — MIT license.

**Note**: The Docker image is designed to be used interactively. It installs Docker client tooling inside the container; to control host Docker from the container you should mount the Docker socket (see examples below). Mounting the socket grants the container control over your Docker daemon — treat it as a privileged operation.

**Requirements**
- Docker Engine (to build and run the image)
- Docker Compose (or the `docker compose` plugin)
- An OpenAI API key (set via `OPENAI_API_KEY` env var)

**Build the image (manual)**

1. From the repository root run:

```bash
docker build -t enarciso/codex-runner:latest .
```

**Start an interactive container (recommended)**

Mount your project into `/workspace` so you can operate on code from inside the container. The example below also mounts `~/.codex` to persist Codex configuration and `/var/run/docker.sock` to allow the container to control host Docker.

```bash
docker run --rm -it \
  -v "${PWD}":/workspace \
  -v "$HOME/.codex":/home/ubuntu/.codex \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  -e CODEX_MODEL="gpt-5-mini" \
  enarciso/codex-runner:latest bash
```

Inside the running container you can run the Codex CLI:

```bash
codex --help
# or, if you prefer, use npx as a fallback:
npx @openai/codex --help
```

**Run with Docker Compose**

You can use the provided `docker-compose.yml`. Create a small `.env` file next to the compose file with at least your API key:

```ini
# .env
OPENAI_API_KEY=sk-...
CODEX_MODEL=gpt-5-mini
SANDBOX_MODE=danger-full-access
NETWORK_ACCESS=true
MODEL_REASONING_EFFORT=high
MODEL_REASONING_SUMMARY=auto
```

Start the service and build the image (if needed):

```bash
docker compose up --build -d
# or, if you use the older docker-compose binary:
docker-compose up --build -d

# attach or open a shell in the running container:
docker exec -it codex-runner bash
```

To run a one-off `codex` command via Docker without opening a shell:

```bash
docker run --rm -e OPENAI_API_KEY="$OPENAI_API_KEY" enarciso/codex-runner:latest codex --help
```

**Docker-in-Docker / socket notes and security**
- Mounting `/var/run/docker.sock` gives the container direct access to the host Docker daemon — this effectively grants root-equivalent access to the host. Only mount the socket if you trust the container and your local environment.
- Alternatively, you can run a true DinD (Docker-in-Docker) setup with `--privileged` and a dind service, but this is more complex and more dangerous.

**Troubleshooting**
- If `codex` is not found inside the container, check that the global npm installation succeeded: `npm ls -g --depth=0`.
- If you have permission errors on mounted `~/.codex` or your mounted project, run `sudo chown -R $(id -u):$(id -g) <path>` on the host, or mount with appropriate uid/gid.

**Author & License**
- Copyright (c) 2025 Eugene Narciso
- Licensed under the MIT License — see `LICENSE`.

If you want, I can also add a short example `.env.example` or a small wrapper script to simplify running the container. Would you like that?


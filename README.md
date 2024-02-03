# Rust for rv32imce-unknown-none-elf (Docker)

## Requirements

You'll need Docker or podman available on system. podman is pretty easy to setup on Linux so we'll recommend that one: <https://podman.io/docs/installation#installing-on-linux>.

## Building the container image

If you need checkpointing, i.e., if you want to share your container runtime in the GitHub Releases
page, the containers must be created as root. Switch to root using `sudo -i`.

Build the image:

```sh
podman build -t rust-rv32imce -f Dockerfile
```

or

```sh
docker build -t rust-rv32imce -f Dockerfile
```

This may take a duration between 30 minutes to several hours depending on host performance.

## Working with the container

If you need checkpointing, i.e., if you want to share your container runtime in the GitHub Releases
page, the containers must be created as root. Switch to root using `sudo -i`.

```sh
# Boot a container from the image
podman run --name rust-rv32imce -dt rust-rv32imce

# List running containers
podman ps

# Attach
podman exec -it rust-rv32imce /bin/bash

# Stop & remove
podman stop rust-rv32imce
podman rm rust-rv32imce
```

Checkpoint the container to save its full state to disk. Stops the container.

```sh
# Checkpoint the container
podman container checkpoint rust-rv32imce -e /tmp/rust-rv32imce.tar.gz

# Restore
podman container restore <container_id>
podman container restore -i /tmp/checkpoint.tar.gz
```

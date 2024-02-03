# Rust for rv32imce-unknown-none-elf (Docker)

## Requirements

You'll need Docker or podman available on system. podman is pretty easy to setup on Linux so we'll recommend that one: <https://podman.io/docs/installation#installing-on-linux>.

You'll also need around 25 GB of disk space to hold the image (until I've time to optimize it a bit).

## Building the container image

Consider downloading the latest image from the [Releases](https://github.com/soc-hub-fi/rust-rv32imce-docker/releases)  section, as building the image may take several hours.

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

### Saving the image for distribution

```sh
# Create a full replica of the image, distributable over network
podman save rust-rv32imce -o rust-rv32imce.tar.gz

# Load from the image
podman load -i rust-rv32imce.tar.gz
```

## Working with the container

If you need checkpointing, i.e., if you want to create and load container checkpoints, the
containers must be created as root. Switch to root using `sudo -i`.

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

### Creating a container checkpoint

Checkpoint the container to save its current state to disk. Stops the container. Depends on the
image from the localhost so these cannot be transferred over network.

```sh
# Checkpoint the container
podman container checkpoint rust-rv32imce -e rust-rv32imce.tar.gz

# Restore
podman container restore rust-rv32imce
podman container restore -i rust-rv32imce.tar.gz
```

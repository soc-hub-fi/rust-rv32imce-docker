# Rust for rv32imce-unknown-none-elf (Docker)

## Requirements

You'll need Docker or podman available on system. podman is pretty easy to setup on Linux so we'll
recommend that one: <https://podman.io/docs/installation#installing-on-linux>.

You'll also need around 12 GB of disk space to hold the image.

## Quickstart

1. Switch to root (if you need checkpointing)
    * `sudo -i`
1. Build the container image
    * `podman build -t rust-rv32imce -f Dockerfile`
1. Boot a container from the image:
    * `podman run --name rust-rv32imce -dt rust-rv32imc`
1. Attach to the running container and start development
    * `podman exec -it rust-rv32imce /bin/bash`
1. Some tips for development
    1. You might want to start by [generating a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    1. Here's some example code runnable on the rt-ss that you can clone <https://github.com/perlindgren/rust_rve>

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

# List containers
podman ps --all

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

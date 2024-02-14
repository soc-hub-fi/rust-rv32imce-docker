# Rust for rv32emc-unknown-none-elf (Docker)

A Docker container for a Rust compiler targeting rv32{e,i}mc-unknown-none-elf.

## Requirements

You'll need Docker or podman available on system. podman is pretty easy to setup on Linux so we'll
recommend that one: <https://podman.io/docs/installation#installing-on-linux>. You can use `docker`
as a drop-in replacement for `podman`, all commands are interchangeable.

You'll also need around 12 GB of disk space to hold the final image (or ~100 GiB to build it).

## Quickstart

1. Switch to root (if you need checkpointing)
    * `sudo -i`
1. Build the container image
    * `podman build -t rust-rv32emc -f Containerfile`
1. Boot a container from the image:
    * `podman run --name rust-rv32emc -dt rust-rv32emc`
1. Attach to the running container and start development
    * `podman exec -w=/root/ -it rust-rv32emc /bin/bash`
1. Some tips for development
    1. Here's some example code runnable on the rt-ss that you can clone
       <https://github.com/perlindgren/rust_rve>
    1. Once you've built some binaries, copy them over to the host:
        * `podman cp rust-rv32emc:/root/rust_rve/target/riscv32emc-unknown-none-elf .`

## Building the container image

If you need checkpointing, i.e., if you want to share your container runtime in the GitHub Releases
page, the containers must be created as root. Switch to root using `sudo -i`.

The container build requires some several hours from your computer, depending on system specs. If
you need the computer while it builds the container, do limit the number of cores used by the
container build. You will need to know the number of cores on your system:

```sh
# Identify the number of CPU cores on your system
cat /proc/cpuinfo | grep processor | wc -l
```

```sh
# Build the image using only specified cores (pick a number lower than your core count for the higher bound)
podman build -t rust-rv32emc -f Containerfile --cpuset-cpus 0-6

# Build the image without resource limits
podman build -t rust-rv32emc -f Containerfile

# Build a smaller image without any optional extras (e.g., vim, tmux, binutils, openssh)
podman build -t rust-rv32emc -f Containerfile --target minimal
```

This may take a duration between 30 minutes to several hours depending on host performance.

### Saving the image for distribution

```sh
# Create a full replica of the image, distributable over network
podman save rust-rv32emc -o rust-rv32emc.tar.gz

# Load from the image
podman load -i rust-rv32emc.tar.gz
```

## Working with the container

If you need checkpointing, i.e., if you want to create and load container checkpoints, the
containers must be created as root. Switch to root using `sudo -i`.

```sh
# Boot a container from the image
podman run --name rust-rv32emc -dt rust-rv32emc

# List containers
podman ps --all

# Attach
podman exec -it rust-rv32emc /bin/bash

# Copy files from container to host
podman cp rust-rv32emc:/root/file .

# Stop & start (analogous to shutdown & reboot)
podman stop rust-rv32emc
podman start rust-rv32emc

# Remove the container permanently
podman rm rust-rv32emc
```

### Creating a container checkpoint

Checkpoint the container to save its current state to disk. Stops the container. Depends on the
image from the localhost so these cannot be transferred over network.

```sh
# Checkpoint the container
podman container checkpoint rust-rv32emc -e rust-rv32emc.tar.gz

# Restore
podman container restore rust-rv32emc
podman container restore -i rust-rv32emc.tar.gz
```

## Debugging the container

There's a special image for debugging the release image. It is larger because it retains all the
artifacts, but it is similar otherwise.

```sh
# Build the debug container
podman build -t rust-rv32emc-debug -f Containerfile -f debug.Containerfile
```

## Using VS Code with the container

This may require some minor setup. Configure your system based on this guide:
<https://jahed.dev/2023/05/27/remote-development-with-vs-code-podman/>

TL;DR:

1. Add to your VS Code settings: `"dev.containers.dockerPath": "podman"`
2. Make sure the container is running, i.e., `podman run --name rust-rv32emc -dt rust-rv32emc` or `podman start rust-rv32emc`
3. Then `Command Palette` -> `Dev Containers: Attach to Running Container...`. For first time load,
   VS Code will take some time to set up the remote container.

If it doesn't work for you and something else is also required, open an issue and I'll figure it
out.

## Using your SSH keys with the container

With pre-existing SSH keys on the host machine:

* On host: `podman cp ~/.ssh rust-rv32emc:/root/`
* On container: `chmod 600 .ssh/id_ed25519 .ssh/id_ed25519.pub .ssh/config`

## Pushing an image to Docker Hub

```sh
# Build the image to be uploaded
podman build -f Containerfile --target minimal -t $USER/rust-rv32e:$TAG .

# Login to docker.io
podman login --username=$USER docker.io

# Push the image to Docker Hub
podman push $USER/rust-rv32e:$TAG
```

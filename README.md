# Docker container with Rust support for rv32imce-unknown-none-elf

## Requirements

You'll need Docker or podman available on system. podman is pretty easy to setup on Linux so we'll recommend that one: <https://podman.io/docs/installation#installing-on-linux>.

## Building the container image

If you need checkpointing, i.e., if you want to share your container runtime in the GitHub Releases
page, the containers must be created as root. Switch to root using `sudo -i`.

Build the image.

```sh
podman build -t rust-rv32imce -f Dockerfile
```

or

```sh
docker build -t rust-rv32imce -f Dockerfile
```

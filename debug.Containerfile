# A debug image for testing & development
#
# This image is much larger than the release image, and is not intended for end-use
FROM builder AS debug

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Hook the new compiler into rustup
RUN \
  rustup toolchain link rve-stage0 ${RUST}/build/host/stage0-sysroot # beta compiler + stage0 std && \
  rustup toolchain link rve-stage1 ${RUST}/build/host/stage1 && \
  rustup toolchain link rve ${RUST}/build/host/stage2 && \
  rustup default rve

# Add tools for end-user
RUN pacman --noconfirm -Syy \
    binutils \
    git \
    openssh \
    riscv64-linux-gnu-binutils \
    tmux \
    vim

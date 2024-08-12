# Build stage: basic development tools
FROM debian:trixie-slim AS builder

RUN apt-get update
RUN apt install -y \
  git \
  less

# Requirements for RISC-V GCC
RUN apt install -y \
  autoconf \
  automake \
  bc \
  bison \
  bzip2 \
  curl \
  libexpat-dev \
  flex \
  gawk \
  g++ \
  gperf \
  libgmp-dev \
  libmpfr-dev \
  libtool \
  make \
  patchutils \
  python3 \
  texinfo \
  zlib1g-dev

# Clone RISC-V GCC
WORKDIR /root/
RUN git clone --depth=1 --branch 2024.04.12 https://github.com/riscv-collab/riscv-gnu-toolchain

# Build RISC-V cross-compiler
WORKDIR /root/riscv-gnu-toolchain/
ENV RISCV=/opt/riscv/
RUN \
  mkdir ${RISCV} && \
  ./configure --prefix=${RISCV} --with-arch=rv32emc --with-abi=ilp32e
RUN make
ENV PATH="${RISCV}/bin:${PATH}"

# Requirements for LLVM
RUN apt install -y \
  cmake \
  gcc \
  ninja-build \
  python3

# Clone LLVM
WORKDIR /root/
RUN git clone --depth=1 --branch llvmorg-18.1.4 https://github.com/llvm/llvm-project

# Build LLVM
WORKDIR /root/llvm-project/
ENV LLVM=/opt/llvm/
RUN \
  mkdir ${LLVM} && \
  cmake -S llvm -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=${LLVM} \
  -DLLVM_ENABLE_PROJECTS="clang;lld" -DCMAKE_BUILD_TYPE=Release
# This will take some 10 min to few hours depending on the resources available on host
RUN ninja -C build install


FROM builder AS minimal-builder

# Requirements for Rust
RUN apt install -y \
  pkg-config \
  python3

# Clone the Rust compiler
WORKDIR /opt/
RUN \
  git clone --branch 1.77.2 --depth 1 https://github.com/rust-lang/rust && \
  cd rust

# Apply patches & configure Rust for build
WORKDIR /opt/rust/
COPY config.minimal.toml config.toml
COPY patches .
RUN git config --global user.name "$(git --no-pager log --format=format:'%an' -n 1)" && \
  git config --global user.email "$(git --no-pager log --format=format:'%ae' -n 1)" && \
  git am --committer-date-is-author-date *.patch

# Build the Rust compiler
RUN ./x build \
  library \
  src/tools/rust-analyzer \
  src/tools/rust-analyzer/crates/proc-macro-srv-cli \
  src/tools/rustfmt


FROM builder AS devel-builder

# Requirements for Rust
RUN pacman --noconfirm -Syy libiconv pkg-config python3

# Clone the Rust compiler
WORKDIR /opt/
RUN pacman --noconfirm -Syy libiconv pkg-config python3
RUN \
  git clone --single-branch https://github.com/rust-lang/rust && \
  cd rust && \
  git checkout bf3c6c5bed498f41ad815641319a1ad9bcecb8e8

# Apply patch & configure Rust for build
WORKDIR /opt/rust/
COPY 01_riscv32emc_target.patch .
RUN git apply 01_riscv32emc_target.patch
COPY config.devel.toml ./config.toml

# Build the Rust compiler
RUN ./x build library


# A lean image with only what's necessary
FROM debian:trixie-slim AS minimal

RUN apt-get update
RUN apt install -y \
    build-essential

# Copy RISC-V cross-compiler
ENV RISCV=/opt/riscv/
COPY --from=builder ${RISCV} ${RISCV}
ENV PATH="${RISCV}/bin:${PATH}"

# Copy Rust compiler
ENV RUST=/opt/rust/
COPY --from=minimal-builder ${RUST} ${RUST}

# Install rustup
RUN apt install -y \
    curl
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Hook the new compiler into rustup
RUN \
  rustup toolchain link rve-stage0 ${RUST}/build/host/stage0-sysroot && \
  rustup toolchain link rve-stage1 ${RUST}/build/host/stage1 && \
  rustup toolchain link rve ${RUST}/build/host/stage2 && \
  rustup default rve


# A more refined image for further development
FROM docker.io/library/archlinux:base-devel-20240101.0.204074 AS devel

# Copy RISC-V cross-compiler
ENV RISCV=/opt/riscv/
COPY --from=builder ${RISCV} ${RISCV}
ENV PATH="${RISCV}/bin:${PATH}"

# Copy Rust compiler
ENV RUST=/opt/rust/
COPY --from=devel-builder ${RUST} ${RUST}

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Hook the new compiler into rustup
RUN \
  rustup toolchain link rve-stage0 ${RUST}/build/host/stage0-sysroot && \
  rustup toolchain link rve-stage1 ${RUST}/build/host/stage1 && \
  rustup toolchain link rve ${RUST}/build/host/stage2 && \
  rustup default rve

# Add optional tools for end-user
RUN apt-get update
RUN apt install -y \
  binutils \
  git \
  tmux \
  vim \
  zsh

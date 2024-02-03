# Arch Linux with basic development tools
FROM docker.io/library/archlinux:base-devel-20240101.0.204074

RUN pacman --noconfirm -Syy tmux vim git less

# Download RISC-V cross-compiler
WORKDIR /root/
ENV RISCV=/opt/riscv/
RUN \
  mkdir ${RISCV} && \
  curl -LO https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2024.02.02/riscv32-elf-ubuntu-22.04-gcc-nightly-2024.02.02-nightly.tar.gz && \
  tar -xzf riscv32-elf-ubuntu-22.04-gcc-nightly-2024.02.02-nightly.tar.gz -C ${RISCV} --strip-components=1 && \
  rm riscv32-elf-ubuntu-22.04-gcc-nightly-2024.02.02-nightly.tar.gz
ENV PATH="${RISCV}/bin:${PATH}"

# Clone LLVM
RUN git clone --depth=1 --branch llvmorg-18.1.0-rc1 https://github.com/llvm/llvm-project

# Build LLVM
RUN pacman --noconfirm -Syy cmake ninja gcc python3
WORKDIR /root/llvm-project/
ENV LLVM=/opt/llvm/
RUN \
  mkdir ${LLVM} && \
  cmake -S llvm -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=${LLVM} \
  -DLLVM_ENABLE_PROJECTS="clang;lld" -DCMAKE_BUILD_TYPE=Release
# This will take some 10 min to few hours depending on the resources available on host
RUN ninja -C build install

# Clone the Rust compiler
WORKDIR /root/
RUN pacman --noconfirm -Syy libiconv pkg-config
RUN \
  git clone --single-branch https://github.com/rust-lang/rust && \
  cd rust && \
  git checkout bf3c6c5bed498f41ad815641319a1ad9bcecb8e8

# Apply patch & configure Rust for build
WORKDIR /root/rust/
COPY 01_riscv32imce_target.patch .
RUN git apply 01_riscv32imce_target.patch
COPY config.toml .

# Build the Rust compiler
RUN ./x build library

WORKDIR /root/

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Hook the new compiler into rustup
RUN \
  rustup toolchain link rve-stage0 build/host/stage0-sysroot # beta compiler + stage0 std && \
  rustup toolchain link rve-stage1 build/host/stage1 && \
  rustup toolchain link rve build/host/stage2 && \
  rustup default rve

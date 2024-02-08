# Build stage: Arch Linux with basic development tools
FROM docker.io/library/archlinux:base-devel-20240101.0.204074 AS builder

WORKDIR /root/

# Clone RISC-V GCC
RUN git clone --depth=1 --branch 2024.02.02 https://github.com/riscv-collab/riscv-gnu-toolchain
WORKDIR /root/riscv-gnu-toolchain/

# Build RISC-V cross-compiler
RUN pacman --noconfirm -Syy autoconf automake curl python3 libmpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patchutils bc zlib expat
ENV RISCV=/opt/riscv/
RUN \
  mkdir ${RISCV} && \
  ./configure --prefix=${RISCV}
RUN make
ENV PATH="${RISCV}/bin:${PATH}"

# Clone LLVM
RUN git clone --depth=1 --branch llvmorg-18.1.0-rc2 https://github.com/llvm/llvm-project

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
COPY config.toml .

# Build the Rust compiler
RUN ./x build library



# A lean image with only what's necessary
FROM docker.io/library/archlinux:base-devel-20240101.0.204074 as release

# Copy RISC-V cross-compiler
ENV RISCV=/opt/riscv/
COPY --from=builder ${RISCV} ${RISCV}
ENV PATH="${RISCV}/bin:${PATH}"

# Copy Rust compiler
ENV RUST=/opt/rust/
COPY --from=builder ${RUST} ${RUST}

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Hook the new compiler into rustup
RUN \
  rustup toolchain link rve-stage0 ${RUST}/build/host/stage0-sysroot && \
  rustup toolchain link rve-stage1 ${RUST}/build/host/stage1 && \
  rustup toolchain link rve ${RUST}/build/host/stage2 && \
  rustup default rve



# A more refined image for further development
FROM release as release:devel

# Add optional tools for end-user
RUN pacman --noconfirm -Syy \
    binutils \
    git \
    openssh \
    riscv64-linux-gnu-binutils \
    tmux \
    vim

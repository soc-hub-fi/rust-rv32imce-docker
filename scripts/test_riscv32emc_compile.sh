#!/bin/bash
set -euxo pipefail

# Run compilers on container to test that they work

git clone --depth=1 --branch=feat/rve https://github.com/hegza/riscv
cd riscv/riscv-rt

export RUSTFLAGS="-C linker=riscv32-unknown-elf-gcc -C link-arg=-nostartfiles -C link-arg=-Triscv-rt/examples/device.x"
cargo build --target riscv32e-unknown-none-elf --examples
cargo build --target riscv32em-unknown-none-elf --examples
cargo build --target riscv32ec-unknown-none-elf --examples
cargo build --target riscv32emc-unknown-none-elf --examples

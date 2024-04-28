#!/bin/bash

# Run compiler on container to test that it works

git clone --depth=1 --branch=feat/rve https://github.com/hegza/riscv
cd riscv/riscv-rt

RUSTFLAGS="-C linker=riscv32-unknown-elf-gcc -C link-arg=-nostartfiles -C link-arg=-Triscv-rt/examples/device.x" cargo build --target riscv32emc-unknown-none-elf --examples

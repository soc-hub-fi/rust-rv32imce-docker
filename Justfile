build-debug:
    podman build -t rust-rv32e:0.2-debug -f Containerfile -f debug.Containerfile --target debug

build-minimal:
    podman build -t rust-rv32e:0.2-minimal -f Containerfile --target minimal

build-devel:
    podman build -t rust-rv32e:0.2-devel -f Containerfile --target devel

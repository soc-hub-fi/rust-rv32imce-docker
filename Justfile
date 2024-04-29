ver := "0.2"

build-debug:
    #!/usr/bin/env bash
    set -euo pipefail
    tag=rust-rv32e:{{ver}}-debug
    podman build -t ${tag} -f Containerfile -f debug.Containerfile --target debug

build-minimal:
    #!/usr/bin/env bash
    set -euo pipefail
    tag=rust-rv32e:{{ver}}-minimal
    podman build -t ${tag} -f Containerfile --target minimal

build-devel:
    #!/usr/bin/env bash
    set -euo pipefail
    tag=rust-rv32e:{{ver}}-devel
    podman build -t ${tag} -f Containerfile --target devel

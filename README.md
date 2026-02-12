<!-- SPDX-License-Identifier: Apache-2.0 -->
# LamaDist

**A secure, maintainable Yocto/OpenEmbedded distribution for homelab devices**

LamaDist provides a hardened Linux distribution built with Yocto Project for homelab infrastructure, featuring comprehensive security (SELinux, dm-verity, LUKS, TPM), Kubernetes orchestration (k3s), and robust OTA updates (RAUC).

## Features

- 🔒 **Multi-layered Security**: SELinux, dm-verity, IMA/EVM, LUKS encryption, secure boot
- 🚀 **Container-ready**: k3s lightweight Kubernetes for orchestrated workloads
- 🔄 **Atomic Updates**: RAUC-based OTA updates with automatic rollback
- 🖥️ **Multi-platform**: Support for x86_64 Intel systems and ARM SBCs (Orin NX, RK1, SOQuartz)
- 📦 **Reproducible Builds**: KAS-based declarative configuration in Docker containers
- 🎯 **Minimal & Optimized**: Lean system with size-optimized builds (`-Os`)

## Quick Start

### Prerequisites

- Linux system (Ubuntu 22.04+ recommended) or WSL2
- Docker 20.10+ with BuildKit
- 8+ GB RAM, 100+ GB free disk space (SSD recommended)
- mise — polyglot tool version manager and task runner

### Build Your First Image

```bash
# Clone the repository
git clone https://github.com/lamawithonel/lamadist.git
cd lamadist

# Install mise (if not already installed)
curl https://mise.run | sh

# Install tool versions (Python, etc.)
mise install

# Build the container
mise run container

# Build image (this will take 2-6 hours on first build)
mise run build

# Images will be in: build/tmp/deploy/images/genericx86-64/
```

### Supported Hardware (BSPs)

- **x86_64**: Intel-based systems (`mise run build BSP=x86_64`)
- **orin-nx**: NVIDIA Jetson Orin NX (`mise run build BSP=orin-nx`)
- **rk1**: Radxa RK1 (`mise run build BSP=rk1`)
- **soquartz**: Pine64 SOQuartz (`mise run build BSP=soquartz`)

## Documentation

Comprehensive documentation is available in the [`docs/`](docs/) directory:

- **[Development Plan](docs/PLAN.md)** - Phased roadmap and project planning
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture and design
- **[Contributing](docs/CONTRIBUTING.md)** - Contribution guidelines and workflow
- **[Tooling](docs/TOOLING.md)** - Tools, setup, and build system guide

### Key Commands

```bash
mise tasks             # List all available tasks
mise run build         # Build for default BSP (x86_64)
mise run build BSP=rk1 # Build for specific BSP
mise run kash          # Interactive shell in build environment
mise run dump          # Dump KAS configuration
mise run version       # Show build version
```

See [`docs/TOOLING.md`](docs/TOOLING.md) for detailed usage information.

## Project Status

**Current Phase**: Phase 0 - Architecture Documentation + Tooling Baseline

LamaDist is in active development. See [`docs/PLAN.md`](docs/PLAN.md) for the complete development roadmap.

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│              LamaDist System                     │
├─────────────────────────────────────────────────┤
│  User Services | Containers (k3s) | systemd  │
│  ─────────────────────────────────────────────  │
│  Security: SELinux | IMA/EVM | dm-verity | LUKS │
│  ─────────────────────────────────────────────  │
│         Linux Kernel 6.6 LTS                     │
│  ─────────────────────────────────────────────  │
│    Bootloader (systemd-boot / U-Boot)           │
│  ─────────────────────────────────────────────  │
│    Hardware (x86_64 | ARM64)                     │
└─────────────────────────────────────────────────┘
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for detailed architecture information.

## Contributing

Contributions are welcome! Please read [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for:

- Development workflow
- Branch naming and commit message conventions
- Pull request process
- Code review expectations
- Yocto/OE best practices

## Community & Support

- **Issues**: [GitHub Issues](https://github.com/lamawithonel/lamadist/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lamawithonel/lamadist/discussions)
- **Documentation**: [`docs/`](docs/) directory

## Legal Notice

   Copyright 2024 Lucas Yamanishi

   All content licensed under the Apache License, Version 2.0 (the "License");
   you may not use these files except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


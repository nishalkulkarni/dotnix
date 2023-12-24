# dotnix
NixOS System Configuration as a Flake.

## Supported Platforms

### Legion
Lenovo Legion Y540 Laptop

#### Specification
- Intel Core i7-9750H
- NVIDIA GeForce GTX 1660 Ti
- 16 GB (2x 8 GB), DDR4 2666 MHz
- 256 GB M.2 NVMe SSD
- System: x86_64-linux

#### Build
```bash
sudo nixos-rebuild switch --flake .#legion
```

### Gisela
Cloud Arm VPS

#### Specification
- Shared vCPU 2 Ampere Cores
- 4 GB RAM
- 40 GB NVMe SSD
- System: aarch64-linux

#### Build
```bash
sudo nixos-rebuild switch --flake .#gisela
```

### Isar
Raspberry Pi 3 Model B+

#### Specification
- Broadcom BCM2837B0, Cortex-A53 (ARMv8) 64-bit SoC
- 1 GB LPDDR2 SDRAM
- 16 GB SD Card
- System: aarch64-linux

#### Build
```bash
# Create installer image
nix build .#nixosConfigurations.rPiImage.config.system.build.sdImage
# Setup RPi
sudo nixos-rebuild switch --flake .#isar
```

## Helper Commands

### Update and Upgrade
```bash
sudo nix flake update
sudo nixos-rebuild switch --flake .#legion
nix-channel --update
sudo nixos-rebuild --upgrade
```

### Garbage Collection
```bash
nix-collect-garbage
nix-env --delete-generations 14d
nix-store --gc
```

## TODO
- Refactor how home-manager packages are installed. Currently GUI applications are installed for all systems (not-desirable).
- Add docker support.
- Setup git using home-manager.
- Add support for multiple architectures in devshells.
- Create a separate mediastation trait. Don't install those packages in workstation.
- Move home-manager config options out of base.nix

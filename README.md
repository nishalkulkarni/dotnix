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


## Helper Commands

### Update and Upgrade
```bash
nix-channel --update
sudo nixos-rebuild --upgrade
```

### Garbage Collection
```bash
nix-collect-garbage
nix-env --delete-generations 14d
nix-store --gc
```
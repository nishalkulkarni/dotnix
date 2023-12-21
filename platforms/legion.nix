{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];
    boot.supportedFilesystems = [ "ntfs" ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/22c82bfc-99b2-4437-b1b5-516015c662e0";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/E0DF-0754";
        fsType = "vfat";
      };

    swapDevices = [ ];

    # Bluetooth Fast Connect Support
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          FastConnectable = true;
        };
        Policy = {
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,3,4,8";
        };
      };
    };

    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Make sure opengl is enabled
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # NVIDIA drivers are unfree.
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
      ];

    # Tell Xorg to use the nvidia driver
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {

      # Modesetting is needed for most wayland compositors
      modesetting.enable = true;

      # Use the open source version of the kernel module
      # Only available on driver 515.43.04+
      open = true;

      # Enable the nvidia settings menu
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    networking.hostName = "legion";
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
  };
}

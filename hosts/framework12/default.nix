{
  hostCfg,
  lib,
  config,
  ...
}:

{
  imports = [
    ./disko.nix
    ../../modules/nixos/common.nix
  ];

  networking.hostName = hostCfg.hostName;

  # Hardware config from original hardware-configuration.nix
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

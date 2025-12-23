{
  hostCfg,
  modulesPath,
  ...
}:

{
  imports = [
    ./disko.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/nixos/common.nix
  ];

  networking.hostName = hostCfg.hostName;

  # UTM with Apple Virtualization Framework: enable Rosetta for x86_64 binary support
  virtualisation.rosetta.enable = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "usbhid"
    "virtiofs"
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
}

{
  hostCfg,
  modulesPath,
  ...
}:

{
  imports = [
    ./disko.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/system/core.nix
    ../../modules/system/greetd.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/power.nix
    ../../modules/system/stylix.nix
  ];

  services.libinput.enable = true;

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

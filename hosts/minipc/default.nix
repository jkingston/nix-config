{
  hostCfg,
  ...
}:

{
  imports = [
    ./disko.nix
    ../../modules/system/core.nix
    ../../modules/system/greetd.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/power.nix
    ../../modules/system/stylix.nix
  ];

  services.libinput.enable = true;

  networking.hostName = hostCfg.hostName;

  # AMD-specific firmware and microcode
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}

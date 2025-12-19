{
  hostCfg,
  username,
  ...
}:

{
  imports = [
    ./disko.nix
    ../../modules/nixos/common.nix
  ];

  networking.hostName = hostCfg.hostName;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "render"
    ];
  };

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

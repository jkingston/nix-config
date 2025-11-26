{
  config,
  pkgs,
  stylix,
  hostCfg,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
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
      "input"
    ];
  };

  # Framework-12 specific quirks (if any)
  # e.g. special kernel params, power tweaks, etc.
}

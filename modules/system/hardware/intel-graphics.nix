{ pkgs, ... }:

{
  # Intel Xe Graphics (Framework 13th gen and similar)
  # Early KMS for high-resolution Plymouth
  boot.initrd.kernelModules = [ "i915" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD driver)
      vpl-gpu-rt # QSV runtime
      intel-compute-runtime # OpenCL
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
}

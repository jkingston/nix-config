{ ... }:

{
  # Early KMS for high-resolution Plymouth
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics.enable = true;
  # Mesa handles VAAPI automatically for AMD - no extra packages needed
  # Unlike Intel, no LIBVA_DRIVER_NAME override required
}

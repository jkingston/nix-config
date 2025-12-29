# Audio configuration - PipeWire with ALSA and PulseAudio compatibility
_:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}

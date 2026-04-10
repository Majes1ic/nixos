{ username, ... }:
{
  hardware.bluetooth.enable = true;
  # hardware.pulseaudio.enable = lib.mkForce false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Joshua: rtkit sucks and this allows Hyprland to acquire round robin
  # scheduling policy.
  security.rtkit.enable = false;
  users.users.${username}.extraGroups = [ "pipewire" ];
}

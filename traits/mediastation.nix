{ pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      ffmpeg
      gimp
      handbrake
      spotify
      vlc
    ];
  };
}

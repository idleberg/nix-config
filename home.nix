{ lib, pkgs, ... }: {
  home = {
    packages = with pkgs; [ hello ];

    # This needs to actually be set to your username
    username = "jan";
    homeDirectory = "/home/jan";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.11";
  };
}

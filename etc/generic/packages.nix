{ pkgs, ... }:
{
  # System overlays
  nixpkgs.overlays = let
    dir = ../../home/nixpkgs/.config/nixpkgs/overlays;
    names = builtins.attrNames (builtins.readDir dir);
  in
    (map (name: import (dir + "/${name}")) names);

  # More involved programs
  programs = {
    adb.enable = true;
    dconf.enable = true;
    slock.enable = true;
    bash = {
      enableCompletion = true;
      interactiveShellInit = ''
        source "${pkgs.autojump}/share/autojump/autojump.bash"
        eval "$("${pkgs.direnv}/bin/direnv" hook bash)"
      '';
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      promptInit = "";
      interactiveShellInit = ''
        source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
        source "${pkgs.autojump}/share/autojump/autojump.zsh"
        eval "$("${pkgs.direnv}/bin/direnv" hook zsh)"
      '';
    };
  };
  virtualisation = {
    docker = {
      enable           = true;
      autoPrune.enable = true;
      storageDriver    = "zfs";
    };
    libvirtd.enable = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # Graphical - WM
    compton
    dmenu
    dunst
    feh
    j4-dmenu-desktop
    networkmanagerapplet

    # Graphical
    emacs
    firefox
    gnome3.zenity
    kitty
    polybar
    virtmanager
    xfce.xfce4-power-manager

    # Command line
    direnv
    tmux

    # Must have utils
    autojump
    bc
    bind
    binutils
    efibootmgr
    file
    gist
    git
    gnupg
    htop
    httpie
    manpages
    mosh
    ncdu
    nix-index
    patchelf
    pciutils
    socat
    trash-cli
    unzip
    wget
    xclip
    xdotool
    zip

    # Daemons
    udiskie
  ];
}

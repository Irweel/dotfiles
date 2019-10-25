{ pkgs }:

# Most of my installed applications are nowadays installed through
# here. The line between what I want as a "system package" and a "user
# package" is incredibly blurry, but I am currently going with the
# following definition:

# Can I live without it temporarily, should I need to debug my user
# config or log in as a different user?
# Answer is "preferrably no"? It's a system package.

let
  unstable = import <nixos-unstable> {};

  reminder = ''

      If it doesn't seem to work, make sure the remote's sshd_config
      specifies "GatewayPorts" to either "yes" or "clientspecified".
  '';
  forward = let
    usage = "forward <remote> <port>";
  in pkgs.writeShellScriptBin "forward" ''
      : "''${1:?${usage}}"
      : "''${2:?${usage}}"
      cat <<-EOF
      Remote port being forwarded over SSH!
      ${reminder}
      EOF

      ssh "$1" -R ":''${2}:localhost:$2" -- sleep infinity
  '';
  backward = let
    usage = "backward <remote> <port>";
  in pkgs.writeShellScriptBin "backward" ''
      : "''${1:?${usage}}"
      : "''${2:?${usage}}"
      cat <<-EOF
      Local port being forwarded to a remote application over SSH!
      ${reminder}
      EOF

      ssh "$1" -L ":''${2}:localhost:$2" -- sleep infinity
  '';
in
  # Convenient bash aliases
  [
    forward
    backward
  ]

  ++

  # Unstable packages
  (with unstable; [
  ])

  ++

  # Stable packages
  (with pkgs; [
    # Local overlays
    clangd

    # My software
    powerline-rs
    termplay
    (callPackage (builtins.fetchTarball https://gitlab.com/jD91mZM2/xidlehook/-/archive/master.tar.gz) {})

    # Graphical applications
    abiword
    firefox
    chromium
    gimp
    olive-editor # <- THIS IS AMAZING
    inkscape
    keepassxc
    liferea
    maim
    mpv
    multimc
    musescore
    obs-studio
    pavucontrol
    thunderbird
    tigervnc
    torbrowser
    xorg.xev
    xorg.xwininfo
    superTuxKart

    # Must have utils
    ascii
    asciinema
    cdrkit
    ctags
    docker_compose
    fd
    ffmpeg
    figlet
    gitAndTools.hub
    ncftp
    neofetch
    nixops
    pv
    rclone
    rename
    ripgrep
    sqlite
    tree
    units
    weechat
    just
    youtube-dl

    # Nix stuff
    (import (builtins.fetchTarball https://cachix.org/api/v1/install) {}).cachix
    (import (builtins.fetchTarball https://github.com/kolloch/crate2nix/archive/master.tar.gz) {})
    (import (builtins.fetchTarball https://github.com/nix-community/pypi2nix/archive/master.tar.gz) {})
    nix-review

    # Languages
    cabal-install
    cargo-edit
    cargo-release
    cargo-tree
    cmake
    gcc
    gdb
    ghc
    gnumake
    go
    gotools
    nodejs
    (python3.withPackages (p: with p; [
      python-language-server
      tkinter
    ]))
    # ruby
    rustup
    sbcl

    # LaTeX stuff
    okular
    poppler_utils
    texlive.combined.scheme-full
  ])

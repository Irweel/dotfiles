{ pkgs, ... }:

let
  shared = pkgs.callPackage <dotfiles/shared> {};
in {
  #  _____ _     ____
  # |_   _| |   / ___|
  #   | | | |   \___ \
  #   | | | |___ ___) |
  #   |_| |_____|____/

  security.acme = {
    # for testing certificates, toggle comment below:
    # production = false;

    certs."krake.one" = {
      email = shared.consts.email;
      webroot = "/var/www/challenges";
      postRun = ''
        systemctl reload nginx
      '';
      extraDomains = {
        "vault.krake.one" = null;
        "redox-os.club" = null;
      };
    };
    certs."mail.krake.one" = {
      email = shared.consts.email;
      webroot = "/var/www/challenges";

      # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/blob/v2.2.1/mail-server/nginx.nix#L39-41
      postRun = ''
        systemctl reload nginx
        systemctl reload postfix
        systemctl reload dovecot2
      '';
    };
  };

  #  __  __       _
  # |  \/  | __ _(_)_ __    ___  ___ _ ____   _____ _ __
  # | |\/| |/ _` | | '_ \  / __|/ _ \ '__\ \ / / _ \ '__|
  # | |  | | (_| | | | | | \__ \  __/ |   \ V /  __/ |
  # |_|  |_|\__,_|_|_| |_| |___/\___|_|    \_/ \___|_|

  services.nginx = {
    enable                   = true;
    recommendedGzipSettings  = true;
    recommendedOptimisation  = true;
    recommendedProxySettings = true;
    recommendedTlsSettings   = true;

    virtualHosts = {
      "krake.one" = {
        useACMEHost = "krake.one";
        acmeRoot    = "/var/www/challenges";
        forceSSL    = true;

        default = true;
        locations."/" = {
          extraConfig = ''
            return 302 https://jd91mzm2.github.io/;
          '';
        };
      };
      "krake.one:1337" = {
        useACMEHost = "krake.one";
        serverName  = "krake.one";
        onlySSL     = true;

        listen = [{
          addr = "0.0.0.0";
          port = 1337;
          ssl  = true;
        }];
        locations."/" = {
          root = "/var/www/public";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
      "mail.krake.one" = {
        useACMEHost = "mail.krake.one";
        acmeRoot    = "/var/www/challenges";
        forceSSL    = true;
      };
      "vault.krake.one" = {
        useACMEHost = "krake.one";
        acmeRoot    = "/var/www/challenges";
        forceSSL    = true;

        locations."/" = {
          proxyPass = "http://localhost:27057";
        };
      };
      "krake.one:11694" = {
        listen = [{
          # Domain only accessible from TOR
          addr = "127.0.0.1";
          port = 11694;
        }];
        locations."/" = {
          extraConfig = ''
            return 302 https://www.youtube.com/watch?v=dQw4w9WgXcQ;
          '';
        };
      };
      "redox-os.club" = {
        useACMEHost = "krake.one";
        acmeRoot    = "/var/www/challenges";
        forceSSL    = true;

        locations."/" = {
          proxyPass = "http://localhost:22165";
          extraConfig = ''
            error_page 502 /drop/502.html;
          '';
        };
        locations."/drop" = {
          proxyPass = "https://krake.one:1337/";
          extraConfig = ''
            internal;
          '';
        };
      };
    };
  };

  #   ___  _   _
  #  / _ \| |_| |__   ___ _ __
  # | | | | __| '_ \ / _ \ '__|
  # | |_| | |_| | | |  __/ |
  #  \___/ \__|_| |_|\___|_|

  services.tor = {
    enable = true;
    hiddenServices."rickroll".map = [
      { port = 80; toPort = 11694; }
    ];
  };
}

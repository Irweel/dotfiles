{ pkgs, lib, ... }:

let
  shared = pkgs.callPackage <dotfiles/shared> {};
in
{
  services.znc = {
    enable = true;
    useLegacyConfig = false;

    # Modules such as SASL are handled using a separate config, and
    # should be mutable anyway :)
    mutable = false;

    config = {
      LoadModule = [ "webadmin" "adminlog" ];
      Listener.l = {
        Port = 5000;
        IPv4 = true;
        IPv6 = true;
        SSL  = true;
      };
      User."${shared.consts.name}" = {
        Admin = true;
        Nick = shared.consts.name;
        AltNick = shared.consts.name + "_";
        LoadModule = [ "chansaver" "controlpanel" ];
        Network = let
          createZncServers = servers:
            lib.mapAttrs
              (_name: cfg: {
                Server = "${cfg.ip} +6697";
                LoadModule = [ "simple_away" "sasl" "keepnick" ];
                Chan = lib.listToAttrs (
                  map
                    (name: lib.nameValuePair name {})
                    cfg.chan
                );
              })
              servers;
        in
          createZncServers {
            freenode = {
              ip = "chat.freenode.net";
              chan = [ "#nixos" "#nixos-chat" "#nix-community" ];
            };
            mozilla = {
              ip = "irc.mozilla.org";
              chan = [ "#rust" ];
            };
          };
        Pass.password = shared.consts.secret.zncPassBlock;
      };
    };
  };
}

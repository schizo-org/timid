{
  inputs,
  pkgs,
  ...
}: let
  inherit (builtins) toFile toJSON;
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  policies = toFile "schizo.json" <| toJSON <| import ./policies.nix;

in
  mkNixPak {
    config = {sloth, ...}: {
      app.package = pkgs.callPackage ../nix/package.nix {};
      app.binPath = "bin/timid";

      flatpak.appId = "org.timid.Timid";

      gpu.enable = true;
      gpu.provider = "bundle";
      fonts.enable = true;
      locale.enable = true;

      bubblewrap = {
        bind.rw = [
          (sloth.concat' sloth.homeDir "Downloads")
          "/tmp/brave.dev"
          (sloth.concat [
            (sloth.env "XDG_RUNTIME_DIR")
            "/"
            (sloth.envOr "WAYLAND_DISPLAY" "no")
          ])
          [
            (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/timid"))
            (sloth.concat' sloth.homeDir "/.config/BraveSoftware/Brave-Browser")
          ]
        ];

        bind.ro = [
          "/etc/resolv.conf"

          "/etc/localtime"
          "/etc/fonts"
          "/sys/bus/pci"
          "/run/dbus/system_bus_socket"
          "/run/opengl-driver"

          ["${policies}" "/etc/brave/policies/managed/schizo.json"]
        ];
      };
    };
  }

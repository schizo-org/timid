{
  inputs,
  pkgs,
  policyList ? (import ../modules/policies.nix),
  ...
}:
let
  inherit (pkgs) lib;
  inherit (builtins) toFile toJSON;
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  policies = toFile "schizo.json" <| builtins.trace policyList <| toJSON <| policyList;
  appId = "com.brave.Browser";
in
mkNixPak {
  config =
    { sloth, ... }:
    {
      app.package = pkgs.callPackage ../nix/package.nix { };
      app.binPath = "bin/timid";

      flatpak = {
        inherit appId;
      };
      gpu.enable = true;
      gpu.provider = "nixos";
      fonts.enable = true;
      locale.enable = true;
      etc.sslCertificates.enable = true;

      dbus.enable = false;
      dbus.policies = {
        "${appId}" = "own";
        "${appId}.*" = "own";

        "org.gnome.SessionManager" = "talk";
        "org.freedesktop.ScreenSaver" = "talk";
        "org.freedesktop.Notifications" = "talk";

        "org.freedesktop.portal.FileChooser" = "talk";
        "org.freedesktop.portal.Settings" = "talk";

        "org.freedesktop.DBus.*" = "talk";
        "org.freedesktop.NetworkManager" = "talk";
        "org.freedesktop.FileManager1" = "talk";

        "org.freedesktop.DBus" = "talk";
        "org.gtk.vfs.*" = "talk";
        "org.gtk.vfs" = "talk";
        "ca.desrt.dconf" = "talk";
        "org.freedesktop.portal.*" = "talk";
        "org.a11y.Bus" = "talk";
        "org.freedesktop.*" = "talk";
      };

      bubblewrap = {
        network = true;
        sockets = {
          wayland = true;
          pipewire = true;
          pulse = true;
        };
        bind.rw = [
          (sloth.concat' sloth.homeDir "/Downloads")

          [
            (sloth.mkdir (
              sloth.concat [
                sloth.appDataDir
                "/profile"
              ]
            ))
            (sloth.concat [
              sloth.xdgConfigHome
              "/chromium"
            ])
          ]
          [
            (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/timid"))
            (sloth.concat' sloth.homeDir "/.config/BraveSoftware/Brave-Browser")
          ]

          (sloth.concat' sloth.xdgCacheHome "/fontconfig")
          (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
          (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache_db")
          (sloth.concat' sloth.xdgCacheHome "/radv_builtin_shaders")

          (sloth.concat' sloth.runtimeDir "/at-spi/bus")
          (sloth.concat' sloth.runtimeDir "/gvfsd")
          (sloth.concat' sloth.runtimeDir "/dconf")
          (sloth.concat' sloth.runtimeDir "/doc")
          (sloth.concat' sloth.runtimeDir "/bus")
          (sloth.concat' sloth.runtimeDir "/pipewire-0")

          "/run/dbus/system_bus_socket"
          "/etc/resolv.conf"
          "/etc/localtime"
          "/sys/bus/pci"
          "/tmp"
          "/run/opengl-driver"
          "/run/dbus"
        ];

        bind.ro = [
          [
            "${policies}"

            "/etc/brave/policies/managed/schizo.json"
          ]

          (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
          (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
          (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
          (sloth.concat' sloth.xdgConfigHome "/fontconfig")
          (sloth.concat' sloth.xdgConfigHome "/dconf")

          "/etc/xdg/gtk-2.0"
          "/etc/xdg/gtk-3.0"
          "/etc/xdg/gtk-4.0"
          "/usr/share/mime"
           
          # FIXME: get rid of this

          "/etc/egl"
          "/etc/static"
           
        ];
        bind.dev = [
          "/dev/dri"
          "/dev/shm"
          "/dev/mem"
          "/dev"
        ];

        env = {
          XDG_DATA_DIRS = lib.makeSearchPath "share" [
            pkgs.shared-mime-info
            pkgs.adwaita-icon-theme
            pkgs.hicolor-icon-theme
            pkgs.egl-wayland
            "${pkgs.addDriverRunpath.driverLink}/share"
          ];
          XCURSOR_PATH = lib.concatStringsSep ":" [
            "${pkgs.adwaita-icon-theme}/share/icons"
            "${pkgs.adwaita-icon-theme}/share/pixmaps"
          ];
          # LD_LIBRARY_PATH = lib.makeLibraryPath [
          #   pkgs.libGL
          # ];
        };
      };
    };
}

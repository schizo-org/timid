{
  description = "";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    eachSystem = lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];
    pkgsFor = inputs.nixpkgs.legacyPackages;
  in {
    formatter = eachSystem (system: pkgsFor.${system}.alejandra);

    packages = eachSystem (system: let
      pkgs = pkgsFor.${system};
      timid = import ./nix/timid.nix {inherit inputs pkgs;};
    in {
      default = inputs.self.packages.${system}.timid;

      timid = timid.config.env;

      timid-unwrapped = pkgs.callPackage ./nix/package.nix {};
    });
    apps = eachSystem (system: {
      default = inputs.self.apps.${system}.timid;
      timid = {
        type = "app";
        program = "${inputs.self.packages.${system}.default}/bin/timid";
      };
      timid-unwrapped = {
        type = "app";
        program = "${inputs.self.packages.${system}.timid-unwrapped}/bin/timid";
      };
    });
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options)
    mkOption
    mkEnableOption
    mkPackageOption
    literalExpression
    ;
  inherit (lib.types)
    listOf
    string
    ;
  defaultPolicies = import ./policies.nix;
  cfg = config.programs.timid;
in
{
  options = {
    programs.timid = {
      enable = mkEnableOption "Enable Timid, a privacy-conscious browser.";
      package = mkPackageOption pkgs "brave" {
        example = "brave";
      };
      settings = {
        extensions = mkOption {
          type = listOf string;
          default = [ ];
          example = literalExpression ''
            [
              # NoScript
              "doojmbjmlfjjnbmnoijecmcbfeoakpjm"
              # KeePassXC-Browser
              "oboonakemofpalcgghocfoadofidjkkk"
              # Catppuccin Mocha
              "bkkmolkhemgaeaeggcmfbghljjjoofoh"
              # Dark Reader
              "eimadpbcbfnmbkopoojfekhnkhdbieeh"
              # UBlock Origin
              "cjpalhdlnbpafiamejdnhcphjbkeiagm"
              # I still don't care about cookies
              "edibdbjcniadpccecjdfdjjppcpchdlm"
              # Sponsorblock
              "mnjggcdmjocbbbhaepdhchncahnbgone"
              # Decentraleyes
              "ldpochfccmkkmhdbclfhpagapcfdljkj"
            ]
          '';
          description = ''
            A list of of extension IDs to be installed by default.

            ::: {.note}

            You can add new extensions by their Chrome web-store ID. For example
            the URL of UBlock Origin Lite is as follows:

            `https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh`

            and if you take the last part, `ddkjiahejlhfcafbddmgiahcphecmpfh` you
            will have the extension ID.

            :::
          '';
        };
      };

    };

  };

  config =
    let
      policyList = defaultPolicies // {
        ExtensionInstallForcelist = cfg.settings.extensions;
      };
      timid = import ../nix/timid.nix {
        inherit policyList;
      };
    in
    {
      environment.systemPackages = [ timid ];
    };
}

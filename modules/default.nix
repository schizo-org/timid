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
          description = ''
            List of extensions to be installed.

            You can add new extensions by their chrome web-store ID.
            For example, the url of Ublock Origin Lite is:
            https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh
            Take the last part, `ddkjiahejlhfcafbddmgiahcphecmpfh` and
            you have the ID of the extension.
          '';
          example = literalExpression ''
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

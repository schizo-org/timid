
{ stdenv, callPackage, ... }@args:
let
  pname = "timid";
  version = "1.80.120";

  allArchives = {
    aarch64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_arm64.deb";
      hash = "sha256-BicdZFFU8MmBpkl6F0tf0aR0t4dfEI8QQS/gCBlye8w=";
    };
    x86_64-linux = {
      url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser_${version}_amd64.deb";
      hash = "sha256-RgJK9Q60hTBcxaA2B0UuwJrDtw1zqXnm/IZKiu1XcZg=";
    };
  };
  archive = allArchives.${stdenv.system};
in
  callPackage ./make-brave.nix (removeAttrs args ["callPackage"]) (
    archive
    // {
      inherit pname version;
    }
  )

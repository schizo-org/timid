#! /usr/bin/env nu

print $"Working directory: ($env.FILE_PWD)"

let tag_name = http get "https://api.github.com/repos/brave/brave-browser/releases/latest"
| get tag_name
| str trim --left --char 'v'


print $"Latest tag: ($tag_name)\n"

def getHash [arch] {
  nix-prefetch-url --type sha256 $"https://github.com/brave/brave-browser/releases/download/v($tag_name)/brave-browser_($tag_name)_($arch).deb" e> /dev/null
}

let hashAmd64 = getHash amd64 | nix-hash --to-sri --type sha256 $in
let hashArm64 = getHash arm64 | nix-hash --to-sri --type sha256 $in

print $"Amd64 hash: ($hashAmd64)"
print $"Arm64 hash: ($hashArm64)"



let fileContent = $"
{ stdenv, callPackage, ... }@args:
let
  pname = \"timid\";
  version = \"($tag_name)\";

  allArchives = {
    aarch64-linux = {
      url = \"https://github.com/brave/brave-browser/releases/download/v\${version}/brave-browser_${version}_arm64.deb\";
      hash = \"($hashArm64)\";
    };
    x86_64-linux = {
      url = \"https://github.com/brave/brave-browser/releases/download/v\${version}/brave-browser_${version}_amd64.deb\";
      hash = \"($hashAmd64)\";
    };
  };
  archive = allArchives.${stdenv.system};
in
  callPackage ./make-brave.nix \(removeAttrs args ["callPackage"]) \(
    archive
    // {
      inherit pname version;
    }
  )
"

let packageFile = $env.FILE_PWD | path join package.nix

print 
print $"Writing new content to ($packageFile)."

$fileContent | save -f $packageFile

print "Written new package to package.nix successfully!"

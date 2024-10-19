{ lib, nixpkgs, callPackage, zip }:
let
  fetchNupkg = callPackage "${nixpkgs}/pkgs/build-support/dotnet/fetch-nupkg" {
    nugetPackageHook = callPackage "${nixpkgs}/pkgs/development/compilers/dotnet/nuget-package-hook.nix" {};
    patchNupkgs = callPackage "${nixpkgs}/pkgs/development/compilers/dotnet/patch-nupkgs.nix" {};
  };
  overrideNupkgToRemoveSignature = nupkg:
    nupkg.overrideAttrs (prevNupkg: {
      src = prevNupkg.src.overrideAttrs {
        downloadToTemp = true;
        postFetch = ''
          mv $downloadedFile file.zip
          ${zip}/bin/zip -d file.zip ".signature.p7s" || true
          mv file.zip $out
        '';
      };
    });
in
# TODO: Read NuGet.Config for url resolving
{ packagesLockJson, resolveUrl ? (_: null) }:
  let
    getExternalDeps = packagesLock:
      let
        allDeps' = builtins.foldl' (a: b: a // b) { } (builtins.attrValues packagesLock.dependencies);
        allDeps = map (name: { inherit name; } // (builtins.getAttr name allDeps')) (builtins.attrNames allDeps');
      in
      builtins.filter (dep: (builtins.hasAttr "contentHash" dep) && (builtins.hasAttr "resolved" dep)) allDeps;
    externalDeps = getExternalDeps (builtins.fromJSON (builtins.readFile packagesLockJson));
    nugetDeps = { fetchNuGet }:
      lib.pipe externalDeps [
        (builtins.map (dep:
          let url = resolveUrl dep; in
          fetchNuGet ({
            pname = dep.name;
            version = dep.resolved;
            hash = "sha512-${dep.contentHash}";
          } // lib.optionalAttrs (url != null) { inherit url; })
        ))
        (builtins.map overrideNupkgToRemoveSignature)
      ];
  in
  nugetDeps { fetchNuGet = fetchNupkg; }

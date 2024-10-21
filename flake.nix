{
  description = "nuget-packages-lock2nuget-deps";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }: {
    lib = {
      nugetPackagesLockToNugetDeps =
        nixpkgs.lib.trivial.mirrorFunctionArgs
          (import ./nuget-packages-lock-to-nuget-deps.nix)
          (attrs:
            (import ./nuget-packages-lock-to-nuget-deps.nix) attrs { inherit nixpkgs; }
          );
    };
  };
}

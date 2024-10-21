{
  description = "nuget-packages-lock2nuget-deps";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { ... }: {
    lib = {
      nugetPackagesLockToNugetDeps = import ./nuget-packages-lock-to-nuget-deps.nix;
    };
  };
}

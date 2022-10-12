{
  description = "papi";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }: rec {

    packages.x86_64-linux.papi = nixpkgs.legacyPackages.x86_64-linux.papi.overrideAttrs (oldAttrs: { src = self; } );

    packages.x86_64-linux.default = self.packages.x86_64-linux.papi;

  };
}

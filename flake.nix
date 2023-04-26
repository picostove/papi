{
  description = "papi";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    version = "7.0.1-g${self.shortRev or "dirty"}";
    # System types to support.
    supportedSystems = [
      "riscv64-linux"
      "x86_64-linux"
    ];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;

        overlays = [
          self.overlays.default
        ];
      });
  in rec {
    overlays.default = final: prev: {
      papi = prev.papi.overrideAttrs (oldAttrs: {
        inherit version;
        src = self;
        configureFlags = (oldAttrs.configureFlags or []) ++ [
          "--with-ffsll"
          "--with-walltimer=clock_realtime"
          "--with-tls=__thread"
          "--with-virtualtimer=clock_thread_cputime_id"
        ];
      });
    };

    packages = forAllSystems (system: let
      papi = (nixpkgsFor.${system}).papi;
    in {
      inherit papi;
      default = papi;
    });
  };
}

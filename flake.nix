{
  description = "Home Manager configuration of chloe";
  nixConfig = {
    extra-trusted-substituters = ["https://cache.flox.dev"];
    extra-trusted-public-keys = ["flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="];
  };
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    #Solaar-Flake.url = "https://flakehub.com/f/Svenum/Solaar-Flake/0.1.2.tar.gz";
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    flox.url = "github:flox/flox/v1.4.4";

    nixgl.url = "github:nix-community/nixGL";
    # Snowfall Lib is not required, but will make configuration easier for you.
    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs-unstable";

    snowfall-flake.url = "github:snowfallorg/flake";
    snowfall-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {self, ...}: {
    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit inputs;
        system = "${system}";
        overlays = with inputs; [
          # when installing packages it’s then possible to use pkgs.unstable.foobar-some-package
          (final: prev: {
            unstable = import nixpkgs-unstable {
              system = prev.system;
            };
          })
          # nixGL overlay is required for opengl programs from nixpkgs to run on non-nixos linux
          nixgl.overlay
          (final: prev: {
            flox = flox.packages.${prev.system}.default;
            snowfallorg.flakes = snowfall-flake.packages.${prev.system}.default;
          })
        ];
      };
    in {
      inherit inputs pkgs;

      # TODO: reduce repeated code by recursing over each user of each hostname and user.
      #   Available through 'home-manager --flake .#your-username@your-hostname'
      "chloe@queenkpad" = with inputs;
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
          modules = [
            ./home/home.nix
            ./home/path.nix
            ./home/shell.nix
            ./home/user.nix
            ./home/aliases.nix
            ./home/programs.nix
            ./home/packages.nix
            ./home/files.nix

            nix-index-database.hmModules.nix-index
            # optional to also wrap and install comma
            {programs.nix-index-database.comma.enable = true;}

            # Host Specific configs
            ./home/hosts/queenkpad/chloe.nix
            ./home/hosts/queenkpad/custom.nix

            {home.packages = [];}
            {nixpkgs.overlays = pkgs.overlays;}
          ];
        };
      "chloe@ombre" = with inputs;
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
          modules = [
            ./home/home.nix
            ./home/path.nix
            ./home/shell.nix
            ./home/user.nix
            ./home/aliases.nix
            ./home/programs.nix
            ./home/packages.nix
            ./home/files.nix

            # Host Specific configs
            ./home/hosts/ombre/chloe.nix
            ./home/hosts/ombre/custom.nix

            {home.packages = [];}
            {nixpkgs.overlays = pkgs.overlays;}
          ];
        };
    };
  };
}

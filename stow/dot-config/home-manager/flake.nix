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
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      # Flake requires some packages that aren't on 22.05, but are available on unstable.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    flox,
    home-manager,
    nixgl,
    nixpkgs,
    nixpkgs-unstable,
    nix-index-database,
    #Solaar-Flake,
    ...
  } @ inputs: {
    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = "${system}";
        overlays = [
          # when installing packages it’s then possible to use pkgs.unstable.foobar-some-package
          (final: prev: {
            unstable = import nixpkgs-unstable {
              system = prev.system;
            };
          })
          (final: prev: {
            flox = inputs.flox.packages.${prev.system}.default;
          })
          # nixGL overlay is required for opengl programs from nixpkgs to run on non-nixos linux
          nixgl.overlay
        ];
      };
    in {
      inherit inputs pkgs;

      # TODO: reduce repeated code by recursing over each user of each hostname and user.
      #   Available through 'home-manager --flake .#your-username@your-hostname'
      "chloe@qweenkpad" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules = [
          ./home.nix
          ./path.nix
          ./shell.nix
          ./user.nix
          ./aliases.nix
          ./programs.nix
          ./packages.nix

          nix-index-database.hmModules.nix-index
          # optional to also wrap and install comma
          {programs.nix-index-database.comma.enable = true;}

          # Host Specific configs
          ./hosts/qweenkpad/chloe.nix
          ./hosts/qweenkpad/custom.nix

          {home.packages = [];}
          {nixpkgs.overlays = pkgs.overlays;}
        ];
      };
      "chloe@ombre" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules = [
          ./home.nix
          ./path.nix
          ./shell.nix
          ./user.nix
          ./aliases.nix
          ./programs.nix
          ./packages.nix

          # Host Specific configs
          ./hosts/ombre/chloe.nix
          ./hosts/ombre/custom.nix

          {home.packages = [];}
          {nixpkgs.overlays = pkgs.overlays;}
        ];
      };
    };
  };
}

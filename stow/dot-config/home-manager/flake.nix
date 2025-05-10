{
  description = "Home Manager configuration of chloe";
  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = {
    self,
    home-manager,
    nixgl,
    nixpkgs,
    nixpkgs-unstable,
    nix-index-database,
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

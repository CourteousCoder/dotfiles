{
  description = "Home Manager configuration of chloe";
  inputs = {
# Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { self, nixpkgs, home-manager, nixgl, ... }@inputs: { 
      #   Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "${system}";
          # nixGL overlay is required for opengl programs from nixpkgs to run on non-nixos linux
          overlays = [ nixgl.overlay ];
        };
      in {
      inherit inputs pkgs;
      
      # TODO: reduce repeated code by recursing over each user of each hostname and user.
      
      "chloe@pop-os" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          ./home.nix 
          ./path.nix
          ./shell.nix
          ./user.nix
          ./aliases.nix
          ./programs.nix
          
           # Host Specific configs
          ./hosts/pop-os/chloe.nix
          ./hosts/pop-os/custom.nix

          { home.packages = []; }
          { nixpkgs.overlays = pkgs.overlays; }

        ];
      };
      "chloe@ombre" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [
          ./home.nix 
          ./path.nix
          ./shell.nix
          ./user.nix
          ./aliases.nix
          ./programs.nix
          
          
           # Host Specific configs
          ./hosts/ombre/chloe.nix
          ./hosts/ombre/custom.nix

          { home.packages = []; }
          { nixpkgs.overlays = pkgs.overlays; }

        ];
      };
    };
  };  
}

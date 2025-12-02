{
  description = "Container Escape Lab VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    web-vuln = {
      url = "path:../lab/images/web-vuln";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, web-vuln }: 
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.lab-vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        {
          # Pré-charger les images Docker dans la VM
          systemd.services.load-docker-images = {
            description = "Load Docker images for Container Escape Lab";
            wantedBy = [ "multi-user.target" ];
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              echo "Loading web-vuln Docker image..."
              ${nixpkgs.legacyPackages.${system}.docker}/bin/docker load < ${web-vuln.packages.${system}.web-vuln}
              echo "Docker images loaded successfully!"
              ${nixpkgs.legacyPackages.${system}.docker}/bin/docker images
            '';
          };
          
          virtualisation.memorySize = 16384; 
          virtualisation.cores = 10;     
          virtualisation.diskSize = 51200;
          
          virtualisation.forwardPorts = [
            { from = "host"; host.address = "127.0.0.1"; host.port = 2222; guest.port = 22; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18081; guest.port = 8081; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18082; guest.port = 8082; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18083; guest.port = 8083; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18084; guest.port = 8084; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18085; guest.port = 8085; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18086; guest.port = 8086; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18087; guest.port = 8087; }
            { from = "host"; host.address = "127.0.0.1"; host.port = 18088; guest.port = 8088; }
          ];
        }
      ];
    };

    packages.${system} = rec {
      vm = self.nixosConfigurations.lab-vm.config.system.build.vm;
      
      default = vm;
    };

    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.vm}/bin/run-container-escape-lab-vm";
    };
  };
}

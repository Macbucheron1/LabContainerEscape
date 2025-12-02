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
        }

        # Générer automatiquement les réseaux et services pour les 8 groupes
        (let
          # Fonction pour créer un réseau Docker isolé pour un groupe
          mkDockerNetwork = groupNum: {
            "docker-network-g${toString groupNum}" = {
              description = "Docker Network for Group ${toString groupNum}";
              wantedBy = [ "multi-user.target" ];
              after = [ "docker.service" ];
              requires = [ "docker.service" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script = ''
                ${nixpkgs.legacyPackages.${system}.docker}/bin/docker network rm labnet_g${toString groupNum} 2>/dev/null || true
                
                echo "Creating isolated network for group ${toString groupNum}..."
                ${nixpkgs.legacyPackages.${system}.docker}/bin/docker network create \
                  --driver bridge \
                  --subnet 172.20.${toString groupNum}.0/24 \
                  labnet_g${toString groupNum}
                
                echo "Network labnet_g${toString groupNum} created (172.20.${toString groupNum}.0/24)"
              '';
              preStop = ''
                ${nixpkgs.legacyPackages.${system}.docker}/bin/docker network rm labnet_g${toString groupNum} || true
              '';
            };
          };
          
          # Fonction pour créer un service web-vuln pour un groupe
          mkWebVulnService = groupNum: {
            "docker-web-vuln-g${toString groupNum}" = {
              description = "Web-Vuln Container - Group ${toString groupNum}";
              wantedBy = [ "multi-user.target" ];
              after = [ "docker-network-g${toString groupNum}.service" ];
              requires = [ "docker-network-g${toString groupNum}.service" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStartPre = "${nixpkgs.legacyPackages.${system}.docker}/bin/docker rm -f web-vuln-g${toString groupNum} || true";
              };
              script = ''
                echo "Starting web-vuln container for group ${toString groupNum}..."
                ${nixpkgs.legacyPackages.${system}.docker}/bin/docker run -d \
                  --name web-vuln-g${toString groupNum} \
                  --network labnet_g${toString groupNum} \
                  --ip 172.20.${toString groupNum}.2 \
                  -p ${toString (8080 + groupNum)}:80 \
                  --restart unless-stopped \
                  web-vuln:latest
                
                echo "Group ${toString groupNum}: web-vuln started (172.20.${toString groupNum}.2:80 -> :${toString (8080 + groupNum)})"
              '';
              preStop = ''
                ${nixpkgs.legacyPackages.${system}.docker}/bin/docker stop web-vuln-g${toString groupNum} || true
                ${nixpkgs.legacyPackages.${system}.docker}/bin/docker rm web-vuln-g${toString groupNum} || true
              '';
            };
          };
          
          # Générer tous les services (réseaux + containers) pour les groupes 1 à 8
          allServices = builtins.foldl' 
            (acc: groupNum: 
              acc 
              // (mkDockerNetwork groupNum)
              // (mkWebVulnService groupNum)
            )
            {}
            [1 2 3 4 5 6 7 8];
        in
        {
          systemd.services = allServices;
        })

        { 
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

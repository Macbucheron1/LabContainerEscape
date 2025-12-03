{
  description = "Priv-Escape Container - SSH + Docker Socket Access";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        
        # Image de base linuxserver/openssh-server
        openssh-base = pkgs.dockerTools.pullImage {
          imageName = "linuxserver/openssh-server";
          imageDigest = "sha256:5c11355ae47107808cb49da35d72b5088820d1dd002cce4da38fd377f0c9b739";
          sha256 = "sha256-k7xoacF52yNg+Vkp64SjZ19lhDtyJNBnEwRR0HDJ0GA=";
          finalImageName = "linuxserver/openssh-server";
          finalImageTag = "latest";
        };

        # Image priv-escape personnalisée
        priv-escape = pkgs.dockerTools.buildLayeredImage {
          name = "priv-escape";
          tag = "latest";
          
          fromImage = self.packages.${system}.openssh-base;
          
          # Force l'architecture
          architecture = "amd64";
          
          # Ajouter des outils pour le container escape
          contents = with pkgs; [
            bash
            coreutils
            curl
            wget
            nmap
            netcat
            iproute2
            procps
            findutils
            gnugrep
            gnused
            docker-client  # Client Docker pour interagir avec le socket
          ];

          # Configuration pour SSH avec credentials
          config = {
            Entrypoint = [ "/init" ];
            Env = [
              "PASSWORD_ACCESS=true"
              "USER_NAME=operator"
              "USER_PASSWORD=N0p@55Wo4dforU"
              "PUID=1000"
              "PGID=1000"
              "TZ=Europe/Paris"
            ];
            ExposedPorts = {
              "2222/tcp" = {};
            };
          };

          extraCommands = ''
            # Créer les répertoires nécessaires
            mkdir -p config
            mkdir -p var/run
          '';
        };

        default = self.packages.${system}.priv-escape;
      };
    };
}

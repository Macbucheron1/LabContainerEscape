{
  description = "Web Vulnerable Container - PHP Upload RCE Lab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        
        php-apache-base = pkgs.dockerTools.pullImage {
          imageName = "php";
          imageDigest = "sha256:b8c8cd2be5690fcc2a6d0a44fee6c319052ee961148236f6a62a03f2b65e439f";
          sha256 = "sha256-Lz0BCGQE79C+PRWHUYeDHxC9XEqIS7LFQKn33mNwHI4=";
          finalImageName = "php";
          finalImageTag = "8.2-apache";
        };

        web-vuln = pkgs.dockerTools.buildLayeredImage {
          name = "web-vuln";
          tag = "latest";
          
          fromImage = self.packages.${system}.php-apache-base;
          
          # Force l'architecture pour éviter les conflits
          architecture = "amd64";
          
          contents = with pkgs; [
            bash
            coreutils
            curl
            nmap
            netcat
            iproute2
            procps
            findutils
            gnugrep
            gnused
            wget
          ];

          config = {
            Entrypoint = [ "docker-php-entrypoint" ];
            Cmd = [ "apache2-foreground" ];
            WorkingDir = "/var/www/html";
            ExposedPorts = {
              "80/tcp" = {};
            };
          };

          extraCommands = ''
            mkdir -p var/www/html
            mkdir -p var/www/html/uploads
            mkdir -p etc/apache2/sites-available
            mkdir -p var/log/apache2

            cp ${./app/index.php} var/www/html/index.php
            cp ${./app/upload.php} var/www/html/upload.php
            cp ${./app/creds.txt} var/www/html/creds.txt

            cp ${./config/apache.conf} etc/apache2/sites-available/000-default.conf

            chmod -R 755 var/www/html
            chmod 777 var/www/html/uploads
            chmod 666 var/www/html/creds.txt
          '';
        };

        default = self.packages.${system}.web-vuln;
      };
    };
}

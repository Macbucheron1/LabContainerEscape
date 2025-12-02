{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "container-escape-lab";
  networking.useDHCP = true;

  networking.networkmanager.enable = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.dev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "password";
  };

  security.sudo.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    python3
  ];

  console.keyMap = "fr";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 8081 8082 8083 8084 8085 8086 8087 8088 ];

  services.xserver.enable = false;

  services.getty.autologinUser = null;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.qemuGuest.enable = true;
  
  system.stateVersion = "25.11";
}

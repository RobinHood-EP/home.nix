{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tools.git;
in
{

  options.tools.git = {
    enable = mkEnableOption "Enable GIT";

    userName = mkOption { type = types.str; };
    userEmail = mkOption { type = types.str; };
    githubUser = mkOption { type = types.str; };

    workspaces = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.file = lib.mapAttrs' (k: v: lib.nameValuePair "${k}/.gitconfig" { text = lib.generators.toINI { } v; }) cfg.workspaces;

    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;

      extraConfig = {
        github.user = cfg.githubUser;
      };

      includes = map (x: { condition = "gitdir:~/${x}/"; path = "~/${x}/.gitconfig"; })
        (lib.attrNames cfg.workspaces);
    };

    home.packages = with pkgs; [
      git-crypt
    ];
  };
}

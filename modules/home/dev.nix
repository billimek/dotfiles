# Development tools
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.dev;
  instructionCfg = config.modules.agent-instructions;
in
{
  options.modules.dev = {
    enable = lib.mkEnableOption "development tools";

    opencode = {
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {
          share = "disabled";
          theme = "one-dark";
          default_agent = "plan";
        };
        description = "OpenCode configuration settings";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python3Packages.pyyaml
      python3Packages.requests
      # manage outside of nix until it updates less frequently
      # pkgs.unstable.opencode
      uv
    ];
    home.sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/.opencode/bin"
    ];

    # OpenCode configuration
    home.file.".config/opencode/opencode.json".text = builtins.toJSON (
      {
        "$schema" = "https://opencode.ai/config.json";
        instructions = [
          "~/${instructionCfg.globalFilePath}"
          instructionCfg.repoFileName
        ];
        # plugin = [ "oh-my-opencode-slim" ];
        model = "github-copilot/claude-sonnet-4.6";
      }
      // cfg.opencode.settings
    );
  };
}

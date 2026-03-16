# Shared AI agent instruction files and settings
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.agent-instructions;
in
{
  options.modules.agent-instructions = {
    enable = lib.mkEnableOption "shared AI agent instructions" // {
      default = true;
    };

    globalFilePath = lib.mkOption {
      type = lib.types.str;
      default = ".config/agent-instructions/global.md";
      description = "Canonical global instruction file path under the home directory.";
    };

    globalText = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Canonical global instructions shared across AI coding tools.";
    };

    repoFileName = lib.mkOption {
      type = lib.types.str;
      default = "AGENTS.md";
      description = "Canonical per-repo instruction filename.";
    };

    gemini.contextFileNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        cfg.repoFileName
        "GEMINI.md"
      ];
      description = "Gemini repo instruction filenames, in lookup order.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.${cfg.globalFilePath} = lib.mkIf (cfg.globalText != "") {
      force = true;
      text = cfg.globalText;
    };

    home.file.".copilot/copilot-instructions.md" = lib.mkIf (cfg.globalText != "") {
      force = true;
      text = cfg.globalText;
    };

    home.file.".claude/CLAUDE.md" = lib.mkIf (cfg.globalText != "") {
      force = true;
      text = cfg.globalText;
    };

    home.file.".gemini/GEMINI.md" = lib.mkIf (cfg.globalText != "") {
      force = true;
      text = cfg.globalText;
    };

    home.file.".gemini/settings.json" = {
      force = true;
      text = builtins.toJSON {
        context = {
          fileName = cfg.gemini.contextFileNames;
        };
      };
    };
  };
}

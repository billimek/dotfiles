{
  pkgs,
  ...
}:
{
  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
    defaultEditor = false;

    settings = {
      theme = "catppuccin_mocha";

      editor = {
        line-number = "relative";
        mouse = true;
        true-color = true;
        indent-guides.render = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker.hidden = false;
      };

      keys.normal = {
        space = {
          f = ":pick_file";
          w = ":write";
          q = ":quit";
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          };
        }
        {
          name = "bash";
          auto-format = true;
          formatter = {
            command = "${pkgs.shellcheck}/bin/shellcheck";
          };
        }
        {
          name = "markdown";
          auto-format = false;
        }
        {
          name = "yaml";
          auto-format = false;
        }
        {
          name = "json";
          auto-format = true;
          formatter = {
            command = "${pkgs.jq}/bin/jq";
            args = ["."];
          };
        }
      ];
    };
  };
}

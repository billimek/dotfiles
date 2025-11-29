# Starship prompt configuration
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.starship;
in
{
  options.modules.starship = {
    enable = lib.mkEnableOption "starship prompt" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        status.disabled = false;
        username = { };
        hostname = {
          ssh_only = true;
          disabled = false;
          ssh_symbol = "@";
        };
        kubernetes.disabled = false;
        ocaml.disabled = true;
        perl.disabled = true;
        cmd_duration = {
          format = "took [$duration]($style) ";
        };

        directory = {
          format = "[$path]($style)( [$read_only]($read_only_style)) ";
        };

        gcloud = {
          format = "on [$symbol($project)]($style) ";
        };

        aws.symbol = "  ";
        conda.symbol = " ";
        dart.symbol = " ";
        directory.read_only = " ";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        gcloud.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        hg_branch.symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        memory_usage.symbol = " ";
        nim.symbol = " ";
        nodejs.symbol = " ";
        package.symbol = " ";
        perl.symbol = " ";
        php.symbol = " ";
        python.symbol = " ";
        ruby.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        shlvl.symbol = "";
        swift.symbol = "ﯣ ";
        terraform.symbol = "行";
      };
    };
  };
}

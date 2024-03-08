{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  hasPackage = pname: lib.any (p: p ? pname && p.pname == pname) config.home.packages;
  hasRipgrep = hasPackage "ripgrep";
  hasEza = hasPackage "eza";
  hasLsd = hasPackage "lsd";
  hasKubecolor = hasPackage "kubecolor";
  hasNeovim = config.programs.neovim.enable;
in {
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "humantime-fish";
        src = pkgs.fishPlugins.humantime-fish.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "patrickF1";
          repo = "fzf.fish";
          rev = "v9.8";
          sha256 = "046wm3hb2hkxsp1966byiaadxhxyr1vb81iv2ng3f26fjdvqqrn5";
        };
      }
      {
        name = "abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "v0.6.0";
          sha256 = "fveTvR+T6IiX8Zk5m6zToo1OtZc1VyrCHfOG63e9b64=";
        };
      }
    ];
    shellAbbrs = rec {
      # git
      gs = "git status";
      gc = "git commit";
      gcm = "git ci -m";
      gco = "git co";
      ga = "git add -A";
      gm = "git merge";
      gl = "git l";
      gd = "git diff";
      gb = "git b";
      gpl = "git pull";
      gp = "git push";
      gpc = "git push -u origin (git rev-parse --abbrev-ref HEAD)";
      gpf = "git push --force-with-lease";
      gbc = "git nb";

      # lsd
      ls = mkIf hasLsd "lsd";

      # nix
      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

      nr = "nixos-rebuild --flake .";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";
      rebuild = "sudo nixos-rebuild switch";
      rehome = "home-manager switch --flake .#(whoami)@(hostname)";

      # other
      df = "df -h";
      du = "du -h";
      jqless = "jq -C | less -r";
      k = "kubectl";
      sc = "tmux detach;tmux attach";
    };
    shellAliases = {
      # Clear screen and scrollback
      # clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      kubectl = mkIf hasKubecolor "kubecolor";
      ll = "lsd -la";
      llrt = "lsd -lart";
    };
    functions = {
      # Disable greeting
      fish_greeting = "";

      # https://github.com/fish-shell/fish-shell/issues/1279#issuecomment-1203233446
      _report_time = {
        description = "Reports runtime of long commands";
        onEvent = "fish_postexec";
        body = ''
          if test "$CMD_DURATION" -gt 2000
              set milliseconds (math -s0 "($CMD_DURATION) % 1000")
              set seconds      (math -s0 "($CMD_DURATION / (1000)) % 60")
              set minutes      (math -s0 "($CMD_DURATION / (1000*60)) % 60")
              set hours        (math -s0 "($CMD_DURATION / (1000*60*60)) % 24")
              set days         (math -s0 "($CMD_DURATION / (1000*60*60*24))")

              echo -n (set_color -io -b black black)"Took "
              test $days -gt 0 && echo -n "$days days, "
              test $hours -gt 0 && echo -n "$hours hours, "
              test $minutes -gt 0 && echo -n "$minutes minutes, "
              printf "%d.%03d seconds: %s" $seconds $milliseconds $argv[1]
              echo (set_color normal)
          end
        '';
      };

      epub-to-mobi = {
        description = "convert epub files to mobi files";
        body = ''
          for i in *.epub; echo $i;ebook-convert  "$i" "$(basename "$i" .epub).mobi"; end
        '';
      };

      dps = {
        description = "formatted `docker ps` command";
        body = ''
          docker ps --format 'table {{.Names}}\t{{.Status}}'
        '';
      };
    };

    shellInit = ''
      set -gx LS_COLORS 'di=01;34:ln=01;36:pi=33:so=01;35:bd=01;33:cd=33:or=31:ex=01;32:*.7z=01;31:*.bz2=01;31:*.gz=01;31:*.lz=01;31:*.lzma=01;31:*.lzo=01;31:*.rar=01;31:*.tar=01;31:*.tbz=01;31:*.tgz=01;31:*.xz=01;31:*.zip=01;31:*.zst=01;31:*.zstd=01;31:*.bmp=01;35:*.tiff=01;35:*.tif=01;35:*.TIFF=01;35:*.gif=01;35:*.jpeg=01;35:*.jpg=01;35:*.png=01;35:*.webp=01;35:*.pot=01;35:*.pcb=01;35:*.gbr=01;35:*.scm=01;35:*.xcf=01;35:*.spl=01;35:*.stl=01;35:*.dwg=01;35:*.ply=01;35:*.apk=01;31:*.deb=01;31:*.rpm=01;31:*.jad=01;31:*.jar=01;31:*.crx=01;31:*.xpi=01;31:*.avi=01;35:*.divx=01;35:*.m2v=01;35:*.m4v=01;35:*.mkv=01;35:*.MOV=01;35:*.mov=01;35:*.mp4=01;35:*.mpeg=01;35:*.mpg=01;35:*.sample=01;35:*.wmv=01;35:*.3g2=01;35:*.3gp=01;35:*.gp3=01;35:*.webm=01;35:*.flv=01;35:*.ogv=01;35:*.f4v=01;35:*.3ga=01;35:*.aac=01;35:*.m4a=01;35:*.mp3=01;35:*.mp4a=01;35:*.oga=01;35:*.ogg=01;35:*.opus=01;35:*.s3m=01;35:*.sid=01;35:*.wma=01;35:*.flac=01;35:*.alac=01;35:*.mid=01;35:*.midi=01;35:*.pcm=01;35:*.wav=01;35:*.ass=01;33:*.srt=01;33:*.ssa=01;33:*.sub=01;33:*.git=01;33:*.ass=01;33:*README=33:*README.rst=33:*README.md=33:*LICENSE=33:*COPYING=33:*INSTALL=33:*COPYRIGHT=33:*AUTHORS=33:*HISTORY=33:*CONTRIBUTOS=33:*PATENTS=33:*VERSION=33:*NOTICE=33:*CHANGES=33:*CHANGELOG=33:*log=33:*.txt=33:*.md=33:*.markdown=33:*.nfo=33:*.org=33:*.pod=33:*.rst=33:*.tex=33:*.texttile=33:*.bib=35:*.json=35:*.jsonl=35:*.jsonnet=35:*.libsonnet=35:*.rss=35:*.xml=35:*.fxml=35:*.toml=35:*.yaml=35:*.yml=35:*.dtd=35:*.cbr=35:*.cbz=35:*.chm=35:*.pdf=35:*.PDF=35:*.epub=35:*.awk=35:*.bash=35:*.bat=35:*.BAT=35:*.sed=35:*.sh=35:*.zsh=35:*.vim=35:*.py=35:*.ipynb=35:*.rb=35:*.gemspec=35:*.pl=35:*.PL=35:*.t=35:*.msql=35:*.mysql=35:*.pgsql=35:*.sql=35:*.r=35:*.R=35:*.cljw=35:*.scala=35:*.sc=35:*.dart=35:*.asm=35:*.cl=35:*.lisp=35:*.rkt=35:*.el=35:*.elc=35:*.eln=35:*.lua=35:*.c=35:*.C=35:*.h=35:*.H=35:*.tcc=35:*.c++=35:*.h++=35:*.hpp=35:*.hxx=35:*ii.=35:*.m=35:*.M=35:*.cc=35:*.cs=35:*.cp=35:*.cpp=35:*.cxx=35:*.go=35:*.f=35:*.F=35:*.nim=35:*.nimble=35:*.s=35:*.S=35:*.rs=35:*.scpt=35:*.swift=35:*.vala=35:*.vapi=35:*.hs=35:*.lhs=35:*.zig=35:*.v=35:*.pyc=35:*.tf=35:*.tfstate=35:*.tfvars=35:*.css=35:*.less=35:*.sass=35:*.scss=35:*.htm=35:*.html=35:*.jhtm=35:*.mht=35:*.eml=35:*.coffee=35:*.java=35:*.js=35:*.mjs=35:*.jsm=35:*.jsp=35:*.rasi=35:*.php=35:*.twig=35:*.vb=35:*.vba=35:*.vbs=35:*.Dockerfile=35:*.dockerignore=35:*.Makefile=35:*.MANIFEST=35:*.am=35:*.in=35:*.hin=35:*.scan=35:*.m4=35:*.old=35:*.out=35:*.SKIP=35:*.diff=35:*.patch=35:*.tmpl=35:*.j2=35:*PKGBUILD=35:*config=35:*.conf=35:*.service=31:*.@.service=31:*.socket=31:*.swap=31:*.device=31:*.mount=31:*.automount=31:*.target=31:*.path=31:*.timer=31:*.snapshot=31:*.allow=31:*.swp=31:*.swo=31:*.tmp=31:*.pid=31:*.state=31:*.lock=31:*.lockfile=31:*.pacnew=31:*.un=31:*.orig=31:'
    '';

    interactiveShellInit =
      # Open command buffer in vim when alt+e is pressed
      ''
        #bind \ee edit_command_buffer
      ''
      +
      # Use vim bindings and cursors
      ''
        #fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
      ''
      +
      # fzf
      ''
        set fzf_preview_dir_cmd exa --all --color=always
        set -x FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*" --color=fg:white,bg:black,hl:red,fg+:white,hl+:red,info:yellow,prompt:blue,pointer:magenta,marker:magenta,spinner:green,header:blue,border:white'
        set fzf_fd_opts --hidden --exclude=.git --exclude=.github --exclude=.cache
      '';
  };
}

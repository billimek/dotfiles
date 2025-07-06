{
  pkgs,
  ...
}:
{
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    enableManpages = true; #for man 5 nvf

    settings.vim = {
      package = pkgs.unstable.neovim-unwrapped;

      keymaps = [
        {
          mode = "n";
          key = "<leader>rp";
          action = ":lua require('precognition').peek()<CR>";
          desc = "Peek recognition";
        }
      ];
      viAlias = false;
      vimAlias = true;
      
      lsp = {
        enable = true;
        formatOnSave = true;
        trouble.enable = true;
        lspSignature.enable = true;
        null-ls.enable = true;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix.enable = true;
        markdown.enable = true;
        bash.enable = true;
        helm.enable = true;
        terraform.enable = true;
        yaml.enable = true;
      };

      options = {
        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;
        autoindent = true;
        smartindent = true;
      };

      visuals = {
        nvim-scrollbar.enable = true;
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
        cinnamon-nvim.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
          theme = "catppuccin";
        };
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };

      assistant.copilot = {
        enable = true;
        cmp.enable = true;
      };

      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;
      filetree.neo-tree.enable = true;
      tabline.nvimBufferline.enable = true;
      treesitter.context.enable = true;
      
      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope.enable = true;
      
      git = {
        enable = true;
        gitsigns = {
          enable = true;
          codeActions.enable = true;
        };
      };

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim.enable = true;
      };

      utility = {
        surround.enable = true;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
        };
      };

      notes = {
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        breadcrumbs = {
          enable = true;
          navbuddy.enable = true;
        };
      };

      comments = {
        comment-nvim.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; {
        CopilotChat-nvim = {
          package = CopilotChat-nvim;
          setup = ''
            require("CopilotChat").setup({
              window = {
                layout = 'float',
                width = 0.5,
                height = 0.5,
                relative = 'editor',
                border = 'single',
                row = nil,
                col = nil,
                title = 'Copilot Chat',
                footer = nil,
                zindex = 1,
              },
            })
            vim.keymap.set({"n", "i", "v"}, "<C-c>", ":CopilotChatToggle<CR>", { desc = "copilot" })
          '';
        };
      };
    };
  };
}
{
  outputs,
  lib,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    # need newer version of neovim for conform to work
    package = pkgs.unstable.neovim-unwrapped;
    defaultEditor = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # NodeJS
      nodejs

      # Treesitter
      cmake
      gcc
      tree-sitter

      # Formatters and Linters
      selene
      shfmt
      stylua

      # LSPs
      helm-ls
      prettierd
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.bash-language-server
      sumneko-lua-language-server
      nixd
      terraform-ls
    ];
  };

  # hacky lazyvim configuration - replicating what https://github.com/LazyVim/starter does
  home.file.".config/nvim/init.lua".text = ''
    -- bootstrap lazy.nvim, LazyVim and your plugins
    require("config.lazy")
    
    vim.opt.mouse = "" -- Disable mouse mode
  '';
  home.file.".config/nvim/stylua.toml".text = ''
    indent_type = "Spaces"
    indent_width = 2
    column_width = 120
  '';
  home.file.".config/nvim/.neoconf.json".text = ''
    {
    "neodev": {
        "library": {
        "enabled": true,
        "plugins": true
        }
    },
    "neoconf": {
        "plugins": {
        "lua_ls": {
            "enabled": true
        }
        }
    }
    }
  '';
  home.file.".config/nvim/lua/config/autocmds.lua".text = ''
    -- Autocmds are automatically loaded on the VeryLazy event
    -- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
    -- Add any additional autocmds here
  '';
  home.file.".config/nvim/lua/config/keymaps.lua".text = ''
    -- Keymaps are automatically loaded on the VeryLazy event
    -- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
    -- Add any additional keymaps here
  '';
  home.file.".config/nvim/lua/config/lazy.lua".text = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
    -- bootstrap lazy.nvim
    -- stylua: ignore
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
    end
    vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

    require("lazy").setup({
    spec = {
        -- add LazyVim and import its plugins
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- import any extras modules here
        -- { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.ui.mini-animate" },
        { import = "lazyvim.plugins.extras.coding.copilot" },
        { import = "lazyvim.plugins.extras.coding.copilot-chat" },
        -- import/override with your plugins
        { import = "plugins" },
    },
    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    install = { colorscheme = { "tokyonight-night", "habamax" } },
    checker = { enabled = true }, -- automatically check for plugin updates
    performance = {
        rtp = {
        -- disable some rtp plugins
        disabled_plugins = {
            "gzip",
            -- "matchit",
            -- "matchparen",
            -- "netrwPlugin",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
        },
        },
    },
    })
  '';
  home.file.".config/nvim/lua/config/options.lua".text = ''
    -- Options are automatically loaded before lazy.nvim startup
    -- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
    -- Add any additional options here
  '';
  home.file.".config/nvim/lua/plugins/example.lua".text = ''
    -- since this is just an example spec, don't actually load anything here and return an empty spec
    -- stylua: ignore
    if true then return {} end
  '';
}

# Nixvim port of .config/lua-nvim (the lazy.nvim based config).
#
# Parallel install: this module is added alongside the existing Makefile
# symlinked configs (.config/nvim and .config/lua-nvim), which stay untouched.
# Nixvim's wrapped neovim is launched with `-u <generated init>` so it ignores
# NVIM_APPNAME configs; to keep the `ov` / `v` aliases working with the old
# configs, home.nix keeps plain neovim with lib.hiPrio (it wins the `nvim`
# name) and the nixvim build is exposed here as the `nixvim` command.
#
# Differences from .config/lua-nvim (intentional / unavoidable):
#   - lazy.nvim itself is not used: nix takes over plugin management, so the
#     bootstrap code in lua/config/lazy.lua has no equivalent.
#   - noice.nvim was lazy-loaded on the VeryLazy event; here it loads at
#     startup (nixvim does not lazy-load by default). Functionally identical.
#   - lsp: `vim.lsp.enable("rust_analyzer")` relied on rust-analyzer from the
#     environment (rustup). Here nvim-lspconfig still provides the default
#     config and rust-analyzer is resolved from $PATH first, with the nixpkgs
#     build appended as a fallback (packageFallback).
{ inputs, pkgs, config, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;

    # In home-manager nixvim defaults to wrapRc = false, which writes its init
    # to ~/.config/nvim via xdg.configFile — that would collide with the
    # Makefile symlink ~/.config/nvim -> this repo. Bake the config into the
    # wrapper (-u <generated init>) instead and keep the rtp pure so the
    # symlinked configs are never picked up by this binary.
    wrapRc = true;
    impureRtp = false;

    # lua/config/lazy.lua
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    # lua/core.lua + the opts set inside the statuscol plugin spec
    opts = {
      cursorline = true; # highlight cursor line
      list = true; # show tabs and trailing spaces
      clipboard = "unnamedplus"; # sync clipboard (provider comes from the environment)
      expandtab = true; # insert spaces instead of tabs
      tabstop = 2; # render a tab as two spaces
      shiftwidth = 2; # use two spaces for auto indent
      number = true;
      relativenumber = true;
    };

    keymaps = [
      {
        mode = "x";
        key = "p";
        action = ''"_dP'';
        options.desc = "paste in visual mode without yanking selection";
      }
      {
        mode = "t";
        key = "<Esc>";
        action = "<C-\\><C-n>";
        options = {
          silent = true;
          desc = "exit terminal-mode with Esc";
        };
      }
      {
        mode = "n";
        key = "Q";
        action.__raw = ''
          function()
            local dir = vim.fn.expand("%:p:h")
            vim.cmd("bd")
            require("oil").open(dir)
          end
        '';
        options.desc = "delete current buffer and return to oil";
      }
      # from the oil.nvim plugin spec
      {
        mode = "n";
        key = "-";
        action = "<CMD>Oil<CR>";
        options.desc = "Open parent directory";
      }
    ];

    # vim.api.nvim_create_user_command("Q", "q!", {})
    userCommands.Q.command = "q!";

    # EdenEast/nightfox.nvim
    colorschemes.nightfox.enable = true;

    plugins = {
      # stevearc/oil.nvim
      oil = {
        enable = true;
        settings = {
          delete_to_trash = true;
          view_options.show_hidden = true;
        };
      };

      # luukvbaal/statuscol.nvim
      statuscol = {
        enable = true;
        settings = {
          setopt = true;
          segments = [
            {
              text = [
                {
                  __raw = ''
                    function(args)
                      return "%#LineNr#" .. ("%2d "):format(args.lnum)
                    end
                  '';
                }
              ];
            }
            {
              text = [
                {
                  __raw = ''
                    function(args)
                      return "%#CursorLineNr#" .. ("%2d "):format(args.relnum > 99 and 99 or args.relnum)
                    end
                  '';
                }
              ];
            }
          ];
        };
      };

      # neovim/nvim-lspconfig (provides the default rust_analyzer config)
      lspconfig.enable = true;

      # ap/vim-css-color
      vim-css-color.enable = true;

      # rcarriga/nvim-notify (was a lazy.nvim dependency of noice)
      notify.enable = true;

      # folke/noice.nvim (nui.nvim comes in as a package dependency)
      noice = {
        enable = true;
        settings = {
          cmdline.enabled = true;
          messages.enabled = false;
        };
      };
    };

    # vim.lsp.enable("rust_analyzer")
    lsp.servers.rust_analyzer = {
      enable = true;
      # prefer rust-analyzer from the environment (rustup), fall back to nixpkgs
      packageFallback = true;
    };
  };

  # `v` / `ov` keep using plain neovim (hiPrio in home.nix); reach this config
  # through the `nixvim` command.
  home.packages = [
    (pkgs.runCommand "nixvim-cmd" { } ''
      mkdir -p $out/bin
      ln -s ${config.programs.nixvim.build.package}/bin/nvim $out/bin/nixvim
    '')
  ];
}

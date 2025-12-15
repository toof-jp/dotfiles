return {
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme nightfox]])
    end,
  },
  {
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        delete_to_trash = true,
	view_options = {
          show_hidden = true,
	}
      })
    end,
  },
  {
  "luukvbaal/statuscol.nvim",
  config = function()
    local builtin = require("statuscol.builtin")

    require("statuscol").setup({
      setopt = true,
      segments = {
        {
          text = {
            function(args)
              return "%#LineNr#" .. ("%2d "):format(args.lnum)
            end,
          },
        },
        {
          text = {
            function(args)
              return "%#CursorLineNr#" .. ("%2d "):format(args.relnum > 99 and 99 or args.relnum)
            end,
          },
        },
      },
    })
  end
},
}

vim.opt.cursorline = true -- highlight cursor line
vim.opt.list = true -- show tabs and trailing spaces
vim.opt.clipboard = "unnamedplus" -- sync clipboard
-- vim.opt.shellcmdflag = "-ic" -- run shell commands as an interactive shell commands
vim.opt.expandtab = true -- insert spaces instead of tabs
vim.opt.tabstop = 2 -- render a tab as two spaces
vim.opt.shiftwidth = 2 -- use two spaces for auto indent

vim.keymap.set("x", "p", '"_dP', { desc = "paste in visual mode without yanking selection" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true, desc = "exit terminal-mode with Esc" })
vim.keymap.set("n", "Q", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("bd")
  require("oil").open(dir)
end, { desc = "delete current buffer and return to oil" })

vim.api.nvim_create_user_command("Q", "q!", {})

" Minimal Neovim configuration for testing
" Based on plenary.nvim testing recommendations

" Set up the runtime path to include plenary and current config
set rtp^=.

" Ensure we can load our config
lua << EOF
-- Bootstrap lazy.nvim for tests
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim")
  end
end
vim.opt.rtp:prepend(lazypath)

-- Only load essential plugins for testing
require("lazy").setup({
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "neovim/nvim-lspconfig",
  },
}, {
  -- Disable notifications and UI for tests
  ui = { border = "none" },
  install = { colorscheme = {} },
  checker = { enabled = false },
  change_detection = { enabled = false },
})

-- Add test directory to package path
package.path = package.path .. ";" .. vim.fn.expand("%:p:h") .. "/?.lua"
EOF

" Enable some basic settings needed for tests
set nocompatible
set hidden
set noswapfile
set nobackup
set nowritebackup
set shortmess+=c
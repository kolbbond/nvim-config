-- additional settings for vim

-- single source of truth; must land before remap.lua and before lazy.setup()
vim.g.mapleader = " ";
vim.g.maplocalleader = "\\";

-- fat cursor
vim.opt.guicursor = "";

-- line number
vim.opt.nu = true;
vim.opt.relativenumber = true;

-- tabs
vim.opt.tabstop = 4;
vim.opt.softtabstop = 4;
vim.opt.shiftwidth = 4;
vim.opt.expandtab = true;
vim.opt.smartindent = true;

-- no wrap
vim.opt.wrap = false;

-- no backups except in undotree
vim.opt.swapfile = false;
vim.opt.backup = false;
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true;

-- search highlights
vim.opt.hlsearch = false;
vim.opt.incsearch = true;

-- replace many
vim.opt.inccommand = "split";

-- colors!
vim.opt.termguicolors = true;

-- limit buffer lines
vim.opt.scrolloff = 8;
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@");

-- fast update
vim.opt.updatetime = 50;

vim.opt.colorcolumn = "80";

-- ftplugins set formatoptions, so undo them after FileType, not before.
-- 'r'/'o': no comment leader on <CR> or o/O. 'c': no auto-wrapping comments.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("kolbbond_formatoptions", { clear = true }),
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

if not os.getenv("DISPLAY") then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end




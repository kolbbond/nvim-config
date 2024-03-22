-- additional settings for vim

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

-- colors!
vim.opt.termguicolors = true;

-- limit buffer lines
vim.opt.scrolloff = 8;
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@");

-- fast update
vim.opt.updatetime = 50;

vim.opt.colorcolumn = "80";

vim.g.mapleader = " ";




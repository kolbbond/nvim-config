-- main init.lua for neovim
require("kolbbond")

-- format, turn off auto paste comments!
vim.opt_local.formatoptions:remove({ 'r', 'o'})

-- slime
--vim.g.slime_target = "tmux"
--vim.g.slime_target = "vimterminal"
--vim.g.slime_target = "neovim"
vim.g.slime_menu_config=1

-- netrw line numbers
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

-- change coloring
-- require("colors")







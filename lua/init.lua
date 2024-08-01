-- main init.lua for neovim
require("kolbbond")

-- format, turn off auto paste comments!
vim.opt_local.formatoptions:remove({ 'r', 'o'})

-- slime
vim.g.slime_target = "tmux"

-- change coloring
-- require("colors")







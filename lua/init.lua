-- main init.lua for neovim
require("kolbbond")

-- format, turn off auto paste comments!
vim.opt_local.formatoptions:remove({ 'r', 'o' })

-- slime
--vim.g.slime_target = "tmux"
--vim.g.slime_target = "vimterminal"
--vim.g.slime_target = "neovim"
vim.g.slime_menu_config = 1

-- netrw line numbers
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

-- asyncrun autocmd
local mymsg = "--- initializing ---";
vim.schedule(function()
    vim.api.nvim_echo({ { mymsg } }, false, {})
end)

require("modules")
local group = vim.api.nvim_create_augroup("AsyncRunNotifications", { clear = true })
vim.api.nvim_create_autocmd("User", {
    pattern = "AsyncRunStop",
    group = group,
    callback = function()
        require("modules").notify_build_status()
    end,
})

-- change coloring
-- require("colors")

-- require lazy
require("config.lazy")
mymsg = "✅ Neovim loaded ✅";
vim.schedule(function()
    vim.api.nvim_echo({ { mymsg } }, false, {})
end)

-- main init.lua for neovim
-- options/keymaps first, plugin globals next, lazy.setup() last
require("kolbbond")

-- slime
--vim.g.slime_target = "tmux"
--vim.g.slime_target = "vimterminal"
--vim.g.slime_target = "neovim"
vim.g.slime_menu_config = 1

-- netrw line numbers
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

-- asyncrun autocmd
local init_msg = "--- initializing ---";
vim.schedule(function()
    vim.api.nvim_echo({ { init_msg } }, false, {})
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

-- last: every option and plugin global must be set before lazy.setup()
require("config.lazy")
local loaded_msg = "✅ Neovim loaded ✅";
vim.schedule(function()
    vim.api.nvim_echo({ { loaded_msg } }, false, {})
end)

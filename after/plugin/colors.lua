-- colors.lua - Color keymaps and colorizer setup
-- Gruvbox config is in lua/plugins/themes.lua

-- ColorMyPencils function
function ColorMyPencils(color)
    color = color or "gruvbox"
    vim.cmd.colorscheme(color)
    vim.api.nvim_set_hl(0, "Comment", { fg = "#4C8687" })
end

vim.keymap.set("n", "<leader>cmp", ColorMyPencils, { desc = "Color my pencils" })

-- Background toggle
local flag_bg_dark = true
function invert_background()
    if flag_bg_dark then
        vim.o.background = "light"
        flag_bg_dark = false
    else
        vim.o.background = "dark"
        flag_bg_dark = true
    end
end

vim.keymap.set("n", "<leader>ibc", invert_background, { desc = "Invert background color" })

-- Colorizer setup
local colorizer_ok, colorizer = pcall(require, "colorizer")
if colorizer_ok then
    colorizer.setup({ "*" }, {
        RGB      = true,
        RRGGBB   = true,
        names    = true,
        RRGGBBAA = true,
        css      = true,
        css_fn   = true,
    })
end

-- Colorizer keymaps
vim.keymap.set("n", "<leader>ca", "<cmd>ColorizerAttachToBuffer<cr>", { desc = "Attach Colorizer" })
vim.keymap.set("n", "<leader>cd", "<cmd>ColorizerDetachFromBuffer<cr>", { desc = "Detach Colorizer" })
vim.keymap.set("n", "<leader>ct", "<cmd>ColorizerToggle<cr>", { desc = "Toggle Colorizer" })

-- Reload colorscheme command
vim.api.nvim_create_user_command("ReloadColorscheme", function()
    vim.cmd("colorscheme gruvbox")
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#555555", bg = "#1d2021", italic = false })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#8ddabb", bg = "#3c3836", italic = true, bold = true })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#3c3836", italic = false, bold = true })
    vim.api.nvim_set_hl(0, "Comment", { fg = "#4C8687" })
end, { desc = "Reload Gruvbox colorscheme" })

vim.keymap.set("n", "<leader>rc", "<cmd>ReloadColorscheme<cr>", { desc = "Reload Colorscheme" })

-- Treesitter highlight inspection
vim.keymap.set("n", "<leader>tsh", "<cmd>Inspect<cr>", { desc = "Inspect highlight under cursor" })

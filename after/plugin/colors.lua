-- custom colors
function ColorMyPencils(color)
    color = color or "gruvbox"
    vim.cmd.colorscheme(color)

    -- transparent background
    --vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none"})
    --vim.api.nvim_set_hl(0, "Normal", { blend = "none" })

    -- highlights
    vim.api.nvim_set_hl(0, "Comment", { fg = "#4C8687" })

    -- moving things from init.vim to lua
    -- @hey, not done
    --[[
    vim.cmd("colorscheme blue");
    vim.cmd("set termguicolors");
    vim.cmd("set cursorline");
    vim.cmd("hi Cursor guifg=black guibg=red");
    vim.cmd("set guicursor=n-v-c:block-Cursor/lCursor");
    vim.cmd("colorscheme " .. color);
    --]]
end

-- invert background color
flag_bg_dark = true;
function invert_background()
    if flag_bg_dark then
        background_light();
        flag_bg_dark = false;
    else
        background_dark()
        flag_bg_dark = true;
    end
end

-- map the above functions
vim.keymap.set("n", "<leader>ibc", invert_background);

function background_light()
    vim.o.background = "light";
end

function background_dark()
    vim.o.background = "dark";
end

-- set specific colorscheme
-- we love gruvbox
require("gruvbox").setup({
    invert_selection = true,
    contrast = "hard",

    -- trying to change cursor color but we overrided with terminal
    -- (wanted pink cursor)
    --overrides = {
    -- Cursor = { bg = "#000000", fg = "#000000" }
    --}
    -- darker background
    palette_overrides = {
--        dark0_hard = "#0f0f0f",
    },
});

--vim.o.background = "light";
vim.o.background = "dark";
vim.cmd("colorscheme gruvbox");

--ColorMyPencils()
vim.keymap.set("n", "<leader>cmp", ColorMyPencils);

-- colorizer map
vim.keymap.set("n", "<leader>ca", vim.cmd("ColorizerAttachToBuffer"));
vim.keymap.set("n", "<leader>cd", vim.cmd("ColorizerDetachFromBuffer"));
vim.keymap.set("n", "<leader>ct", vim.cmd("ColorizerToggle"));

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

vim.keymap.set("n", "<leader>cmp", ColorMyPencils);

-- colorizer
--require("colorizer").setup({
-- "*", -- highlight all filetypes
--  css = { rgb_fn = true },
--   html = { names = false },
--})
local colorizer_ok, colorizer = pcall(require, "colorizer")
if colorizer_ok then
    -- Setup for all filetypes
    colorizer.setup({ "*" }, {
        RGB      = true,
        RRGGBB   = true,
        names    = true,
        RRGGBBAA = true,
        css      = true,
        css_fn   = true,
    })

    -- Auto-attach after every buffer read or new file
    --vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    --   pattern = "*",
    --  callback = function()
    --     colorizer.attach_to_buffer(0)
    --end,
    --})
end

-- invert background color
local flag_bg_dark = true;
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
local custom_gruvbox = true;
--local dark_red = "#bb2206"
--local dark_background = "#1d1a1a"
local number = 1.0
if (custom_gruvbox) then
    require("gruvbox").setup({
        contrast = "hard",

        -- trying to change cursor color but we overrided with terminal
        -- (wanted pink cursor)
        overrides = {
            --Cursor = { fg = "#000000", bg = "#000000", },
            --Comment = { fg = "#928374", italic = true },
            --Normal = { fg = "#1d2021" }, -- change background
            --SignColumn = { fg = "#000000" },
            -- to check a signature use one of below
            -- :echo synIDattr(synID(line("."), col("."), 1), "name")
            -- :TSHighlightCapturesUnderCursor
            --    ["@lsp.type.method"] = { fg = dark_red, }, -- bg = "#ff9900" },
            --           ["@keyword.function"] = { fg = dark_red, },
            --          ["@function.call"] = { fg = dark_red, },
            ["@keyword"] = { fg = "#882206", bold = true, italic = false },
            ["@keyword.function"] = { fg = "#cc2206", },
            ["@keyword.conditional"] = { fg = "#df5520", },
            ["@variable"] = { fg = "#bbbbbb", },
            ["@variable.member"] = { fg = "#ddcccc", },
            ["@function.call"] = { fg = "#ddcccc", },
            ["@property"] = { fg = "#aaddaa", },
            ["@number"] = { fg = "#885588", },
            ["@type"] = { fg = "#d18a20", },
            ["@type.builtin"] = { fg = "#a18a20", },
            ["@comment"] = { fg = "#777777" },
            ["@comment.lua"] = { fg = "#ffffff" },
            --["@string"] = { fg = "#b8bb26" },
            ["@string"] = { fg = "#646a20", italic = true },
            ["@constant.builtin"] = { fg = "#bb55bb" },
            ["@function.builtin"] = { fg = "#a18a20" },
        },
        -- darker background
        palette_overrides = {
            dark0_hard = "#1d1a1a",
            --    bright_green = "#114411",
        },
        dim_inactive = false,     -- dim inactive windows
        transparent_mode = false, -- true = no background

        -- other default options from github
        terminal_colors = false, -- add neovim terminal colors
        undercurl = false,
        underline = false,
        bold = false,
        italic = {
            strings = false,
            emphasis = false,
            comments = false,
            operators = false,
            folds = false,
        },
        strikethrough = true,

        -- inversions
        invert_selection = true, -- invert selection highlight (makes white/black background for selection which is awesome)
        invert_signs = false,
        invert_tabline = true,
        inverse = true, -- invert background for search, diffs, statuslines and errors
    });
else
    require("gruvbox").setup({});
end
--vim.o.background = "dark";
vim.cmd("colorscheme gruvbox");

-- override general colors (can also override in gruvbox setup) @todo: override in gruvbox setup

-- custom highlights
local custom_hls = {
    LineNr = { fg = "#555555", bg = "#1d2021", italic = false },
    CursorLineNr = { fg = "#8ddabb", bg = "#3c3836", italic = true, bold = true },
    CursorLine = { bg = "#3c3836", italic = false, bold = true },
}
local function apply_custom_highlights()
    for group, opts in pairs(custom_hls) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end
apply_custom_highlights()

local function reload_colorizer()
    local ok, colorizer = pcall(require, "colorizer")
    if not ok then return end
    local bufnr = vim.api.nvim_get_current_buf()
    pcall(function() colorizer.detach_from_buffer(bufnr) end)
    vim.api.nvim_buf_clear_namespace(bufnr, colorizer.ns or 0, 0, -1)
    colorizer.attach_to_buffer(bufnr)
end

-- colorizer map
vim.keymap.set("n", "<leader>ca", function() vim.cmd("ColorizerAttachToBuffer") end,
    { desc = "Attach Colorizer to current buffer" });
--vim.keymap.set("n", "<leader>ca", function() require("colorizer").attach_to_buffer(0) end,
--   { desc = "Attach Colorizer to current buffer" });

--vim.keymap.set("n", "<leader>cr", function() vim.cmd("ColorizerReloadAllBuffers") end,
--{ desc = "Reload Colorizer buffers" });
vim.keymap.set("n", "<leader>cr", function() reload_colorizer() end,
    { desc = "Reload Colorizer buffers" });

vim.keymap.set("n", "<leader>cc", function()
    local bufnr = vim.api.nvim_get_current_buf()
    pcall(function() colorizer.detach_from_buffer(bufnr) end)
    vim.api.nvim_buf_clear_namespace(bufnr, colorizer.ns or 0, 0, -1)
    colorizer.attach_to_buffer(bufnr)
end, { desc = "Force reload Colorizer for current buffer" })
vim.keymap.set("n", "<leader>cd", function() vim.cmd("ColorizerDetachFromBuffer") end,
    { desc = "Detach Colorizer from current buffer" });

vim.keymap.set("n", "<leader>ct", function() vim.cmd("ColorizerToggle") end, { desc = "Toggle Colorizer" });

vim.api.nvim_create_user_command("ReloadColorscheme", function()
    -- Reload colorscheme
    --   vim.o.background = "dark";
    vim.cmd("colorscheme gruvbox")

    apply_custom_highlights()

    -- Reattach Colorizer if needed
    if package.loaded["colorizer"] then
        require("colorizer").attach_to_buffer(0)
    end
end, { desc = "Reload Gruvbox colorscheme and highlights" })
vim.keymap.set("n", "<leader>rc", ":ReloadColorscheme<CR>", { desc = "Reload Colorscheme" })

-- tree-sitter highlight fix after colorscheme reload
vim.keymap.set("n", "<leader>tsh", ":TSHighlightCapturesUnderCursor<CR>", { desc = "TSHighlightCapturesUnderCursor" })

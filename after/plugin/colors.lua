-- custom colors
function ColorMyPencils(color)
	--color = color or "rose-pine"
	vim.cmd.colorscheme(color)

	-- transparent background
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none"})
	--vim.api.nvim_set_hl(0, "Normal", { blend = "none" })

    -- highlights
	--vim.api.nvim_set_hl(0, "Comment", { fg = "#00CED1" })
	--vim.api.nvim_set_hl(0, "Comment", { fg = "#33FF4E" })
	--vim.api.nvim_set_hl(0, "Comment", { fg = "#33EAFF" })
	vim.api.nvim_set_hl(0, "Comment", { fg = "#129C56" })
	vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })

    -- moving things from init.vim to lua
    --[[
" highlight Cursor guibg=#000000 ctermbg=black
" highlight Cursor ctermfg=black ctermbg=black cterm=bold guifg=black guibg=yellow gui=bold
" @hey add this to a command in colors
:set cursorline
":highlight CursorLineNr guifg="#000000"
hi Cursor guifg=black guibg=red
set guicursor=n-v-c:block-Cursor/lCursor
--]]


end

-- set specific colorscheme
--vim.cmd("colorscheme github_dark_dimmed");
--vim.cmd("colorscheme tokyonight-moon");
--vim.o.background = "dark";
--[[
require("gruvbox").setup({
    invert_selection = true,
    contrast = "hard",
    overrides = {
        Cursor = {bg = "#000000", fg = "#000000"}
    }
});
--]]

--vim.o.background = "light";
vim.o.background = "dark";
vim.cmd("colorscheme gruvbox");

--ColorMyPencils()
vim.keymap.set("n", "<leader>cmp", ColorMyPencils);

-- colorizer map
vim.keymap.set("n", "<leader>ca", vim.cmd("ColorizerAttachToBuffer"));
vim.keymap.set("n", "<leader>cd", vim.cmd("ColorizerDetachFromBuffer"));
vim.keymap.set("n", "<leader>ct", vim.cmd("ColorizerToggle"));

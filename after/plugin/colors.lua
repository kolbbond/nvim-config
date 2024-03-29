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


end

--vim.cmd("colorscheme github_dark_dimmed");
vim.cmd("colorscheme tokyonight-moon");

--ColorMyPencils()
vim.keymap.set("n", "<leader>cmp", ColorMyPencils);

-- colorizer map
vim.keymap.set("n", "<leader>ca", vim.cmd("ColorizerAttachToBuffer"));
vim.keymap.set("n", "<leader>cd", vim.cmd("ColorizerDetachFromBuffer"));
vim.keymap.set("n", "<leader>ct", vim.cmd("ColorizerToggle"));

-- additional options
--
--

-- try to turn off autocomments
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ 'r', 'o'})
	end,
})

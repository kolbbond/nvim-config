local lsp = require("lsp-zero");

lsp.preset("recommended");

-- lsp servers
-- remember to add @hey, matlab and clang
--[[
lsp.ensure_installed({
	'tsserver',
	'eslint',
	'sumneko_lua',
	'rust_analyzer',
});
--]]

-- try to get matlab
require'lspconfig'.matlab_ls.setup{
	settings = {
		matlab = {
			installPath = "$MATLAB_PATH"
		}
	}
};

-- lua specific
require("lspconfig").lua_ls.setup({
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
});

-- mason is how we setup lsp
require('mason').setup({})
require('mason-lspconfig').setup({
	ensure_installed = {'clangd','lua_ls', 'matlab_ls', 'cmake', 'texlab', 'pylsp','bashls'},
	handlers = { lsp.default_setup },
});


-- keymaps
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-Up>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-Down>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-y>'] = cmp.mapping.confirm({ select = true }),
	['<C-Enter>'] = cmp.mapping.confirm({ select = true }),
	['<C-Space>'] = cmp.mapping.confirm({ select = true }),
	['<C-l>'] = cmp.mapping.confirm({ select = true }),
	--['<C-Space>'] = cmp.mapping.complete();
});

-- sign icons
--[[
lsp.set_preferences({
	sign_icons = {}
});
--]]
--

cmp_action = require('lsp-zero').cmp_action();
cmp.setup({
	mapping = cmp_mappings
})

--[[
lsp.setup_nvim_cmp({
	mapping = cmp_mappings
});
--]]

-- lsp setup remap only in buffer
lsp.on_attach(function(client, bufnr)
	--print("help")
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("n", "<C-q>", function() vim.lsp.buf.signature_help() end, opts)

end);

lsp.setup();

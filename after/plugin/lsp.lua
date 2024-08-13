local lsp = require("lsp-zero");

lsp.preset("recommended");


-- mason is how we setup lsp
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'clangd', 'lua_ls',
        --        'matlab_ls', 'bashls'
    },
    handlers = {
        lsp.default_setup,
    },
});

-- matlab lsp
--[[
require("lspconfig").matlab_ls.setup({
    settings = {
        MATLAB = {
            indexWorkspace = true,
            --installPath = vim.env.MATLAB_PATH,
            installPath = vim.env.Matlab_ROOT_DIR,
            telemetry = false,
        },
    },
    single_file_support = true,
});
--]]

-- clangd
--[[
require("lspconfig").clangd.setup({
    root_files = {vim.env.CLANG_FORMAT}
});
--]]
require("lspconfig").clangd.setup({
    cmd = { "clangd", "--header-insertion=never", }
});

--vim.lsp.set_log_level("debug");

-- keymaps
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
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


-- lsp setup remap only in buffer
lsp.on_attach(function(client, bufnr)
    --print("help")
    local opts = { buffer = bufnr, remap = false }

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

    -- vim.keymap.set("n", "<leader>sh", vim.cmd("ClangdSwitchSourceHeader"));
    --vim.keymap.set("n", "<leader>sh", "<cmd>!ClangdSwitchSourceHeader<CR>");
end);

function clang_switch()
    vim.cmd("ClangdSwitchSourceHeader");
end

vim.keymap.set("n", "<leader>sh", clang_switch);


-- clang switch header

-- lsp auto format keymap
vim.keymap.set("n", "<leader>af", function()
    vim.lsp.buf.format({
        async = false, timeout_ms = 10000 })
end)


lsp.setup();

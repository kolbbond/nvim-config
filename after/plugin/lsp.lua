local lsp = require("lsp-zero");

lsp.preset("recommended");

--vim.o.winborder = "rounded"

-- mason is how we setup lsp
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'clangd', 'lua_ls', 'pylsp'
        --'matlab_ls',
    },
    handlers = {
        lsp.default_setup,
    },
});

-- matlab lsp
-- set Matlab_ROOT_DIR as cmake also uses this environment variable??
-- @hey:, or is this just cmake internal variable?
require("lspconfig").matlab_ls.setup({
    settings = {
        MATLAB = {
            indexWorkspace = true,
            installPath = vim.env.Matlab_ROOT_DIR,
            telemetry = false,
        },
    },
    single_file_support = true,
});

-- clangd
require("lspconfig").clangd.setup({
    -- auto-insert headers is annoying
    cmd = { "clangd", "--header-insertion=never", },
    -- Add the exclude pattern here
    exclude_patterns = { "bak/*", "bak/**/*" },
    --root_files = {vim.env.CLANG_FORMAT}, -- use custom clang format
});

--[[
require("lspconfig").arduino_language_server.setup({
    filetypes = { 'ino', 'cpp' },
});
--]]


-- hyprls
--require("lspconfig").hyprls.setup({});

require("lspconfig").pylsp.setup({
});

-- lua
require("lspconfig").lua_ls.setup({
    settings =
    {
        Lua = {
            diagnostics =
            {
                -- stop warning about global "vim"
                globals =
                {
                    "vim",
                    "require"
                }
            }
        }
    }
});

-- bash
--require("lspconfig").bashls.setup({});
--require("lspconfig").fortls.setup({});

-- debug options
--vim.lsp.set_log_level("debug");

-- keymaps
-- this is navigation in the lsp buffer list
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
});
cmp_action = require('lsp-zero').cmp_action();
cmp.setup({
    mapping = cmp_mappings
})

-- sign icons
-- try ':Telescope symbols' to select others
lsp.set_sign_icons({
    error = '🩸',
    warn = '',
    hint = '',
    info = '❔'
}
);
--

-- lsp setup remap
-- only when lsp buffer is attached to file
-- check this for information on functions/definitions etc.
lsp.on_attach(function(client, bufnr)
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
end);

-- remap to switch between source and header files
-- requires that clangd can find them
-- Cmake can do this automatically by setting
-- "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)" in your "CMakeLists.txt"
function clang_switch()
    vim.cmd("ClangdSwitchSourceHeader");
end

vim.keymap.set("n", "<leader>sh", clang_switch);

-- lsp auto format keymap
vim.keymap.set("n", "<leader>af", function()
    vim.lsp.buf.format({
        async = false, timeout_ms = 1000 })
end)

-- End
lsp.setup();

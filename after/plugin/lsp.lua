local ok, lsp = pcall(require, "lsp-zero")
if not ok then return end

lsp.preset("recommended");

--vim.o.winborder = "rounded"

-- mason is how we setup lsp
local mason_ok, mason = pcall(require, 'mason')
if not mason_ok then return end
mason.setup({
    -- Force public PyPI for pip-based installs (pylsp, etc.) so Mason
    -- doesn't inherit the internal index from global pip.conf/PIP_INDEX_URL.
    pip = {
        install_args = { "--index-url", "https://pypi.org/simple" },
    },
})
local mason_lsp_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mason_lsp_ok then return end
mason_lspconfig.setup({
    ensure_installed = { 'clangd', 'lua_ls', 'pylsp'
        --'matlab_ls',
    },
    handlers = {
        lsp.default_setup,
    },
});

-- matlab lsp
-- set Matlab_ROOT_DIR as cmake also uses this environment variable??
vim.lsp.config("matlab_ls.setup", {
    settings = {
        MATLAB = {
            indexWorkspace = true,
            installPath = vim.env.Matlab_ROOT_DIR,
            telemetry = false,
        },
    },
    single_file_support = true,
});
--vim.lsp.enable("matlab_ls.setup");

-- clangd
vim.lsp.config("clangd", {
    -- auto-insert headers is annoying
    cmd = { "clangd", "--header-insertion=never", "--clang-tidy" },
    -- Add the exclude pattern here
    exclude_patterns = { "bak/*", "bak/**/*" },
    --root_files = {vim.env.CLANG_FORMAT}, -- use custom clang format
});
vim.lsp.enable("clangd");

-- python
vim.lsp.config("pylsp", {
    timeout = 10000,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = true, -- easiest: turn it off completely
                    ignore = { "E302", "E305" }
                },
            },
        },
    },

    on_attach = function(_, bufnr)
        vim.keymap.set({ "n", "v" }, "<C-l>", "<cmd>SlimeSend<CR>", {
            buffer = bufnr,
            silent = true,
            desc = "Send to REPL (pylsp attached)",
        })
    end,
})
vim.lsp.enable("pylsp")

-- lua
vim.lsp.config("lua_ls", {
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
vim.lsp.enable("lua_ls");

-- blink.cmp provides capabilities to LSP servers
local blink_ok, blink = pcall(require, 'blink.cmp')
if blink_ok then
    local lspconfig = require('lspconfig')
    local capabilities = blink.get_lsp_capabilities()
    -- apply to all servers via lspconfig default
    lspconfig.util.default_config = vim.tbl_deep_extend(
        'force',
        lspconfig.util.default_config,
        { capabilities = capabilities }
    )
end

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

--[[
require("lspconfig").arduino_language_server.setup({
    filetypes = { 'ino', 'cpp' },
});
--]]


-- hyprls
--require("lspconfig").hyprls.setup({});

lsp.setup();

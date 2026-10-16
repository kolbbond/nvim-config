-- native LSP (nvim 0.11+): mason installs servers, vim.lsp.config/enable runs them.
-- Server defaults come from nvim-lspconfig's lsp/*.lua; blink.cmp injects
-- capabilities itself via vim.lsp.config('*').

local mason_ok, mason = pcall(require, 'mason')
if not mason_ok then return end
mason.setup({
    -- Force public PyPI for pip-based installs (pylsp, etc.) so Mason
    -- doesn't inherit the internal index from global pip.conf/PIP_INDEX_URL.
    pip = {
        install_args = { "--index-url", "https://pypi.org/simple" },
    },
})

local servers = { 'clangd', 'lua_ls', 'pylsp', 'marksman' }

local mason_lsp_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if mason_lsp_ok then
    mason_lspconfig.setup({
        ensure_installed = servers,
        -- enable from `servers` only; auto-enable would also start every
        -- other mason-installed server (e.g. markdown-oxide next to marksman)
        automatic_enable = false,
    })
end

-- set Matlab_ROOT_DIR as cmake also uses this environment variable
if vim.env.Matlab_ROOT_DIR then
    vim.lsp.config("matlab_ls", {
        settings = {
            MATLAB = {
                indexWorkspace = true,
                installPath = vim.env.Matlab_ROOT_DIR,
                telemetry = false,
            },
        },
    })
    table.insert(servers, 'matlab_ls')
end

vim.lsp.config("clangd", {
    -- auto-insert headers is annoying
    cmd = { "clangd", "--header-insertion=never", "--clang-tidy" },
})

vim.lsp.config("pylsp", {
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = true,
                    ignore = { "E302", "E305" }
                },
            },
        },
    },
})

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = {
                -- stop warning about global "vim"
                globals = { "vim", "require" },
            },
        },
    },
})

vim.lsp.enable(servers)

vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '🩸',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '❔',
        },
    },
})

-- nvim 0.11+ already maps K, grn/gra/grr/gri, and ]d/[d; these are the extras
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kolbbond_lsp_attach', { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
        map("n", "<leader>vd", vim.diagnostic.open_float, "Line diagnostics")
        map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>vrr", vim.lsp.buf.references, "References")
        map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename")
        map("n", "<C-q>", vim.lsp.buf.signature_help, "Signature help")

        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'pylsp' then
            map({ "n", "v" }, "<C-l>", "<cmd>SlimeSend<CR>", "Send to REPL")
        end
    end,
})

-- needs compile_commands.json to find pairs (CMAKE_EXPORT_COMPILE_COMMANDS ON)
vim.keymap.set("n", "<leader>sh", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "Switch source/header" })

-- <leader>a* is the claude namespace, so format lives on <leader>F
vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
end, { desc = "Format buffer" })

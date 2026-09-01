-- test_config.lua — Full Neovim config test suite
-- Run: nvim --headless -c "luafile test_config.lua" -c "qa!"
--
-- Exit code 0 = all passed, non-zero = failures detected

local passed, failed, skipped = 0, 0, 0
local failures = {}

local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print("  PASS  " .. name)
    else
        failed = failed + 1
        failures[#failures + 1] = { name = name, err = tostring(err) }
        print("  FAIL  " .. name .. " -- " .. tostring(err))
    end
end

local function skip(name, reason)
    skipped = skipped + 1
    print("  SKIP  " .. name .. " -- " .. reason)
end

local function try_require(mod)
    local ok, m = pcall(require, mod)
    assert(ok, mod .. " failed to load: " .. tostring(m))
    assert(m ~= nil, mod .. " returned nil")
    return m
end

local function has_exe(name)
    return vim.fn.executable(name) == 1
end

-- ═══════════════════════════════════════════
print("\n══════════════════════════════════════")
print("  NEOVIM CONFIG TEST SUITE")
print("══════════════════════════════════════\n")

-- ───────────────────────────────────────────
print("[core]")
-- ───────────────────────────────────────────

test("plenary loads", function() try_require("plenary") end)

test("treesitter loads", function()
    -- verify the plugin itself is present
    local parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"
    assert(vim.fn.isdirectory(parser_dir) == 1, "nvim-treesitter not installed")
end)

-- individual parser tests so you see exactly which are missing
for _, lang in ipairs({ "lua", "python", "c", "vim", "cpp", "markdown" }) do
    test("treesitter parser: " .. lang, function()
        local ok = pcall(vim.treesitter.language.inspect, lang)
        assert(ok, "run :TSInstall " .. lang)
    end)
end

test("nvim-web-devicons loads", function() try_require("nvim-web-devicons") end)
test("nvim-notify loads", function()
    local notify = try_require("notify")
    assert(vim.notify == notify, "vim.notify not overridden by nvim-notify")
end)
test("dressing loads", function() try_require("dressing") end)
test("colorizer loads", function() try_require("colorizer") end)
test("color-picker loads", function() try_require("color-picker") end)
test("rainbow-delimiters loads", function() try_require("rainbow-delimiters") end)

-- ───────────────────────────────────────────
print("\n[completion]")
-- ───────────────────────────────────────────

test("blink.cmp loads", function() try_require("blink.cmp") end)

test("blink.cmp exposes get_lsp_capabilities", function()
    local blink = require("blink.cmp")
    assert(type(blink.get_lsp_capabilities) == "function", "missing get_lsp_capabilities")
    local caps = blink.get_lsp_capabilities()
    assert(type(caps) == "table", "capabilities not a table")
    assert(caps.textDocument, "capabilities missing textDocument")
end)

test("blink-cmp-copilot loads", function() try_require("blink-cmp-copilot") end)
test("luasnip loads", function() try_require("luasnip") end)
test("lspkind loads", function() try_require("lspkind") end)

test("nvim-cmp is NOT present", function()
    local ok, _ = pcall(require, "cmp")
    assert(not ok, "nvim-cmp should be removed but is still loadable")
end)

-- ───────────────────────────────────────────
print("\n[lsp]")
-- ───────────────────────────────────────────

test("lsp-zero loads", function() try_require("lsp-zero") end)
test("lspconfig loads", function() try_require("lspconfig") end)
test("mason loads", function() try_require("mason") end)
test("mason-lspconfig loads", function() try_require("mason-lspconfig") end)

test("lsp servers registered", function()
    local lspconfig = require("lspconfig")
    -- these should be configured via after/plugin/lsp.lua
    for _, server in ipairs({ "clangd", "lua_ls", "pylsp" }) do
        local cfg = lspconfig[server]
        assert(cfg, "lspconfig missing server: " .. server)
    end
end)

test("copilot.lua loads", function() try_require("copilot") end)
test("fidget loads", function() try_require("fidget") end)

-- ───────────────────────────────────────────
print("\n[ui]")
-- ───────────────────────────────────────────

test("telescope loads", function() try_require("telescope") end)
test("telescope.builtin loads", function() try_require("telescope.builtin") end)
test("harpoon loads", function() try_require("harpoon") end)
test("trouble loads", function() try_require("trouble") end)
test("oil loads", function() try_require("oil") end)
test("neo-tree loads", function() try_require("neo-tree") end)
test("which-key loads", function() try_require("which-key") end)
test("toggleterm loads", function() try_require("toggleterm") end)
test("project_nvim loads", function() try_require("project_nvim") end)
test("lualine loads", function() try_require("lualine") end)
test("alpha loads", function() try_require("alpha") end)
test("mini.animate loads", function() try_require("mini.animate") end)
test("mini.map loads", function() try_require("mini.map") end)

-- ───────────────────────────────────────────
print("\n[tools]")
-- ───────────────────────────────────────────

test("todo-comments loads", function() try_require("todo-comments") end)
test("nvim-surround loads", function() try_require("nvim-surround") end)

test("undotree command exists", function()
    assert(vim.fn.exists(":UndotreeToggle") == 2, "UndotreeToggle command missing")
end)

test("fugitive command exists", function()
    assert(vim.fn.exists(":Git") == 2, "Git (fugitive) command missing")
end)

test("asyncrun command exists", function()
    assert(vim.fn.exists(":AsyncRun") == 2, "AsyncRun command missing")
end)

test("suda command exists", function()
    assert(vim.fn.exists(":SudaWrite") == 2, "SudaWrite command missing")
end)

-- ───────────────────────────────────────────
print("\n[debug]")
-- ───────────────────────────────────────────

if has_exe("gdb") or has_exe("codelldb") then
    test("nvim-dap loads", function() try_require("dap") end)

    test("dap adapters configured", function()
        local dap = require("dap")
        -- at least one adapter should exist
        local count = 0
        for _ in pairs(dap.adapters or {}) do count = count + 1 end
        assert(count > 0, "no DAP adapters configured")
    end)

    test("nvim-dap-ui loads", function() try_require("dapui") end)
    test("nvim-dap-virtual-text loads", function() try_require("nvim-dap-virtual-text") end)
    test("nvim-nio loads", function() try_require("nio") end)
else
    skip("nvim-dap", "gdb/codelldb not found")
    skip("nvim-dap-ui", "gdb/codelldb not found")
end

test("neotest loads", function() try_require("neotest") end)

-- ───────────────────────────────────────────
print("\n[repl]")
-- ───────────────────────────────────────────

test("iron loads", function() try_require("iron.core") end)

test("vim-slime loaded", function()
    assert(vim.g.slime_target ~= nil or vim.fn.exists(":SlimeSend") >= 1,
        "vim-slime not configured")
end)

test("jupynium loads", function() try_require("jupynium") end)

if has_exe("magick") then
    test("molten loads", function() try_require("molten") end)
    test("image.nvim loads", function() try_require("image") end)
else
    skip("molten", "magick not found")
    skip("image.nvim", "magick not found")
end

-- ───────────────────────────────────────────
print("\n[keymaps]")
-- ───────────────────────────────────────────

test("leader is space", function()
    assert(vim.g.mapleader == " ", "mapleader is not space, got: " .. tostring(vim.g.mapleader))
end)

-- spot-check critical keymaps exist
local function keymap_exists(mode, lhs)
    local maps = vim.api.nvim_get_keymap(mode)
    for _, m in ipairs(maps) do
        if m.lhs == lhs or m.lhs:gsub("<Space>", " ") == lhs:gsub("<leader>", " ") then
            return true
        end
    end
    return false
end

test("telescope find_files mapped (<leader>pf)", function()
    assert(keymap_exists("n", " pf"), "missing <leader>pf mapping")
end)

test("undotree mapped (<leader>ut)", function()
    assert(keymap_exists("n", " ut"), "missing <leader>ut mapping")
end)

test("lsp format mapped (<leader>af)", function()
    assert(keymap_exists("n", " af"), "missing <leader>af mapping")
end)

test("fugitive mapped (<leader>gs)", function()
    assert(keymap_exists("n", " gs"), "missing <leader>gs mapping")
end)

-- ───────────────────────────────────────────
print("\n[health]")
-- ───────────────────────────────────────────

test("no duplicate plugin loads", function()
    -- check that lazy hasn't loaded two versions of anything
    local lazy_config = require("lazy.core.config")
    local names = {}
    for _, plugin in pairs(lazy_config.plugins) do
        local name = plugin.name
        assert(not names[name], "duplicate plugin: " .. name)
        names[name] = true
    end
end)

test("lazy reports no broken plugins", function()
    local lazy_config = require("lazy.core.config")
    local broken = {}
    for _, plugin in pairs(lazy_config.plugins) do
        if plugin._.kind == "disabled" then
            -- skip intentionally disabled plugins
        elseif plugin._.installed == false then
            broken[#broken + 1] = plugin.name
        end
    end
    assert(#broken == 0, "not installed: " .. table.concat(broken, ", "))
end)

test("nvim version >= 0.10", function()
    local v = vim.version()
    assert(v.major > 0 or v.minor >= 10,
        string.format("need >= 0.10, got %d.%d.%d", v.major, v.minor, v.patch))
end)

-- ═══════════════════════════════════════════
print("\n══════════════════════════════════════")
print(string.format("  RESULTS: %d passed, %d failed, %d skipped",
    passed, failed, skipped))
print("══════════════════════════════════════")

if #failures > 0 then
    print("\nFailed tests:")
    for _, f in ipairs(failures) do
        print("  - " .. f.name)
        print("    " .. f.err)
    end
    print("")
    vim.cmd("cq!") -- exit code 1
end

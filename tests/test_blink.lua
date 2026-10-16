-- test_blink.lua — run with: nvim --headless -u init.lua -c "luafile test_blink.lua" -c "qa!"
local passed, failed = 0, 0

local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print("  PASS: " .. name)
    else
        failed = failed + 1
        print("  FAIL: " .. name .. " — " .. tostring(err))
    end
end

print("\n=== blink.cmp migration tests ===\n")

-- 1. blink.cmp loads
test("blink.cmp loads", function()
    local blink = require("blink.cmp")
    assert(blink, "blink.cmp module is nil")
end)

-- 2. blink-cmp-copilot loads
test("blink-cmp-copilot loads", function()
    local copilot = require("blink-cmp-copilot")
    assert(copilot, "blink-cmp-copilot module is nil")
end)

-- 3. LuaSnip loads
test("LuaSnip loads", function()
    local ls = require("luasnip")
    assert(ls, "luasnip module is nil")
end)

-- 4. old nvim-cmp is NOT loaded
test("nvim-cmp is NOT loaded", function()
    local ok, _ = pcall(require, "cmp")
    assert(not ok, "nvim-cmp should not be loadable anymore")
end)

-- 5. lsp-zero loads
test("lsp-zero loads", function()
    local lsp = require("lsp-zero")
    assert(lsp, "lsp-zero module is nil")
end)

-- 6. copilot.lua loads
test("copilot.lua loads", function()
    local copilot = require("copilot")
    assert(copilot, "copilot module is nil")
end)

-- 7. blink.cmp has get_lsp_capabilities
test("blink.cmp exposes get_lsp_capabilities", function()
    local blink = require("blink.cmp")
    assert(type(blink.get_lsp_capabilities) == "function", "get_lsp_capabilities missing")
    local caps = blink.get_lsp_capabilities()
    assert(type(caps) == "table", "capabilities should be a table")
end)

-- 8. lspkind loads
test("lspkind loads", function()
    local lspkind = require("lspkind")
    assert(lspkind, "lspkind module is nil")
end)

-- summary
print(string.format("\n=== Results: %d passed, %d failed ===\n", passed, failed))
if failed > 0 then
    vim.cmd("cq!") -- exit with error code
end

-- tests/test_claude_throw.lua -- unit tests for the tier-2 throw module
-- Run: nvim --headless -c "luafile tests/test_claude_throw.lua" -c "qa!"
-- Exit code 0 = all passed, non-zero = failures detected

local passed, failed = 0, 0
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

local ct = require("kolbbond.claude_throw")

-- ── session_name ────────────────────────────────────────────
test("session_name uses the basename", function()
    assert(ct.session_name("/home/ohr4/defcon/nvim-config") == "claude-bg-nvim-config",
        "got: " .. tostring(ct.session_name("/home/ohr4/defcon/nvim-config")))
end)

test("session_name sanitizes dots (tmux window separator)", function()
    assert(ct.session_name("/home/ohr4/defcon.nvim") == "claude-bg-defcon-nvim",
        "got: " .. tostring(ct.session_name("/home/ohr4/defcon.nvim")))
end)

test("session_name sanitizes colons (tmux session separator)", function()
    assert(ct.session_name("/a/b:c") == "claude-bg-b-c",
        "got: " .. tostring(ct.session_name("/a/b:c")))
end)

test("session_name sanitizes whitespace", function()
    assert(ct.session_name("/a/my project") == "claude-bg-my-project",
        "got: " .. tostring(ct.session_name("/a/my project")))
end)

-- ── compose ─────────────────────────────────────────────────
test("compose renders a line range", function()
    local got = ct.compose("src/a.cpp", { first = 42, last = 77 }, "why does this allocate?")
    assert(got == "@src/a.cpp (lines 42-77): why does this allocate?", "got: " .. tostring(got))
end)

test("compose renders without a range", function()
    local got = ct.compose("src/a.cpp", nil, "explain this file")
    assert(got == "@src/a.cpp: explain this file", "got: " .. tostring(got))
end)

test("compose trims the question", function()
    local got = ct.compose("a.c", nil, "   hello   ")
    assert(got == "@a.c: hello", "got: " .. tostring(got))
end)

test("compose refuses an empty question", function()
    local got, err = ct.compose("a.c", nil, "   ")
    assert(got == nil, "expected nil for whitespace-only question")
    assert(err ~= nil, "expected an error message")
end)

test("compose refuses a nil question", function()
    local got = ct.compose("a.c", nil, nil)
    assert(got == nil, "expected nil for nil question")
end)

-- ═══════════════════════════════════════════
print(string.format("\n  RESULTS: %d passed, %d failed", passed, failed))
if #failures > 0 then
    print("\nFailed tests:")
    for _, f in ipairs(failures) do
        print("  - " .. f.name .. "\n    " .. f.err)
    end
    vim.cmd("cq!") -- exit code 1
end

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

-- ── tmux shell (runner stubbed) ─────────────────────────────
-- Swap the seam so no live tmux is needed. Each stub records the argv it saw.
local function with_stub(responses, fn)
    local real = ct.runner
    local calls = {}
    local i = 0
    ct.runner = function(cmd)
        i = i + 1
        calls[#calls + 1] = cmd
        return responses[i] or { code = 0, stdout = "", stderr = "" }
    end
    local ok, err = pcall(fn, calls)
    ct.runner = real
    if not ok then error(err, 0) end
end

test("repo_root returns the git toplevel", function()
    with_stub({ { code = 0, stdout = "/repo/root\n", stderr = "" } }, function()
        assert(ct.repo_root("/repo/root/src/a.c") == "/repo/root",
            "did not return the toplevel")
    end)
end)

test("repo_root falls back to the directory outside a repo", function()
    with_stub({ { code = 128, stdout = "", stderr = "not a git repo" } }, function()
        assert(ct.repo_root("/tmp/loose/a.c") == "/tmp/loose",
            "did not fall back to the containing dir")
    end)
end)

test("session_exists uses an exact-match target", function()
    with_stub({ { code = 0, stdout = "", stderr = "" } }, function(calls)
        ct.session_exists("claude-bg-x")
        assert(vim.deep_equal(calls[1], { "tmux", "has-session", "-t", "=claude-bg-x" }),
            "wrong argv: " .. vim.inspect(calls[1]))
    end)
end)

test("ensure_session creates the session when absent", function()
    with_stub({
        { code = 1, stdout = "", stderr = "" },  -- has-session: no
        { code = 0, stdout = "", stderr = "" },  -- new-session: ok
    }, function(calls)
        local ok = ct.ensure_session("claude-bg-x", "/repo/root")
        assert(ok, "ensure_session reported failure")
        assert(vim.deep_equal(calls[2],
            { "tmux", "new-session", "-d", "-s", "claude-bg-x", "-c", "/repo/root", "claude" }),
            "wrong argv: " .. vim.inspect(calls[2]))
    end)
end)

test("ensure_session does not recreate an existing session", function()
    with_stub({ { code = 0, stdout = "", stderr = "" } }, function(calls)
        assert(ct.ensure_session("claude-bg-x", "/repo/root"), "reported failure")
        assert(#calls == 1, "should not have called new-session")
    end)
end)

test("ensure_session surfaces tmux stderr on failure", function()
    with_stub({
        { code = 1, stdout = "", stderr = "" },
        { code = 1, stdout = "", stderr = "no server running" },
    }, function()
        local ok, err = ct.ensure_session("claude-bg-x", "/repo/root")
        assert(not ok, "should have failed")
        assert(err:match("no server running"), "stderr not surfaced: " .. tostring(err))
    end)
end)

test("throw sends literal text then Enter separately", function()
    with_stub({}, function(calls)
        assert(ct.throw("press Enter now", "claude-bg-x"), "throw reported failure")
        assert(vim.deep_equal(calls[1],
            { "tmux", "send-keys", "-t", "=claude-bg-x", "-l", "--", "press Enter now" }),
            "wrong text argv: " .. vim.inspect(calls[1]))
        assert(vim.deep_equal(calls[2],
            { "tmux", "send-keys", "-t", "=claude-bg-x", "Enter" }),
            "wrong Enter argv: " .. vim.inspect(calls[2]))
    end)
end)

test("throw never builds a shell string", function()
    with_stub({}, function(calls)
        ct.throw("rm -rf / ; echo $(whoami)", "claude-bg-x")
        for _, cmd in ipairs(calls) do
            assert(type(cmd) == "table", "argv must be a list, got " .. type(cmd))
            assert(cmd[1] == "tmux", "first arg must be the tmux binary")
        end
    end)
end)

-- ── availability / navigation ───────────────────────────────
local function without_tmux(fn)
    local real = vim.env.TMUX
    vim.env.TMUX = nil
    local ok, err = pcall(fn)
    vim.env.TMUX = real
    if not ok then error(err, 0) end
end

test("available() fails outside tmux", function()
    without_tmux(function()
        local ok, err = ct.available()
        assert(not ok, "available() should fail with TMUX unset")
        assert(err:match("tmux"), "error should mention tmux: " .. tostring(err))
    end)
end)

test("goto_session refuses outside tmux and names the attach command", function()
    without_tmux(function()
        local ok, err = ct.goto_session("claude-bg-x")
        assert(not ok, "goto_session should fail with TMUX unset")
        assert(err:match("tmux attach %-t claude%-bg%-x"),
            "should suggest the attach command: " .. tostring(err))
    end)
end)

test("goto_session uses an exact-match target", function()
    vim.env.TMUX = vim.env.TMUX or "fake"
    with_stub({ { code = 0, stdout = "", stderr = "" } }, function(calls)
        ct.goto_session("claude-bg-x")
        assert(vim.deep_equal(calls[1],
            { "tmux", "switch-client", "-t", "=claude-bg-x" }),
            "wrong argv: " .. vim.inspect(calls[1]))
    end)
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

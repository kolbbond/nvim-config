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
        { code = 1, stdout = "", stderr = "" },      -- has-session: no
        { code = 0, stdout = "", stderr = "" },      -- new-session: ok
        { code = 0, stdout = "❯ ", stderr = "" },    -- capture: ready
    }, function(calls)
        local ok = ct.ensure_session("claude-bg-x", "/repo/root", 5000, 10)
        assert(ok, "ensure_session reported failure")
        assert(vim.deep_equal(calls[2],
            { "tmux", "new-session", "-d", "-s", "claude-bg-x", "-c", "/repo/root", "claude" }),
            "wrong argv: " .. vim.inspect(calls[2]))
    end)
end)

test("ensure_session does not recreate an existing session", function()
    with_stub({
        { code = 0, stdout = "", stderr = "" },      -- has-session: yes
        { code = 0, stdout = "❯ ", stderr = "" },    -- capture: ready
    }, function(calls)
        assert(ct.ensure_session("claude-bg-x", "/repo/root", 5000, 10), "reported failure")
        assert(calls[2][2] == "capture-pane",
            "2nd call should be the readiness poll, not new-session: " .. vim.inspect(calls[2]))
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
            { "tmux", "send-keys", "-t", "=claude-bg-x:", "-l", "--", "press Enter now" }),
            "wrong text argv: " .. vim.inspect(calls[1]))
        assert(vim.deep_equal(calls[2],
            { "tmux", "send-keys", "-t", "=claude-bg-x:", "Enter" }),
            "wrong Enter argv: " .. vim.inspect(calls[2]))
    end)
end)

test("send-keys uses the target-PANE form, has-session the target-SESSION form", function()
    -- Regression: tmux rejects "=name" for send-keys ("can't find pane: =name")
    -- because send-keys takes a target-pane, which needs the trailing ":".
    -- has-session takes a target-session and must NOT have it. Verified against
    -- real tmux; a self-consistent-but-wrong argv passes unit tests otherwise.
    with_stub({}, function(calls)
        ct.session_exists("claude-bg-x")
        assert(calls[1][4] == "=claude-bg-x",
            "has-session target must be =name, got: " .. tostring(calls[1][4]))
    end)
    with_stub({}, function(calls)
        ct.throw("hi", "claude-bg-x")
        assert(calls[1][4] == "=claude-bg-x:",
            "send-keys target must be =name:, got: " .. tostring(calls[1][4]))
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

-- ── readiness gating ────────────────────────────────────────
-- Regression: ensure_session used to return the instant `tmux new-session`
-- succeeded (~14ms), but Claude's TUI needs ~10s to boot. Text sent into the
-- not-yet-ready terminal got buffered and replayed into the input box while
-- the Enter was swallowed -- so the message sat there unsubmitted, and later
-- throws concatenated onto it.

test("readiness reports ready when the prompt is present", function()
    with_stub({ { code = 0, stdout = "some output\n❯ \n", stderr = "" } }, function()
        assert(ct.readiness("claude-bg-x") == "ready", "should be ready")
    end)
end)

test("readiness reports trust_prompt when the folder dialog is up", function()
    with_stub({ { code = 0, stdout = "❯ 1. Yes, I trust this folder\n", stderr = "" } }, function()
        assert(ct.readiness("claude-bg-x") == "trust_prompt", "should detect the trust dialog")
    end)
end)

test("readiness reports starting during boot", function()
    with_stub({ { code = 0, stdout = "  ▝▜██████▀  splash\n", stderr = "" } }, function()
        assert(ct.readiness("claude-bg-x") == "starting", "should still be starting")
    end)
end)

test("pane_text uses the target-PANE form", function()
    with_stub({}, function(calls)
        ct.pane_text("claude-bg-x")
        assert(vim.deep_equal(calls[1],
            { "tmux", "capture-pane", "-p", "-t", "=claude-bg-x:" }),
            "wrong argv: " .. vim.inspect(calls[1]))
    end)
end)

test("ensure_session waits for the TUI before returning", function()
    with_stub({
        { code = 1, stdout = "", stderr = "" },              -- has-session: no
        { code = 0, stdout = "", stderr = "" },              -- new-session: ok
        { code = 0, stdout = "splash", stderr = "" },        -- capture: starting
        { code = 0, stdout = "❯ ", stderr = "" },            -- capture: ready
    }, function(calls)
        local ok = ct.ensure_session("claude-bg-x", "/repo", 5000, 10)
        assert(ok, "ensure_session should succeed once ready")
        assert(#calls >= 4, "should have polled the pane, got " .. #calls .. " calls")
        assert(calls[3][2] == "capture-pane", "3rd call should poll the pane")
    end)
end)

test("ensure_session surfaces the trust prompt instead of silently failing", function()
    with_stub({
        { code = 1, stdout = "", stderr = "" },
        { code = 0, stdout = "", stderr = "" },
        { code = 0, stdout = "❯ 1. Yes, I trust this folder", stderr = "" },
    }, function()
        local ok, err = ct.ensure_session("claude-bg-x", "/repo", 5000, 10)
        assert(not ok, "should not report success while the trust dialog blocks input")
        assert(err:match("approve"), "error should tell the user to approve: " .. tostring(err))
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

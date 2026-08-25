# Two-Tier Claude Collaboration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Host the attached Claude in an nvim buffer (unlocking send-text and focus) and add a `claude_throw` module that sends file/selection context plus a question to a deliberately-detached Claude in its own tmux session.

**Architecture:** Two tiers with different transports. Tier 1 is `claudecode.nvim` reconfigured to `terminal.provider = "native"` — it keeps the IDE WebSocket and its live-buffer diffs. Tier 2 is a new Lua module talking to a per-repo tmux session via `tmux send-keys`, because a detached Claude has no socket. The tiers share no code.

**Tech Stack:** Lua, Neovim 0.12 (`vim.system`, `vim.ui.input`), lazy.nvim, tmux 3.6, `claudecode.nvim`.

**Spec:** `docs/superpowers/specs/2026-08-24-nvim-claude-two-tier-design.md`

## Global Constraints

- **Never build a shell string for tmux.** Every tmux invocation goes through `vim.system()` with an argument **list**. The question is arbitrary user text; interpolating it into `sh -c` is a quoting bug and a command-injection hole at once.
- **`tmux send-keys` must use `-l` and `--`.** Without `-l`, tmux interprets key *names* — a question containing "Enter" or "C-c" fires those keys instead of typing them. `--` stops a question beginning with `-` being parsed as flags.
- **tmux targets use the `=` exact-match prefix** (`-t "=claude-bg-foo"`). Target lookup is otherwise prefix-based, so `claude-bg-nv` would match `claude-bg-nvim-config`.
- **Session names sanitize `.` `:` and whitespace** — tmux treats `.` and `:` as target separators.
- Test harness is `test_config.lua`'s style: `test(name, fn)`, `assert`, results summary, `vim.cmd("cq!")` for a non-zero exit.
- Do not touch `<leader>af` (LSP/clang-format) or `<leader>aa` (harpoon).

---

### Task 1: Tier 1 — move the attached Claude in-buffer

**Files:**
- Modify: `lua/plugins/claude.lua` (whole file)
- Test: `test_config.lua` (append before the results banner)

**Interfaces:**
- Consumes: nothing.
- Produces: working `:ClaudeCodeSendText`, `:ClaudeCodeFocus`; keymap `<leader>aj` for focus. No Lua API for later tasks.

- [ ] **Step 1: Write the failing test**

Append to `test_config.lua`, immediately **before** the `-- ═══` results banner near the end:

```lua
test("claude focus mapped to <leader>aj (not shadowed <leader>af)", function()
    local m = vim.fn.maparg(" aj", "n", false, true)
    assert(m and next(m), "<leader>aj is not mapped")
    assert((m.desc or ""):match("Claude"), "<leader>aj is not the Claude focus map")
end)

test("<leader>af still belongs to format, not Claude", function()
    local m = vim.fn.maparg(" af", "n", false, true)
    assert(m and next(m), "<leader>af lost its mapping")
    assert(not (m.desc or ""):match("Claude"), "<leader>af was taken by Claude")
end)

test("<leader>aa still belongs to harpoon", function()
    local m = vim.fn.maparg(" aa", "n", false, true)
    assert(m and next(m), "<leader>aa lost its mapping")
    assert((m.desc or ""):match("harpoon"), "<leader>aa is not harpoon's")
end)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `nvim --headless -c "luafile test_config.lua" -c "qa!" 2>&1 | grep -E "claude focus|leader>af|leader>aa"`
Expected: `FAIL  claude focus mapped to <leader>aj` — the key does not exist yet.

- [ ] **Step 3: Rewrite `lua/plugins/claude.lua`**

Replace the entire file. This deletes the `external_terminal_cmd` function and the `vim.env.TMUX` branch — that machinery exists only to work around the tmux-server env trap, which `native` does not have.

```lua
-- Claude Code integration: drives the `claude` CLI (same WebSocket protocol as
-- the official IDE extensions), so it uses your existing Claude Code
-- subscription rather than a separate Anthropic API key.
--
-- TIER 1 of the two-tier workflow -- the ATTACHED Claude, hosted in an nvim
-- terminal buffer. See
-- docs/superpowers/specs/2026-08-24-nvim-claude-two-tier-design.md
--
-- `native` auto-attaches exactly like the old external/tmux provider: the
-- attach env (ENABLE_IDE_INTEGRATION, CLAUDE_CODE_SSE_PORT) is assembled in
-- claudecode's terminal.lua before any provider sees it, and termopen inherits
-- job env normally -- so no `-e` forwarding is needed. Native additionally
-- makes SendText and focus work, which `external` structurally cannot do (it
-- tracks a jobid, never a tmux pane id).
--
-- Tier 2 (the detached, throw-to session) lives in lua/kolbbond/claude_throw.lua.
return {
  {
    "coder/claudecode.nvim",
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd",
      "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny", "ClaudeCodeSendText",
    },
    opts = {
      terminal = { provider = "native" },
    },
    keys = {
      { "<leader>a",  nil,                            desc = "+claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",          desc = "Toggle Claude" },
      { "<leader>aj", "<cmd>ClaudeCodeFocus<cr>",     desc = "Jump to Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",     desc = "Add current buffer" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",  desc = "Deny Claude diff" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    },
  },
}
```

Note what changed: `<leader>af` → `<leader>aj`; `<leader>aa` (accept diff) removed entirely, since `:w` in the diff buffer is the accept gesture; `ClaudeCodeSendText` added to `cmd` so it lazy-loads.

- [ ] **Step 4: Run test to verify it passes**

Run: `nvim --headless -c "luafile test_config.lua" -c "qa!" 2>&1 | tail -20`
Expected: all three new tests PASS, and `0 failed`.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/claude.lua test_config.lua
git commit -m "claude: host attached Claude in-buffer via native provider"
```

---

### Task 2: Tier 2 — pure core of `claude_throw`

**Files:**
- Create: `lua/kolbbond/claude_throw.lua`
- Create: `tests/test_claude_throw.lua`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `M.runner(cmd: string[]) -> { code: integer, stdout: string, stderr: string }` — the single I/O seam; tests replace it.
  - `M.session_name(root: string) -> string`
  - `M.compose(relpath: string, range: {first: integer, last: integer}|nil, question: string|nil) -> string|nil, string|nil` (returns `nil, err` on empty question)

- [ ] **Step 1: Write the failing test**

Create `tests/test_claude_throw.lua`:

```lua
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `nvim --headless -c "luafile tests/test_claude_throw.lua" -c "qa!" 2>&1 | tail -20`
Expected: an error loading the module — `module 'kolbbond.claude_throw' not found`.

- [ ] **Step 3: Write the minimal implementation**

Create `lua/kolbbond/claude_throw.lua`:

```lua
-- Tier 2 of the two-tier Claude workflow: throw file/selection context plus a
-- question at a deliberately-DETACHED Claude living in its own tmux session.
--
-- See docs/superpowers/specs/2026-08-24-nvim-claude-two-tier-design.md
--
-- Why text and not the protocol: a detached Claude has no WebSocket, so
-- at-mentions are unavailable. Context travels as an "@path" reference, which
-- the background Claude resolves itself from its own cwd.

local M = {}

--- Single I/O seam. Tests replace this.
--- ALWAYS takes an argument LIST, never a shell string: the question is
--- arbitrary user text, and interpolating it into `sh -c` is simultaneously a
--- quoting bug and a command-injection hole.
---@param cmd string[]
---@return table  { code: integer, stdout: string, stderr: string }
function M.runner(cmd)
    local res = vim.system(cmd, { text = true }):wait()
    return {
        code = res.code,
        stdout = res.stdout or "",
        stderr = res.stderr or "",
    }
end

--- Derive the tmux session name for a repo root.
--- tmux treats "." and ":" as target separators, so an unsanitized
--- "defcon.nvim" would address a WINDOW rather than a session.
---@param root string
---@return string
function M.session_name(root)
    local base = vim.fn.fnamemodify(root, ":t")
    if base == "" then base = "root" end
    base = base:gsub("[%.:%s]", "-")
    return "claude-bg-" .. base
end

--- Build the text sent to the background Claude.
---@param relpath string        path relative to the session's cwd
---@param range table|nil       { first = <int>, last = <int> } or nil
---@param question string|nil
---@return string|nil text, string|nil err
function M.compose(relpath, range, question)
    if question == nil then return nil, "empty question" end
    question = vim.trim(question)
    if question == "" then return nil, "empty question" end

    if range and range.first and range.last then
        return string.format("@%s (lines %d-%d): %s",
            relpath, range.first, range.last, question)
    end
    return string.format("@%s: %s", relpath, question)
end

return M
```

- [ ] **Step 4: Run test to verify it passes**

Run: `nvim --headless -c "luafile tests/test_claude_throw.lua" -c "qa!" 2>&1 | tail -20`
Expected: `RESULTS: 9 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add lua/kolbbond/claude_throw.lua tests/test_claude_throw.lua
git commit -m "claude_throw: pure core (session naming, message composition)"
```

---

### Task 3: Tier 2 — tmux shell behind the seam

**Files:**
- Modify: `lua/kolbbond/claude_throw.lua` (append before `return M`)
- Modify: `tests/test_claude_throw.lua` (append before the results banner)

**Interfaces:**
- Consumes: `M.runner`, `M.session_name` from Task 2.
- Produces:
  - `M.available() -> boolean, string|nil`
  - `M.repo_root(path: string) -> string`
  - `M.session_exists(name: string) -> boolean`
  - `M.ensure_session(name: string, root: string) -> boolean, string|nil`
  - `M.throw(text: string, name: string) -> boolean, string|nil`
  - `M.goto_session(name: string) -> boolean, string|nil`

- [ ] **Step 1: Write the failing test**

Append to `tests/test_claude_throw.lua`, **before** the results banner:

```lua
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `nvim --headless -c "luafile tests/test_claude_throw.lua" -c "qa!" 2>&1 | tail -25`
Expected: FAILs such as `attempt to call field 'repo_root' (a nil value)`.

- [ ] **Step 3: Write the minimal implementation**

Append to `lua/kolbbond/claude_throw.lua`, **before** the final `return M`:

```lua
--- tmux target with the "=" exact-match prefix. Without it, target lookup is
--- prefix-based and "claude-bg-nv" would match "claude-bg-nvim-config".
---@param name string
---@return string
local function target(name)
    return "=" .. name
end

--- Is the background tier usable at all?
---@return boolean ok, string|nil err
function M.available()
    if vim.env.TMUX == nil or vim.env.TMUX == "" then
        return false, "not inside a tmux session"
    end
    if vim.fn.executable("tmux") == 0 then
        return false, "tmux not found on PATH"
    end
    return true
end

--- Git toplevel for a path, falling back to its containing directory.
---@param path string
---@return string
function M.repo_root(path)
    local dir = path
    if dir == nil or dir == "" then
        dir = vim.fn.getcwd()
    elseif vim.fn.isdirectory(dir) == 0 then
        dir = vim.fn.fnamemodify(dir, ":h")
    end

    local res = M.runner({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
    if res.code ~= 0 then return dir end

    local root = vim.trim(res.stdout)
    if root == "" then return dir end
    return root
end

---@param name string
---@return boolean
function M.session_exists(name)
    return M.runner({ "tmux", "has-session", "-t", target(name) }).code == 0
end

--- Find or create the background session, rooted at the repo.
---@param name string
---@param root string
---@return boolean ok, string|nil err
function M.ensure_session(name, root)
    if M.session_exists(name) then return true end

    local res = M.runner({
        "tmux", "new-session", "-d", "-s", name, "-c", root, "claude",
    })
    if res.code ~= 0 then
        return false, "tmux new-session failed: " .. vim.trim(res.stderr)
    end
    return true
end

--- Send text to the background session, then submit it.
--- `-l` sends the text LITERALLY: without it tmux interprets key names, so a
--- question containing "Enter" or "C-c" would fire those keys instead of being
--- typed. `--` stops a question beginning with "-" being parsed as flags.
---@param text string
---@param name string
---@return boolean ok, string|nil err
function M.throw(text, name)
    local res = M.runner({ "tmux", "send-keys", "-t", target(name), "-l", "--", text })
    if res.code ~= 0 then
        return false, "tmux send-keys failed: " .. vim.trim(res.stderr)
    end

    res = M.runner({ "tmux", "send-keys", "-t", target(name), "Enter" })
    if res.code ~= 0 then
        return false, "tmux send-keys Enter failed: " .. vim.trim(res.stderr)
    end
    return true
end

---@param name string
---@return boolean ok, string|nil err
function M.goto_session(name)
    if vim.env.TMUX == nil or vim.env.TMUX == "" then
        return false, "not inside tmux; attach with: tmux attach -t " .. name
    end

    local res = M.runner({ "tmux", "switch-client", "-t", target(name) })
    if res.code ~= 0 then
        return false, "tmux switch-client failed: " .. vim.trim(res.stderr)
    end
    return true
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `nvim --headless -c "luafile tests/test_claude_throw.lua" -c "qa!" 2>&1 | tail -25`
Expected: `RESULTS: 20 passed, 0 failed`.

- [ ] **Step 5: Commit**

```bash
git add lua/kolbbond/claude_throw.lua tests/test_claude_throw.lua
git commit -m "claude_throw: tmux session lifecycle and literal send-keys"
```

---

### Task 4: Tier 2 — commands, keymaps, and wiring

**Files:**
- Modify: `lua/kolbbond/claude_throw.lua` (append before `return M`)
- Modify: `lua/kolbbond/init.lua`
- Modify: `test_config.lua` (append before the results banner)

**Interfaces:**
- Consumes: everything from Tasks 2 and 3.
- Produces: `M.throw_current(opts)`, `M.setup()`; commands `:ClaudeThrow` (range-aware) and `:ClaudeGoto`; keymaps `<leader>at` (n + v) and `<leader>ag`.

- [ ] **Step 1: Write the failing test**

Append to `test_config.lua`, **before** the results banner:

```lua
test("claude_throw module loads", function()
    local ok, m = pcall(require, "kolbbond.claude_throw")
    assert(ok, "claude_throw failed to load: " .. tostring(m))
    assert(type(m.throw_current) == "function", "throw_current missing")
    assert(type(m.setup) == "function", "setup missing")
end)

test("ClaudeThrow command exists and takes a range", function()
    local cmds = vim.api.nvim_get_commands({})
    assert(cmds.ClaudeThrow, "ClaudeThrow command not registered")
    assert(cmds.ClaudeThrow.range, "ClaudeThrow must accept a range")
end)

test("ClaudeGoto command exists", function()
    assert(vim.api.nvim_get_commands({}).ClaudeGoto, "ClaudeGoto not registered")
end)

test("<leader>at mapped in normal and visual", function()
    for _, mode in ipairs({ "n", "v" }) do
        local m = vim.fn.maparg(" at", mode, false, true)
        assert(m and next(m), "<leader>at not mapped in mode " .. mode)
    end
end)

test("<leader>ag mapped", function()
    local m = vim.fn.maparg(" ag", "n", false, true)
    assert(m and next(m), "<leader>ag not mapped")
end)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `nvim --headless -c "luafile test_config.lua" -c "qa!" 2>&1 | grep -E "claude_throw|ClaudeThrow|ClaudeGoto|leader>at|leader>ag"`
Expected: `FAIL  ClaudeThrow command exists` — nothing calls `setup()` yet.

- [ ] **Step 3: Write the implementation**

First append to `lua/kolbbond/claude_throw.lua`, **before** the final `return M`:

```lua
--- Path relative to the session's cwd, so "@path" resolves for the background
--- Claude (which is rooted at the repo, not at nvim's cwd).
---@param file string
---@param root string
---@return string
local function relative_to(file, root)
    if root ~= "" and file:sub(1, #root + 1) == root .. "/" then
        return file:sub(#root + 2)
    end
    return file
end

--- Prompt for a question and throw it, with the current file/selection, at the
--- background Claude.
---@param opts table|nil  { range = <0|1|2>, line1 = <int>, line2 = <int> }
function M.throw_current(opts)
    opts = opts or {}

    local ok, err = M.available()
    if not ok then
        vim.notify("claude-throw: " .. err, vim.log.levels.ERROR)
        return
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("claude-throw: buffer has no file", vim.log.levels.ERROR)
        return
    end

    local root = M.repo_root(file)
    local name = M.session_name(root)
    local relpath = relative_to(file, root)

    local range = nil
    if opts.range and opts.range > 0 then
        range = { first = opts.line1, last = opts.line2 }
    end

    vim.ui.input({ prompt = "Ask background Claude: " }, function(question)
        -- Empty or cancelled: abort quietly. An empty send would submit a bare
        -- prompt to the background session.
        local text = M.compose(relpath, range, question)
        if not text then return end

        local ok2, err2 = M.ensure_session(name, root)
        if not ok2 then
            vim.notify("claude-throw: " .. err2, vim.log.levels.ERROR)
            return
        end

        local ok3, err3 = M.throw(text, name)
        if not ok3 then
            vim.notify("claude-throw: " .. err3, vim.log.levels.ERROR)
            return
        end

        vim.notify("thrown to " .. name, vim.log.levels.INFO)
    end)
end

--- Register commands and keymaps. Called from lua/kolbbond/init.lua.
function M.setup()
    vim.api.nvim_create_user_command("ClaudeThrow", function(o)
        M.throw_current({ range = o.range, line1 = o.line1, line2 = o.line2 })
    end, { range = true, desc = "Throw file/selection + question to background Claude" })

    vim.api.nvim_create_user_command("ClaudeGoto", function()
        local root = M.repo_root(vim.api.nvim_buf_get_name(0))
        local ok, err = M.goto_session(M.session_name(root))
        if not ok then
            vim.notify("claude-throw: " .. err, vim.log.levels.WARN)
        end
    end, { desc = "Switch to the background Claude tmux session" })

    -- Visual mode: ":" auto-inserts the '<,'> range, so o.range == 2 there and
    -- 0 in normal mode -- which is how throw_current tells file from selection.
    vim.keymap.set({ "n", "v" }, "<leader>at", ":ClaudeThrow<CR>",
        { silent = true, desc = "Throw to background Claude" })
    vim.keymap.set("n", "<leader>ag", "<cmd>ClaudeGoto<cr>",
        { silent = true, desc = "Go to background Claude session" })
end
```

Then add the require to `lua/kolbbond/init.lua` so it becomes:

```lua
-- kolbbond init.lua
--
require("kolbbond.remap");
require("config.lazy");
require("kolbbond.set");
require("kolbbond.autoreload");
require("kolbbond.claude_throw").setup();
```

- [ ] **Step 4: Run tests to verify they pass**

Run both suites:

```bash
nvim --headless -c "luafile tests/test_claude_throw.lua" -c "qa!" 2>&1 | tail -5
nvim --headless -c "luafile test_config.lua" -c "qa!" 2>&1 | tail -20
```

Expected: unit suite `20 passed, 0 failed`; config suite `0 failed` including the five new tests.

- [ ] **Step 5: Commit**

```bash
git add lua/kolbbond/claude_throw.lua lua/kolbbond/init.lua test_config.lua
git commit -m "claude_throw: :ClaudeThrow/:ClaudeGoto commands and keymaps"
```

---

### Task 5: Manual verification and documentation

**Files:**
- Modify: `CLAUDE.md` (Key Commands and Key Mappings sections)

**Interfaces:**
- Consumes: everything.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Verify tier 1 attaches in-buffer**

Inside tmux, from a repo:

```bash
ls ~/.claude/ide/           # note existing lockfiles
nvim lua/plugins/claude.lua # then press <leader>ac
ls ~/.claude/ide/           # a NEW <port>.lock must appear
```

Expected: Claude opens in an **nvim split** (not a tmux pane), and a fresh lockfile appears — confirming it auto-attached without any `-e` forwarding. Confirm `<leader>aj` moves the cursor into it.

- [ ] **Step 2: Verify the diff loop**

Ask the in-buffer Claude to make a small edit to a scratch file. Confirm a vertical diff opens against the live buffer, `:w` accepts, and `:q` on a second attempt rejects.

- [ ] **Step 3: Verify tier 2 end to end**

Select a few lines in a source file, press `<leader>at`, type a question, press Enter.

```bash
tmux list-sessions | grep claude-bg
```

Expected: a `claude-bg-<repo>` session exists and has received `@relpath (lines N-M): <question>`. Press `<leader>ag` to switch to it and read the reply.

- [ ] **Step 4: Verify the literal-send guard**

Press `<leader>at` and enter a question containing the word `Enter`, e.g. `what happens when I press Enter here?`. Confirm the text arrives **verbatim** in the background session and does not fire extra newlines — this is what `-l` buys.

- [ ] **Step 5: Update CLAUDE.md**

In the **Key Commands** section, add:

```markdown
- `:ClaudeThrow` / `:ClaudeGoto` - Throw file/selection + question to the background Claude tmux session; switch to it
```

In the **Key Mappings** section, replace the Claude entries with:

```markdown
- `<leader>ac` - Toggle attached Claude (in-buffer)
- `<leader>aj` - Jump to attached Claude
- `<leader>at` - Throw file (normal) or selection (visual) + question to background Claude
- `<leader>ag` - Go to the background Claude tmux session
- `:w` / `:q` in a Claude diff - accept / reject the proposed edit
```

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: record the two-tier Claude commands and keymaps"
```

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

return M

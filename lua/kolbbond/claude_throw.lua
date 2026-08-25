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

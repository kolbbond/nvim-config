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

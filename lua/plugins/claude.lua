-- Claude Code integration: drives the `claude` CLI (same WebSocket protocol as
-- the official IDE extensions), so it uses your existing Claude Code subscription
-- rather than a separate Anthropic API key. Sits alongside Copilot.
return {
  {
    "coder/claudecode.nvim",
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend", "ClaudeCodeAdd",
      "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
    },
    opts = {
      terminal = { provider = "native" }, -- no extra deps; swap to "snacks" if you add folke/snacks.nvim
    },
    keys = {
      { "<leader>a",  nil,                             desc = "+claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",           desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",      desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",  desc = "Resume Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",      desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny Claude diff" },
    },
  },
}

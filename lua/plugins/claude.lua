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
    opts = function()
      -- Outside tmux there is no pane to split into; fall back to an in-nvim
      -- terminal so <leader>ac still works.
      if not vim.env.TMUX then
        return { terminal = { provider = "native" } }
      end
      return {
        terminal = {
          provider = "external",
          provider_opts = {
            -- Function form is REQUIRED: the tmux pane runs on the tmux server,
            -- which does NOT inherit the jobstart client env. We must forward
            -- each attach var explicitly with `-e KEY=VAL`.
            external_terminal_cmd = function(cmd, env)
              local args = { "tmux", "split-window", "-h", "-l", "40%", "-c", vim.fn.getcwd() }
              for key, value in pairs(env or {}) do
                table.insert(args, "-e")
                table.insert(args, key .. "=" .. tostring(value))
              end
              table.insert(args, cmd)
              return args
            end,
          },
        },
      }
    end,
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

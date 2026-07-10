-- Seamless <M-hjkl> (Alt) movement between nvim splits and tmux panes.
-- Alt, not Ctrl: <C-h> is Harpoon and <C-l> is SlimeSend in this config.
-- The matching tmux-side bindings live in ~/defcon/dotfiles/tmux/tmux.conf.
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<M-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left (nvim/tmux)" },
      { "<M-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down (nvim/tmux)" },
      { "<M-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up (nvim/tmux)" },
      { "<M-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (nvim/tmux)" },
    },
  },
}

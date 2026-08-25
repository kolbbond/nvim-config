-- Seamless <M-hjkl> (Alt) movement between nvim splits and tmux panes.
-- Alt, not Ctrl: <C-h> is Harpoon and <C-l> is SlimeSend in this config.
-- The matching tmux-side bindings live in ~/defcon/dotfiles/tmux/tmux.conf.
--
-- The maps are mode = { "n", "t" } because the attached Claude now lives in an
-- nvim TERMINAL buffer (see the two-tier design spec). Without the "t" half,
-- every key inside that split goes to Claude and the only way out is the
-- built-in <C-\><C-n> -- and since lazy's `keys` are the load trigger, pressing
-- <M-l> in there would not even load this plugin.
--
-- <cmd> (rather than ":") is what makes one rhs work in both modes.
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
      { "<M-h>", "<cmd>TmuxNavigateLeft<cr>",  mode = { "n", "t" }, desc = "Navigate left (nvim/tmux)" },
      { "<M-j>", "<cmd>TmuxNavigateDown<cr>",  mode = { "n", "t" }, desc = "Navigate down (nvim/tmux)" },
      { "<M-k>", "<cmd>TmuxNavigateUp<cr>",    mode = { "n", "t" }, desc = "Navigate up (nvim/tmux)" },
      { "<M-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "t" }, desc = "Navigate right (nvim/tmux)" },
    },
  },
}

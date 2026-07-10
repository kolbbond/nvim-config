# Neovim + tmux + Claude Code Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Claude Code spawn into an auto-attached tmux split from Neovim, so Claude's edits arrive as reviewable diffs against live buffers instead of clobbering the file on disk.

**Architecture:** Reconfigure the already-installed `coder/claudecode.nvim` from the `native` terminal provider to `external`, using a function-form `external_terminal_cmd` that runs `tmux split-window` with `-e` env flags so the spawned Claude pane inherits the IDE attach vars. Add an nvim-side autoreload safety net for the one case attaching cannot cover (Claude's `Bash` writing to disk). Add `vim-tmux-navigator` and fix a dead tmux binding so panes cross without the prefix.

**Tech Stack:** Neovim 0.12.2, Lua, lazy.nvim, tmux 3.6, `coder/claudecode.nvim`, `christoomey/vim-tmux-navigator`.

## Global Constraints

- Neovim version floor: 0.11+ (user is on 0.12.2). Do not use APIs removed before 0.11.
- tmux version floor: 3.6 (user's version). `tmux split-window -e KEY=VAL` requires 3.2+ — satisfied.
- **Env vars must be passed via `tmux split-window -e`, NOT via the jobstart env.** Verified empirically: `jobstart(..., {env=...})` sets env on the tmux *client*, but `split-window` runs on the tmux *server*, so the pane does not inherit client env. The `-e` form is the only thing that works.
- `external_terminal_cmd` MUST be the function form returning a table (documented at claudecode.nvim `README.md:691`). The string `"%s"` form cannot carry `-e` flags reliably.
- Plugins are auto-imported from `lua/plugins/` via `{ import = "plugins" }` in `lua/config/lazy.lua:27`. Each file in `lua/plugins/` returns a lazy.nvim spec table.
- `lua/kolbbond/init.lua` is the require entrypoint; new kolbbond modules are wired in there.
- Preserve all existing `<leader>a*` keymaps in `lua/plugins/claude.lua` — only the provider config changes.
- Step 4 edits `~/defcon/dotfiles/tmux/tmux.conf`, a **separate git repo**. Commit those changes there, not in nvim-config.
- Verification in this project is manual behavioral observation in a live nvim/tmux session — there is no automated test runner for config.

---

### Task 1: Switch claudecode.nvim to an auto-attached tmux split

**Files:**
- Modify: `lua/plugins/claude.lua:11-13` (the `opts` block)

**Interfaces:**
- Consumes: claudecode.nvim's `terminal.provider` / `terminal.provider_opts.external_terminal_cmd` config API. The `external_terminal_cmd` function receives `(cmd, env)` where `env` is a table containing `ENABLE_IDE_INTEGRATION`, `FORCE_CODE_TERMINAL`, and `CLAUDE_CODE_SSE_PORT` (source: `terminal.lua:363-370`).
- Produces: nothing consumed by later tasks (config-only change).

- [ ] **Step 1: Replace the `opts` block with provider selection logic**

In `lua/plugins/claude.lua`, replace the current `opts` table (lines 11-13):

```lua
    opts = { -- new-open
      terminal = { provider = "native" }, -- no extra deps; swap to "snacks" if you add folke/snacks.nvim
    },
```

with a computed `opts` that picks `external` inside tmux and falls back to `native` outside it:

```lua
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
            -- each attach var explicitly with `-e KEY=VAL`. (README.md:691)
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
```

- [ ] **Step 2: Reload the config and check for Lua errors**

Run: `nvim --headless "+lua require('lazy')" +qa 2>&1 | head`
Expected: no error output (empty). A syntax error in `claude.lua` would print here.

- [ ] **Step 3: Manually verify the attach (behavioral test)**

In a real tmux session:
1. `nvim lua/plugins/claude.lua`
2. Press `<leader>ac`.

Expected: a new tmux pane opens on the right (40% width) running `claude`, and within a few seconds Claude reports it is connected to the IDE (or `:checkhealth claudecode` in the nvim pane shows the external terminal / a connected client). If the pane opens but Claude does NOT attach, the env forwarding failed — check `echo $CLAUDE_CODE_SSE_PORT` inside the Claude pane; it must be non-empty.

- [ ] **Step 4: Verify edits arrive as diffs, not disk writes (behavioral test)**

With the Claude pane attached, ask Claude in that pane to make a small edit to an open buffer.

Expected: a diff opens in the nvim pane (scratch buffer, not the file on disk). `<leader>aa` accepts it, `<leader>ad` rejects. Confirm the file on disk is unchanged until you press `<leader>aa` (e.g. `git diff` shows nothing before accept).

- [ ] **Step 5: Commit**

```bash
cd ~/defcon/nvim-config
git add lua/plugins/claude.lua
git commit -m "claude: spawn into auto-attached tmux split via external provider

Edits now arrive as diffs against the live buffer instead of writing to
disk. Falls back to the native in-nvim terminal when outside tmux.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Autoreload safety net for out-of-band disk writes

**Files:**
- Create: `lua/kolbbond/autoreload.lua`
- Modify: `lua/kolbbond/init.lua:5` (add the require)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: nothing consumed by later tasks. Side effect only: sets `autoread` and registers autocmds under the `kolbbond_autoreload` augroup.

**Why this task exists:** Task 1 makes Claude's `Edit` tool route through diffs. But when Claude runs a shell command (`Bash`) — a formatter, `sed -i`, `git checkout` — it writes to disk behind nvim's back regardless of attach state. This task makes nvim notice and reload.

- [ ] **Step 1: Create the autoreload module**

Create `lua/kolbbond/autoreload.lua`:

```lua
-- Reload buffers when their file changes on disk out-of-band.
--
-- Claude's Edit tool routes through claudecode.nvim diffs (no disk write until
-- you accept), but Claude's Bash tool (formatters, `sed -i`, `git checkout`)
-- writes directly. This makes nvim notice and reload, and warns loudly when it
-- can't (a dirty buffer whose file also changed underneath — nvim refuses to
-- clobber your unsaved edits, which is correct).

vim.opt.autoread = true

local group = vim.api.nvim_create_augroup("kolbbond_autoreload", { clear = true })

-- Poll for external changes at natural pause points.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = group,
  callback = function()
    -- Skip special buffers (terminals, prompts) where checktime is meaningless.
    if vim.bo.buftype == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Announce when a reload actually happened, so an edit appearing under you is
-- never silent.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})
```

- [ ] **Step 2: Wire the module into init**

In `lua/kolbbond/init.lua`, add the require after the existing `kolbbond.set` line (line 5):

```lua
-- kolbbond init.lua
--
require("kolbbond.remap");
require("config.lazy");
require("kolbbond.set");
require("kolbbond.autoreload");
```

- [ ] **Step 3: Verify the config loads without error**

Run: `nvim --headless "+lua require('kolbbond.autoreload')" "+lua print(vim.o.autoread)" +qa 2>&1 | head`
Expected: prints `true` and no error.

- [ ] **Step 4: Verify reload fires on an out-of-band write (behavioral test)**

1. `nvim /tmp/autoreload_probe.txt`, type a line, `:w`.
2. Leave it open. In another shell: `echo "external change" >> /tmp/autoreload_probe.txt`
3. Back in nvim, move the cursor / switch focus to trigger `CursorHold` or `FocusGained`.

Expected: the buffer updates to show `external change` and the notification "File changed on disk — buffer reloaded" appears. Clean up: `rm /tmp/autoreload_probe.txt`.

- [ ] **Step 5: Verify the dirty-buffer guard (behavioral test)**

1. `nvim /tmp/autoreload_probe2.txt`, type a line, `:w`.
2. Type more WITHOUT saving (buffer now modified).
3. In another shell: `echo "external" >> /tmp/autoreload_probe2.txt`
4. Back in nvim, trigger a checktime (move cursor, wait).

Expected: nvim does NOT silently discard your unsaved edits; it warns (W12 "Warning: File ... changed and the buffer was changed in Vim as well"). This is the correct safe behavior. Clean up: `rm /tmp/autoreload_probe2.txt`.

- [ ] **Step 6: Commit**

```bash
cd ~/defcon/nvim-config
git add lua/kolbbond/autoreload.lua lua/kolbbond/init.lua
git commit -m "autoreload: reload buffers on out-of-band disk writes

Covers the case Claude's Bash tool writes to disk behind nvim's back.
Warns on reload; refuses to clobber a dirty buffer.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: Add vim-tmux-navigator (nvim side)

**Files:**
- Create: `lua/plugins/tmux.lua`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: the plugin registers `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` normal-mode maps that navigate nvim splits and hand off to tmux at the edge. Task 4 (tmux.conf) is the matching half.

**Note:** This task only makes navigation work *from nvim*. Crossing works fully only once Task 4's tmux bindings are also in place. It is committed separately because the nvim half is independently valid and reviewable.

- [ ] **Step 1: Create the plugin spec**

Create `lua/plugins/tmux.lua`:

```lua
-- Seamless <C-hjkl> movement between nvim splits and tmux panes.
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
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left (nvim/tmux)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down (nvim/tmux)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up (nvim/tmux)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (nvim/tmux)" },
    },
  },
}
```

- [ ] **Step 2: Install the plugin**

Run: `nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5`
Expected: lazy.nvim reports vim-tmux-navigator installed, no errors.

- [ ] **Step 3: Verify nvim-internal split navigation (behavioral test)**

1. `nvim`, then `:vsplit`.
2. Press `<C-h>` and `<C-l>`.

Expected: cursor moves between the two nvim windows. (Cross-to-tmux is verified in Task 4.)

- [ ] **Step 4: Commit**

```bash
cd ~/defcon/nvim-config
git add lua/plugins/tmux.lua lazy-lock.json
git commit -m "plugins: add vim-tmux-navigator for seamless C-hjkl pane movement

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: tmux-side navigation bindings + fix the dead `is_vim` guard

**Files:**
- Modify: `~/defcon/dotfiles/tmux/tmux.conf` (SEPARATE REPO — commit there)

**Interfaces:**
- Consumes: Task 3's vim-tmux-navigator (the nvim half of the handoff).
- Produces: root-level `C-h/j/k/l` bindings that defer to vim when the focused pane runs vim.

**Context:** The current `tmux.conf` references `$is_vim` in the `C-\` binding but never defines it, so that conditional always falls through to `select-pane -l`. This task defines `is_vim` and adds the four directional bindings.

- [ ] **Step 1: Define `is_vim` and add navigation bindings**

In `~/defcon/dotfiles/tmux/tmux.conf`, find the existing vim-motions block:

```
# allow us to send <C-\> within tmux (vim-tmux pane nav passthrough)
bind -n 'C-\' if-shell "$is_vim" "send-keys 'C-\\'" "select-pane -l"
```

Immediately ABOVE that `bind -n 'C-\'` line, insert the `is_vim` definition:

```
# is_vim: true when the focused pane is running vim/nvim (used by vim-tmux-navigator).
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
```

Then, directly after the `bind -n 'C-\'` line, add the four directional bindings:

```
# vim-tmux-navigator: C-hjkl crosses nvim splits and tmux panes seamlessly.
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

# C-l is now bound at root, shadowing clear-screen; restore it under the prefix.
bind C-l send-keys 'C-l'
```

- [ ] **Step 2: Reload tmux config and check for errors**

Run: `tmux source-file ~/.tmux.conf`
Expected: "tmux.conf reloaded" message, no error lines.

- [ ] **Step 3: Verify seamless crossing (behavioral test)**

1. In tmux, open `nvim` in one pane and a shell in a pane to its right.
2. From nvim, press `<C-l>`.

Expected: focus lands in the shell pane. Press `<C-h>` from the shell — focus returns to nvim. No prefix key used. In a shell pane, `prefix C-l` still clears the screen.

- [ ] **Step 4: Commit (in the dotfiles repo)**

```bash
cd ~/defcon/dotfiles
git add tmux/tmux.conf
git commit -m "tmux: add vim-tmux-navigator bindings; define missing is_vim guard

Defines is_vim (was referenced by the C-\\ binding but never set, so it
always fell through). Adds root C-hjkl handoff; restores clear-screen
under prefix C-l.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review

**Spec coverage:**
- Spec §Design.1 (spawn into auto-attached tmux split, external provider, `-e` env, $TMUX fallback) → Task 1. ✓
- Spec §Design.2 (edits as diffs, no code change) → Task 1 Step 4 verifies it. ✓
- Spec §Design.3 (autoreload safety net, autoread + checktime autocmds + FileChangedShellPost notify) → Task 2. ✓
- Spec §Design.4 (vim-tmux-navigator + define is_vim + root C-hjkl + prefix C-l remedy) → Tasks 3 & 4. ✓
- Spec §Verification per-step → each task has behavioral verification steps. ✓
- Spec §Out of scope (custom plugin) → not planned, as intended. ✓

**Placeholder scan:** No TBD/TODO/"handle edge cases"; every code step shows complete code. ✓

**Type/name consistency:** augroup `kolbbond_autoreload` used once. Keymap names `<C-h/j/k/l>` and command names `TmuxNavigate*` consistent between Task 3 nvim maps and Task 4 tmux bindings. `is_vim` variable name consistent between its definition and all five `if-shell` references. ✓

**Note on ordering:** Task 3 and Task 4 are two halves of one feature; navigation is only fully testable after both. Task 3's nvim-internal split test (Step 3) is the independently-verifiable slice that justifies the split commit.

# Neovim + tmux + Claude Code: collaborative editing workflow

**Date:** 2026-07-10
**Status:** Approved — Step 1 (this doc covers the full Option A; implementation is phased)

## Problem

Working with Neovim in one tmux pane and Claude Code in an adjacent pane, the
friction is:

1. Telling Claude which file/lines to look at (manual paths, pasted code).
2. Reviewing Claude's edits (Claude writes to disk, user re-reads in nvim).
3. Moving between the nvim and Claude panes (prefix key every time).
4. **The core problem:** editing the same file from both sides. When the user
   edits a buffer and Claude writes the file, they save over each other and
   have to reload.

The user also wants, eventually, to write their own plugin — but the first step
is the quickest path to a smooth workflow, not new software to maintain.

## Key findings (verified, not assumed)

- The user already has `coder/claudecode.nvim` installed
  (`lua/plugins/claude.lua`), configured with `terminal.provider = "native"`,
  which only ever spawns Claude *inside* nvim. In a tmux pane, Claude is an
  unattached CLI that writes to disk — the source of the clobbering.
- claudecode.nvim runs a WebSocket server inside nvim and exposes MCP tools.
  When Claude is **attached as an IDE**, its `Edit` tool routes through the
  `openDiff` MCP tool, rendered as a scratch buffer diffed against the *live*
  nvim buffer (`diff.lua:1439`, `buftype=acwrite`). Nothing hits disk until the
  user accepts. `check_document_dirty` + `save_document` let Claude see unsaved
  changes. **This is the protocol-level fix for the clobbering problem.**
- The `external` provider passes `ENABLE_IDE_INTEGRATION=true` and
  `CLAUDE_CODE_SSE_PORT=<port>` into the spawned command's env
  (`terminal.lua:362-369`), so a Claude launched this way **auto-attaches** —
  no `/ide` needed.
- **Critical trap (empirically verified):** `external.lua:124` spawns via
  `jobstart(..., {env = env_table})`, which sets env on the tmux *client*.
  `tmux split-window` runs on the tmux *server*, so the new pane does **not**
  inherit those vars. Confirmed with a probe: naive form yields an empty
  `CLAUDE_CODE_SSE_PORT`; the `tmux split-window -e KEY=VAL` form works. User is
  on tmux 3.6, which supports `-e`. Therefore `external_terminal_cmd` **must**
  be the function form returning a command table with explicit `-e` flags — not
  the `"tmux split-window %s"` string form.
- The function form `external_terminal_cmd = function(cmd, env) ... end`
  returning a table is documented at claudecode.nvim `README.md:691`.
- Residual gap attaching does NOT close: when Claude runs `Bash` (a formatter,
  `sed -i`, `git checkout`), it writes to disk behind nvim's back regardless.
  This needs an nvim-side autoreload safety net.
- The user's `tmux.conf` (`~/defcon/dotfiles/tmux/tmux.conf`) has a dead
  binding: `bind -n 'C-\' if-shell "$is_vim" ...` references `$is_vim`, which is
  never defined, so it always falls through to `select-pane -l`. There is no
  `vim-tmux-navigator` in the nvim plugins.

## Decision

Wire up the plugin the user already has (Option A). No new plugin is written in
this step. Writing a custom plugin is explicitly deferred (see Future Work).

## Design

Four changes across four files.

### 1. Spawn Claude into a tmux split, pre-attached

**File:** `lua/plugins/claude.lua`

Set `terminal.provider = "external"` and provide `external_terminal_cmd` as a
function returning a command table:

```lua
external_terminal_cmd = function(cmd, env)
  local port = env["CLAUDE_CODE_SSE_PORT"]
  return {
    "tmux", "split-window", "-h", "-l", "40%", "-c", vim.fn.getcwd(),
    "-e", "ENABLE_IDE_INTEGRATION=true",
    "-e", "CLAUDE_CODE_SSE_PORT=" .. tostring(port),
    cmd,
  }
end
```

`<leader>ac` opens a tmux pane running Claude that connects to nvim's WebSocket
server on its own.

**Fallback:** if `$TMUX` is unset (nvim launched outside tmux), fall back to
`provider = "native"` so `<leader>ac` still works. Implement by choosing the
provider at config time based on `vim.env.TMUX`.

### 2. Edits arrive as diffs, not disk writes

No code change — falls out of step 1. Once attached, Claude's `Edit` becomes
`openDiff`, rendered against the live buffer. Existing `<leader>aa` /
`<leader>ad` accept/reject. Nothing touches disk until accept. Unsaved changes
visible to Claude via `check_document_dirty`.

### 3. Safety net for Bash-writes-to-disk

**File:** new `lua/kolbbond/autoreload.lua`, required from `lua/kolbbond/init.lua`.

- `vim.opt.autoread = true`
- autocmd: `checktime` on `FocusGained`, `BufEnter`, `CursorHold`, `TermLeave`
- autocmd: `FileChangedShellPost` → `vim.notify` that the file changed on disk

If the buffer is dirty AND the file changed underneath, nvim refuses to
auto-reload and warns (W12) — correct, safe behavior; the notification prompts
the user to resolve.

### 4. Cross the nvim/tmux boundary without the prefix

**Files:** `lua/plugins/` (new spec for `christoomey/vim-tmux-navigator`) and
`~/defcon/dotfiles/tmux/tmux.conf` (separate repo).

- Add `christoomey/vim-tmux-navigator`.
- Define `is_vim` in `tmux.conf` (standard `ps`-based pane-command check) and
  add root-level `C-h/j/k/l` bindings that defer to vim when the pane runs vim.
- **Tradeoff:** root-bound `C-l` shadows clear-screen in shell panes;
  conventional remedy is `prefix + C-l` to clear. Document in the binding.

## Verification (per step, behavior not assumption)

- Step 1: `:checkhealth claudecode` shows the external pane attached.
- Step 2: trigger an edit from the Claude pane; confirm a diff opens in nvim and
  disk is untouched until `<leader>aa`.
- Step 3: `sed -i` a file open in nvim from another shell; confirm the reload
  notification fires and the buffer updates.
- Step 4: `C-l` from nvim lands in the Claude pane and `C-h` returns, no prefix.

## Risks

- Step 1's function form: `env_table`'s exact key is confirmed as
  `CLAUDE_CODE_SSE_PORT` (`terminal.lua:369`), but if runtime shape differs the
  pane spawns unattached — caught immediately by `:checkhealth`.
- Step 4 edits the dotfiles repo, not this one. Keep the changes in a separate
  commit there.

## Out of scope / Future work

- **User's own plugin.** Deferred by explicit choice. When revisited, the
  capability gap worth targeting is what attaching cannot give: a presence layer
  showing which buffers Claude is touching, buffer-level locking, or streaming
  Claude's edits live into the buffer without a diff gate. That is a real
  project maintained against a moving CLI protocol — a deliberate undertaking,
  not part of this workflow fix.

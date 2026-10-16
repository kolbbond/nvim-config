# Run-current-file hotkey — design

Status: **design approved, implementation deferred** (paused 2026-07-15, resume next session)

## Goal

One hotkey to run the file you're editing — fresh process, output visible — without
switching tabs or leaving nvim. Distinct from slime (which sends lines to a live REPL);
this runs the whole file from scratch.

## Behavior

- `<leader>rr` — save buffer, then run it by `&filetype` in a dedicated tmux run-pane.
- Run-pane: spawned on first use (vertical split, ~40%, like the slime pane), `pane_id`
  remembered. Later runs reuse it if it still exists; otherwise respawn.
- Each run: `clear` + `Ctrl-C` + the run command, so you see only this run's output with a
  fresh traceback at the top. Fresh process every time (no leftover REPL state).
- `<leader>rq` — close the run-pane (mirrors slime's `<leader>sq`).

## Make (built 2026-10-16)

The run-pane is live in `after/plugin/runfile.lua`, currently driving make only:

- `:Make [args]` — `:wall`, then `make -C <dir> [args]` in the run-pane, where `<dir>`
  holds the nearest `GNUmakefile`/`makefile`/`Makefile` at or above the buffer
  (search stops at `$HOME`). Lets a `tex/` subdir build from its project root.
- `<leader>rm` → `:Make`, `<leader>rM` → `:Make ` (type a target), `<leader>rq` closes.

`<leader>rr` (run file) is still unbuilt: blocked on removing iron.nvim, which owns
`<space>rr`.

## Filetype dispatch

Small table `&filetype` → command:

| filetype   | command  |
|------------|----------|
| python     | python   |
| sh / bash  | bash     |
| lua        | lua      |
| javascript | node     |

Unknown filetype → `vim.notify("no runner for <ft>")`, do nothing.

- **python** is venv-aware: reuse the slime `$VIRTUAL_ENV` logic — if set,
  `source "$VIRTUAL_ENV/bin/activate" && python <file>`; else bare `python3 <file>`.

## Targeting

- Default: spawn an adjacent split beside nvim (best for "no tab switching" — output is
  right there).
- Overridable via `vim.g.runfile_target` — leaves a seam to point runs at a named tmux
  session/window later (the user's old make-throws-to-a-session pattern), without building
  a picker now.

## Fallback

Outside tmux (`not vim.env.TMUX`) → in-nvim `:terminal` split, same escape hatch as the
claude.nvim config.

## Placement

New self-contained file `after/plugin/runfile.lua`, structured like `slime.lua`.

## Out of scope (YAGNI)

- Arg-passing UI
- Output capture back into nvim
- The named-session picker (only the `vim.g` seam is built now)

## Existing pieces to reuse

- `after/plugin/slime.lua` — venv detection (`get_python_repl_command`), tmux pane
  spawn/kill/exists patterns, `<leader>s*` keymap conventions.
- `lua/plugins/claude.lua` — `not vim.env.TMUX` → native-terminal fallback pattern.

# Two-tier Claude Code collaboration in Neovim

**Date:** 2026-08-24
**Status:** Approved — supersedes the transport decision in
`2026-07-10-nvim-tmux-claude-design.md` (that doc's diff/attach analysis still holds)

## Problem

With a Claude session already running, there is no way from nvim to:

1. Push a question about the current selection into it.
2. Move focus to it.
3. Send it arbitrary text at all.

`<leader>as` sends an at-mention, but focus stays in nvim and there is no
mechanism to attach a *question* to the thing being sent. Separately, two of the
eight advertised Claude keymaps never fire.

The deeper question this raised: should Claude live in an nvim buffer, in a
tmux pane, or a separate tmux session — and should we build our own plugin (or
an Agent SDK client) instead?

## Key findings (verified, not assumed)

Each of these was checked against the installed plugin source or a live probe,
not recalled.

- **The attach env is provider-agnostic.** `ENABLE_IDE_INTEGRATION` and
  `CLAUDE_CODE_SSE_PORT` are assembled in `terminal.lua:364-369` *before* any
  provider sees them. The `native` provider spawns via `termopen`, which
  inherits job env normally. **Native auto-attaches with no `-e` forwarding.**
  The tmux-server env trap documented in the 2026-07-10 doc is a cost unique to
  the `external` provider, not an inherent cost of the integration.
- **The external provider cannot focus.** `external.lua:34`: *"External terminal
  is already running, we can't focus it programmatically."* It tracks only a
  `jobid` (`is_valid()`), never a tmux pane id — so there is no address to aim
  at. This is the root cause of both "can't focus" and "can't send text".
- **`ClaudeCodeSendText` is native/snacks only.** `terminal.lua:685-691`
  explicitly refuses `external` and `none`: there is no nvim-side terminal
  buffer to write into.
- **Attachment is per-nvim-instance and authenticated.** Port is random in
  `[10000, 65535]` (`config.lua:11`); the plugin writes
  `~/.claude/ide/<port>.lock` carrying `workspaceFolders`, `pid`, and a fresh
  `authToken`. A restarted nvim gets a new port *and* a new token, so a Claude
  launched against the old port cannot re-attach.
  **Therefore "survives nvim" and "stays attached" are mutually exclusive.**
  A surviving Claude returns *detached*, and a detached Claude writes straight
  to disk — reintroducing the clobbering bug the 2026-07-10 design eliminated.
- **Selection tracking is already live.** `track_selection = true`
  (`config.lua:16`) broadcasts `selection_changed` on `CursorMoved`,
  `ModeChanged`, `TextChanged`, and `BufEnter` (`selection.lua:126,133,140`).
  An attached Claude already knows the current file, cursor, and selection
  without any explicit send.
- **`:w` accepts a diff, `:q` rejects it.** `diff.lua:977` binds `BufWriteCmd`
  as the accept path; `diff.lua:1005` rejects once the proposed buffer is
  displayed in no window. A dedicated accept keymap is therefore optional.
- **Two advertised keymaps never fire.** `after/plugin/` loads *after* lazy, so
  it overwrites the plugin's `keys` entries:
  - `<leader>af` — `lua/plugins/claude.lua:40` (Focus) is shadowed globally by
    `after/plugin/lsp.lua:149` (LSP format) and, in c/cpp, by the buffer-local
    `after/plugin/clang_format.lua:92`.
  - `<leader>aa` — shadowed by `after/plugin/harpoon.lua:7`.
  `<leader>as` does *not* collide: Aerial's is normal-mode, Claude's is visual.
- **Free `<leader>a*` keys** (probed live): `e g h i j k l m q t u v w x y z`.

### Why not the Claude Agent SDK

Considered and rejected for this use case:

- **Billing.** The current setup drives the `claude` CLI and uses the Claude
  Code subscription. The Agent SDK and Claude API bill per token.
- **No Lua SDK.** Official SDKs are Python, TypeScript, Java, Go, Ruby, C#, PHP.
  A Lua plugin would be raw HTTP — hand-rolled SSE, tool loop, retries.
- **It rebuilds what we have.** The Agent SDK is Claude Code as a library;
  wrapping it returns us to the starting point *minus* the IDE WebSocket
  protocol, which is the part that gives diffs against the live buffer.

The gap is not an agent framework — it is **tmux pane addressing**. That is a
small bounded module, not a new product.

## Decision

Approach A: **native in-buffer attached Claude + a tmux "throw-to" module.**

Each tier uses the transport that matches its lifetime. The attached tier uses
the protocol it was designed for; the background tier uses tmux because that is
all a detached process can use.

| | Tier 1 — attached | Tier 2 — background |
|---|---|---|
| Lives in | nvim terminal buffer | tmux session `claude-bg-<repo>` |
| Transport | IDE WebSocket | `tmux send-keys` |
| Context via | `at_mention` (protocol) | `@path` + range, as text |
| Owns | edits, diffs vs live buffer | research, long asks, nothing touching the tree |
| Survives nvim | no — `--resume` | yes |

The tiers share no code. Different transports, different lifetimes.

## Design

### 1. Tier 1 — attached Claude moves in-buffer

**File:** `lua/plugins/claude.lua`

Set `terminal.provider = "native"` and **delete** the `external_terminal_cmd`
function together with its `-e` env forwarding and the `vim.env.TMUX` branch.
That machinery exists solely to work around the tmux-server env trap, which
native does not have. This is a net deletion.

Unlocked for free: `ClaudeCodeSendText`, `ClaudeCodeFocus`, working toggle, and
`auto_resize_terminal` during the diff lifecycle.

Accepted cost: `<C-\><C-n>` to leave terminal mode, and the Claude pane is
nvim-sized rather than tmux-managed. Claude dies with nvim; `<leader>ar`
(`--resume`) is the recovery path, and the conversation itself is already
persisted to disk by the CLI.

### 2. Tier 2 — `lua/kolbbond/claude_throw.lua`

A pure core plus a thin I/O shell, so the logic is testable without tmux.

```
pure
  repo_root(path)                    -> git toplevel, else cwd
  session_name(root)                 -> "claude-bg-" .. sanitized basename
  compose(relpath, range, question)  -> text to send

shell (single seam, injectable runner)
  ensure_session(name, root)  tmux has-session || tmux new-session -d -c root claude
  throw(text, name)           tmux send-keys -l -- <text>; then Enter
  goto_session(name)          tmux switch-client
```

Composed message shape:

```
@src/collider.cpp (lines 42-77): why does this allocate every frame?
```

A `@path` reference rather than pasted code: the background Claude has the
correct cwd and reads the file itself, so the reference stays current and the
send stays small.

**Session naming.** `claude-bg-<basename>`, with `.` and `:` sanitized — tmux
treats both as target separators, so an unsanitized `defcon.nvim` would address
a *window* rather than a session.

### 3. Two correctness requirements

Non-negotiable, because both failure modes are silent:

- **All tmux invocations use `vim.system()` with an argument list — never a
  shell string.** The question is arbitrary user text; interpolating it into
  `sh -c` is a quoting bug and a command-injection hole at once.
- **`send-keys` must use `-l` and `--`.** Without `-l`, tmux interprets key
  *names*: a question containing "Enter" or "C-c" fires those keys instead of
  typing them. `--` prevents a question starting with `-` being parsed as flags.
  `Enter` is then sent as a separate call.

### 4. Keymaps

| Key | Action | Change |
|---|---|---|
| `<leader>ac` | Toggle attached Claude | unchanged |
| `<leader>ab` | Add current buffer | unchanged |
| `<leader>ar` | Resume | unchanged |
| `<leader>as` | Send selection (visual) | unchanged |
| `<leader>ad` | Deny diff | unchanged |
| `<leader>aj` | Jump/focus attached Claude | **moved** from the shadowed `<leader>af` |
| `<leader>at` | Throw to background (normal: file; visual: selection) | **new** |
| `<leader>ag` | Go to background tmux session | **new** |
| `<leader>aa` | — | **removed**; `:w` is the accept gesture, key stays harpoon's |

`<leader>af` remains LSP/clang-format. Claude's focus moves aside rather than
fighting for it, which also keeps `test_config.lua:230` passing.

### 5. Error handling

Surfaced, never swallowed:

- **No tmux** (`$TMUX` unset or binary absent) → notify and abort. Tier 2 is
  tmux-only by construction.
- **Session creation fails** → notify with tmux's actual stderr; no silent retry.
- **Empty question** → abort quietly; an empty send would submit a bare prompt.

### 6. Testing

Tests target the pure core, in the existing `test_config.lua` style
(`nvim --headless -c "luafile test_config.lua" -c "qa!"`, exit-code based):

- `session_name` sanitizes `.` and `:`
- `repo_root` falls back to cwd outside a repo
- `compose` renders with a range, without a range, and refuses an empty question
- the tmux seam is stubbed — no live tmux required

Manual verification: attached Claude spawns in-buffer and auto-attaches (a fresh
`~/.claude/ide/<port>.lock` appears); a diff accepts on `:w`; `<leader>at`
reaches the background session.

## Future work

Explicitly deferred, not forgotten:

- **Global background session** (one `claude-bg`, or one session with a window
  per repo). Per-project was chosen because a global session's cwd belongs to
  whichever repo opened it first, breaking `@path` resolution elsewhere. Revisit
  if per-repo sessions accumulate.
- **Promote `claude_throw` to a real plugin.** It lives in `lua/kolbbond/` for
  now; moving it under `lua/plugins/` (or its own repo) is a deliberate later
  step once the interface has settled.
- **Agent SDK for non-interactive work** — a scheduled reviewer or batch
  refactor runner is a genuinely different product and worth its own design.
- **`focus_after_send`** becomes meaningful under the native provider; left off
  initially so sending does not steal focus mid-edit.

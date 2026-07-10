# peek.nvim — Starter Plugin Design

**Date:** 2026-07-10
**Goal:** Build a standalone, locally-loaded Neovim plugin that teaches the full anatomy of a real, distributable plugin. The plugin promotes the existing in-config `nvim-viewer` code into a properly structured plugin named `peek.nvim`.

## Purpose

The user already hand-wrote `lua/nvim-viewer/init.lua` (a ~130-line floating-window viewer) inside their nvim config. They understand the *domain* but have never built a plugin with real *structure*. This project keeps the exact same job (a viewer window) so that 100% of the learning goes to plugin architecture: the `plugin/` vs `lua/` split, `setup()`/config contract, lazy-loading, vimdoc, health checks, and tests.

## Decisions (from brainstorming)

- **Name:** `peek.nvim` → repo dir `~/defcon/peek.nvim`, `require("peek")`, `:Peek` command, `<leader>vp` keymap.
- **Location:** standalone git repo at `~/defcon/peek.nvim`, loaded locally via lazy.nvim `dir = "~/defcon/peek.nvim"`. Not pushed to GitHub as part of this work (can be pushed later with zero changes).
- **Function:** promote the existing `nvim-viewer` viewer — floating window showing Lua memory, buffers, LSP clients, and top plugins by load time.
- **Depth:** full anatomy — module split, `setup()` + config validation, `plugin/` guard, user command, keymap, `:checkhealth`, vimdoc, plenary tests, stylua config. No CI (deferred).
- **Old copy:** after the new plugin is verified working, delete `lua/nvim-viewer/init.lua`, the `lua/nvim-viewer/` dir, and `plugin/nvim-viewer.lua`. One source of truth.

## Repo Layout

```
~/defcon/peek.nvim/
├── plugin/peek.lua         # auto-sourced on startup; cheap; defines :Peek, load guard
├── lua/peek/
│   ├── init.lua            # public API: M.setup(opts), M.open()
│   ├── config.lua          # defaults + validation + merge, holds config.options
│   ├── collect.lua         # pure data gathering (buffers/lsp/plugins/mem)
│   ├── ui.lua              # float window render + buffer-local keymaps
│   └── health.lua          # :checkhealth peek
├── doc/peek.txt            # vimdoc (:help peek)
├── tests/
│   ├── minimal_init.lua    # bootstraps plenary for headless runs
│   └── peek_spec.lua       # plenary/busted specs
├── .stylua.toml
├── README.md
└── .gitignore
```

### Teaching point: `plugin/` vs `lua/`

`plugin/peek.lua` is auto-sourced by Neovim on every startup (the runtimepath contract). It must stay cheap: it only registers the `:Peek` user command and sets a load guard (`if vim.g.loaded_peek then return end; vim.g.loaded_peek = true`). It does NOT `require` the heavy modules at file scope. The real code under `lua/peek/` loads on demand when `:Peek` runs. This is how plugins stay fast at startup.

## Module Responsibilities & Interfaces

- **`config.lua`**
  - `M.defaults = { border = "rounded", width = 60, max_height = 30, sections = {"memory","buffers","lsp","plugins"}, plugin_limit = 10 }`
  - `M.setup(user_opts)`: validate with `vim.validate`, then `M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})`.
  - `M.options`: the live, merged config every other module reads. No other module hardcodes values.
- **`collect.lua`** (pure, testable — no UI)
  - `M.buffers()`, `M.lsp()`, `M.plugins(limit)`, `M.memory()` — return plain Lua tables. Logic lifted from current `nvim-viewer`.
- **`ui.lua`**
  - `M.open(options)`: builds line content from `collect.*`, creates scratch buffer + float window, sets buffer-local `q` (close) and `r` (refresh) keymaps. Reads all sizing/border from `options`.
- **`init.lua`** (public surface)
  - `M.setup(opts)` → delegates to `config.setup`.
  - `M.open()` → `ui.open(config.options)`.
- **`health.lua`**
  - `M.check()`: reports nvim version, lazy.nvim presence, config validity via `vim.health.start/ok/warn/error`.

## Config / setup() Contract

User writes `require("peek").setup({ width = 80 })`. Flow:

1. `init.setup(opts)` → `config.setup(opts)` validates and merges into `config.options`.
2. `:Peek` → `init.open()` → `ui.open(config.options)`.
3. `collect` and `ui` receive/read config; never hardcode. This keeps units independently testable.

If `setup()` is never called, `config.options` falls back to `config.defaults` (guard: `config.options = config.options or config.defaults`), so `:Peek` works with zero configuration.

## Wiring Into nvim-config

New spec file `lua/plugins/local.lua`, added to the import list in `lua/plugins/init.lua`:

```lua
return {
  {
    dir = "~/defcon/peek.nvim",
    cmd = "Peek",
    keys = { { "<leader>vp", "<cmd>Peek<cr>", desc = "Peek: viewer" } },
    opts = {},
  },
}
```

Teaching points: `dir=` loads a local plugin; `cmd`/`keys` are lazy-load triggers (nothing runs until `:Peek` or the keymap); providing `opts` makes lazy.nvim auto-call `require("peek").setup(opts)`.

## Retiring the Old Copy

After `:Peek` is verified working in a real nvim session:

- Delete `lua/nvim-viewer/init.lua`
- Delete the `lua/nvim-viewer/` directory
- Delete `plugin/nvim-viewer.lua`

Grep for stray references to `nvim-viewer` / `NvimViewer` before deleting (remap files, keymaps) to avoid dangling calls.

## Testing & Health

- **`tests/peek_spec.lua`** (plenary/busted): tests `collect.lua` (create a scratch buffer, assert it appears in `collect.buffers()`) and `config.lua` (defaults present; user opts override; invalid opts rejected). Run headless:
  `nvim --headless -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"`.
  Plenary is already available via telescope in the user's config.
- **`tests/minimal_init.lua`**: prepends peek + plenary to runtimepath for isolated headless runs.
- **`health.lua`** wired so `:checkhealth peek` works.
- **`.stylua.toml`**: formatting config; `stylua lua/` keeps style consistent.

## Out of Scope (YAGNI)

- GitHub Actions CI / luacheck (can add later).
- Pushing the repo to GitHub (structure is push-ready; done later by the user).
- New viewer features — the viewer's behavior is intentionally unchanged.

## Success Criteria

1. `:Peek` opens the float in a real nvim session, loaded from `~/defcon/peek.nvim` via lazy.nvim.
2. `require("peek").setup({ width = 80 })` visibly changes the window.
3. `:checkhealth peek` reports OK.
4. Headless plenary tests pass.
5. Old in-config `nvim-viewer` removed with no dangling references.

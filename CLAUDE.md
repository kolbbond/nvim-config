# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration focused on C/C++ development with CMake, Python/MATLAB scripting with REPL integration, and scientific computing workflows. Targets Neovim 0.12+.

## Key Commands

- `:Lazy` - Plugin manager UI; `:Lazy sync` to install/update, `:Lazy check` for updates
- `:Mason` - Manage LSP servers (clangd, pylsp, lua_ls, matlab_ls)
- `:MatlabLaunchServer` - Launch MATLAB REPL
- `:ClangFormat` / `:ClangFormatInfo` - Format C/C++ buffer; show which binary resolved

## Architecture

```
init.vim                    # Entry point: sets runtimepath, sources lua/init.lua
lua/
  init.lua                  # Requires kolbbond, then config.lazy last
  modules.lua               # Build notification system (emoji-based asyncrun status)
  config/lazy.lua           # lazy.nvim bootstrap + setup
  kolbbond/
    init.lua                # Requires set, remap, autoreload (in that order)
    set.lua                 # Vim settings (tabs=4, relative numbers, no swap)
    remap.lua               # Keymaps (leader=SPACE)
    autoreload.lua          # Reload buffers on out-of-band disk writes
  plugins/                  # lazy.nvim specs, imported by lua/plugins/init.lua
    core.lua debug.lua lsp.lua repl.lua themes.lua tools.lua ui.lua
    tmux.lua claude.lua
after/plugin/               # Per-plugin runtime config (~28 files)
  lsp.lua                   # Native vim.lsp.config/enable; Mason installs servers
  cmp.lua                   # Completion via blink.cmp (+ copilot source)
  clang_format.lua          # Version-tolerant clang-format integration
  dap.lua                   # Debug adapters (GDB, LLDB, CppDBG, Python)
  colors.lua                # Gruvbox customization with 20+ highlight overrides
  slime.lua                 # Python REPL via tmux panes
```

## Plugin Management

Uses **lazy.nvim**. Bootstrap and `lazy.setup()` live in `lua/config/lazy.lua`; plugin
specs live in `lua/plugins/*.lua` and are pulled in via `{ import = "plugins" }`.
Versions are pinned in `lazy-lock.json`.

`lazy.setup()` runs once, from the end of `lua/init.lua`, after `require("kolbbond")`
and every plugin global are set. Don't move it into `lua/kolbbond/init.lua`, and
don't delete it as "redundant" -- it is the only call site.

`mapleader` is set only in `lua/kolbbond/set.lua`, which loads first, so `<leader>`
in a spec's `keys =` table resolves correctly.

Packer was the previous manager and is fully removed from the config. The
`plugin/packer_compiled.lua` entry in `.gitignore` is a leftover of that era.

Custom forks are used for: gruvbox, harpoon2, vim-be-good, nvim-matlab.

## LSP Configuration

Servers configured in `after/plugin/lsp.lua`:
- **clangd** - C/C++ (header-insertion disabled)
- **pylsp** - Python with pycodestyle
- **lua_ls** - Lua with vim globals
- **matlab_ls** - Requires `MATLAB_ROOT_DIR` env var

For C++ projects, set `CMAKE_EXPORT_COMPILE_COMMANDS ON` in CMakeLists.txt for clangd.

### clang-format

`after/plugin/clang_format.lua` resolves a binary at first use rather than
hardcoding a version, in this order:

1. `vim.g.clang_format_bin`, if set (explicit override, accepts a full path)
2. `clang-format-15` (some projects pin this)
3. the highest-numbered `clang-format-<N>` found on PATH
4. plain `clang-format`

If none exist it reports what it tried instead of failing on a hardcoded name.
Style comes from the nearest `.clang-format` -- for this machine that is
`~/defcon/dotfiles/.clang-format`, which current clang-format releases parse
without complaint.

## Key Mappings (Leader = Space)

- `<leader>pv` - Open netrw file explorer
- `<leader>pf` - Telescope file search
- `<leader>ps` - Telescope ripgrep search
- `<leader>sh` - Switch header/source (C/C++)
- `<leader>af` - clang-format current buffer (C/C++)
- `<leader>lr` - Restart LSP (`:lsp restart`, nvim 0.12 core command)
- `<leader>cfp` - Copy current file path
- `<leader>sl` - Send line to Python REPL
- `<leader>mf` - Run entire MATLAB file
- `<leader>rr` - Run MATLAB section/cell
- `Ctrl+L` - Run single MATLAB line
- `Alt+h/j/k/l` - Move between nvim splits and tmux panes (Alt, not Ctrl:
  `<C-h>` is Harpoon and `<C-l>` is SlimeSend here)

## Build Integration

AsyncRun is used for non-blocking builds with tmux integration. The `modules.lua` file provides `notify_build_status()` for build success/failure notifications.

## Debug Adapters (nvim-dap)

Configured in `after/plugin/dap.lua`:
- GDB, LLDB (codelldb), CppDBG for C/C++
- debugpy for Python
- local-lua-debugger for Lua

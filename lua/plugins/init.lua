-- Lazy.nvim plugin specifications
-- This file imports all plugin modules and returns them as a single table

return {
    { import = "plugins.core" },
    { import = "plugins.lsp" },
    { import = "plugins.ui" },
    { import = "plugins.debug" },
    { import = "plugins.repl" },
    { import = "plugins.tools" },
    { import = "plugins.themes" },
}

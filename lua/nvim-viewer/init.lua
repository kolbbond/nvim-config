-- nvim-viewer: process/state viewer for neovim
local M = {}

function M.get_buffer_info()
    local bufs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            table.insert(bufs, {
                id = buf,
                name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t") or "[No Name]",
                modified = vim.bo[buf].modified,
                filetype = vim.bo[buf].filetype,
                lines = vim.api.nvim_buf_line_count(buf),
            })
        end
    end
    return bufs
end

function M.get_lsp_info()
    local clients = {}
    for _, client in ipairs(vim.lsp.get_clients()) do
        table.insert(clients, {
            name = client.name,
            id = client.id,
            buffers = #client.attached_buffers,
            root = vim.fn.fnamemodify(client.root_dir or "", ":~"),
        })
    end
    return clients
end

function M.get_plugin_info()
    local ok, lazy = pcall(require, "lazy")
    if not ok then return {} end
    local plugins = {}
    for _, plugin in ipairs(lazy.plugins()) do
        table.insert(plugins, {
            name = plugin.name,
            loaded = plugin._.loaded ~= nil,
            time = plugin._.loaded and plugin._.loaded.time or 0,
        })
    end
    table.sort(plugins, function(a, b) return a.time > b.time end)
    return plugins
end

function M.get_memory_info()
    return {
        lua_mem = collectgarbage("count"),  -- KB
    }
end

function M.open()
    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].filetype = "nvim-viewer"

    -- Build content
    local lines = {}
    local function add(str) table.insert(lines, str) end
    local function sep() add(string.rep("─", 50)) end

    add("  NVIM VIEWER")
    sep()

    -- Memory
    local mem = M.get_memory_info()
    add(string.format("  Lua Memory: %.2f MB", mem.lua_mem / 1024))
    sep()

    -- Buffers
    add("  BUFFERS")
    for _, b in ipairs(M.get_buffer_info()) do
        local mod = b.modified and " [+]" or ""
        add(string.format("    %d: %s (%s) %d lines%s", b.id, b.name, b.filetype, b.lines, mod))
    end
    sep()

    -- LSP
    add("  LSP CLIENTS")
    local lsp = M.get_lsp_info()
    if #lsp == 0 then
        add("    (none)")
    else
        for _, c in ipairs(lsp) do
            add(string.format("    %s [%d] - %d buffers - %s", c.name, c.id, c.buffers, c.root))
        end
    end
    sep()

    -- Plugins (top 10 by load time)
    add("  PLUGINS (top 10 by load time)")
    local plugins = M.get_plugin_info()
    for i, p in ipairs(plugins) do
        if i > 10 then break end
        local status = p.loaded and string.format("%.2fms", p.time) or "not loaded"
        add(string.format("    %s: %s", p.name, status))
    end
    sep()

    add("")
    add("  Press 'q' to close, 'r' to refresh")

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    -- Open window
    local width = 60
    local height = #lines
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = math.min(height, 30),
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = "minimal",
        border = "rounded",
        title = " nvim-viewer ",
        title_pos = "center",
    })

    -- Keymaps
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
    vim.keymap.set("n", "r", function()
        vim.api.nvim_win_close(win, true)
        M.open()
    end, { buffer = buf })
end

-- Command
vim.api.nvim_create_user_command("NvimViewer", M.open, {})

return M

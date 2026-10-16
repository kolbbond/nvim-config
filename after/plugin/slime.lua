-- slime (REPL integration)

vim.g.slime_target = 'tmux'
vim.g.slime_cell_delimiter = "# %%"
vim.g.slime_bracketed_paste = 1
-- target pane is wired by open_repl(); never prompt
vim.g.slime_dont_ask_default = 1

-- `vertical`/`horizontal` in vim's sense: vertical = side by side
local SPLITS = {
    vertical = { flag = '-h', size = '40%' },
    horizontal = { flag = '-v', size = '35%' },
}
local last_split = 'vertical'

-- ipython mode routes multi-line sends through %cpaste so indented blocks run.
-- Its `--` terminator is a SyntaxError in plain python, so the flag must match
-- the interpreter that launches; this function owns both.
local function repl_command()
    local venv = os.getenv("VIRTUAL_ENV")
    if not venv or venv == "" then
        vim.g.slime_python_ipython = 1
        return 'ipython3'
    end
    local has_ipython = vim.fn.executable(venv .. "/bin/ipython") == 1
    vim.g.slime_python_ipython = has_ipython and 1 or 0
    return string.format('source "%s/bin/activate" && %s', venv, has_ipython and 'ipython' or 'python')
end
repl_command()

local function tmux(args)
    local out = vim.fn.system(vim.list_extend({ 'tmux' }, args))
    return vim.v.shell_error == 0, vim.trim(out)
end

local function target_pane()
    local cfg = vim.g.slime_default_config
    return cfg and cfg.target_pane
end

local function set_target(pane)
    -- $TMUX = "<socket path>,<pid>,<session>"; slime defaults to the "default" socket
    local socket = vim.split(os.getenv('TMUX') or '', ',')[1]
    vim.g.slime_default_config = { socket_name = socket ~= '' and socket or 'default', target_pane = pane }
    -- b:slime_config caches the previous pane per buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[buf].slime_config then vim.b[buf].slime_config = nil end
    end
end

local function repl_ready(pane)
    local ok, out = tmux({ 'capture-pane', '-p', '-t', pane })
    local last = ok and out:match('[^\n]*$') or ''
    return last:match('^In %[%d+%]:') or last:match('^>>>')
end

local function open_repl(split)
    if not os.getenv('TMUX') then
        vim.notify("Slime: not inside tmux", vim.log.levels.ERROR)
        return
    end
    last_split = split or last_split
    local s = SPLITS[last_split]
    -- -d keeps focus in nvim
    local ok, pane = tmux({ 'split-window', '-d', s.flag, '-l', s.size, '-P', '-F', '#{pane_id}', repl_command() })
    if not ok or not pane:match('^%%%d+$') then
        vim.notify("Slime: failed to open REPL pane: " .. pane, vim.log.levels.ERROR)
        return
    end
    set_target(pane)
    vim.notify("Slime connected to " .. pane)
    return pane
end

local function close_repl()
    local pane = target_pane()
    if pane and tmux({ 'display-message', '-p', '-t', pane, '' }) then
        tmux({ 'kill-pane', '-t', pane })
    end
end

local function restart_repl()
    close_repl()
    return open_repl()
end

local function restart_and_send()
    local pane = restart_repl()
    if not pane then return end
    -- keys sent before the prompt appears are eaten by ipython startup
    if not vim.wait(10000, function() return repl_ready(pane) end, 100) then
        vim.notify("Slime: REPL not ready after 10s, file not sent", vim.log.levels.WARN)
        return
    end
    vim.cmd('%SlimeSend')
end

vim.api.nvim_create_user_command('SlimeClose', close_repl, {})
vim.api.nvim_create_user_command('SlimeRestart', restart_repl, {})
vim.api.nvim_create_user_command('SlimeRestartAndSend', restart_and_send, {})

local map = vim.keymap.set
map('n', '<leader>vp', function() open_repl('vertical') end, { desc = 'Open Python REPL (vertical split)' })
map('n', '<leader>hp', function() open_repl('horizontal') end, { desc = 'Open Python REPL (horizontal split)' })
map('n', '<leader>vc', '<cmd>SlimeConfig<cr>', { desc = 'SlimeConfig' })
map('n', '<leader>sq', close_repl, { desc = 'Close Slime REPL' })
map('n', '<leader>sr', restart_repl, { desc = 'Restart Slime REPL' })
map('n', '<leader>so', restart_and_send, { desc = 'Restart Slime REPL and send file' })

map('n', '<leader>sc', function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>SlimeSendCell", true, false, true), "n", true)
    vim.api.nvim_win_set_cursor(0, pos)
end, { desc = 'Slime send cell and return to cursor', silent = true })

map('n', '<leader>ss', '<cmd>SlimeSend<cr>', { desc = 'Send current line to REPL' })
map('n', '<C-l>', '<cmd>SlimeSend<cr>', { desc = 'Send current line to REPL' })
map('x', '<leader>sv', '<Plug>SlimeRegionSend', { desc = 'Send visual selection to REPL' })
map('n', '<leader>sf', '<cmd>%SlimeSend<cr>', { desc = 'Send current file to REPL' })
map('n', '<leader>sp', '<cmd>1,.SlimeSend<cr>', { desc = 'Send file to cursor to REPL' })

-- run-pane: a tmux shell beside nvim that runs builds (see docs/superpowers/specs/2026-07-15-runfile-hotkey-design.md)

local MAKEFILES = { 'GNUmakefile', 'makefile', 'Makefile' }
local pane

local function tmux(args)
    local out = vim.fn.system(vim.list_extend({ 'tmux' }, args))
    return vim.v.shell_error == 0, vim.trim(out)
end

local function pane_alive()
    return pane and tmux({ 'display-message', '-p', '-t', pane, '' })
end

local function send(cmd)
    if not vim.env.TMUX then
        vim.cmd('botright split | terminal ' .. cmd)
        return
    end
    if not pane_alive() then
        -- -d keeps focus in nvim; plain shell so output survives the run
        local ok, id = tmux({ 'split-window', '-d', '-h', '-l', '40%', '-P', '-F', '#{pane_id}' })
        if not ok then
            vim.notify('run: failed to open pane: ' .. id, vim.log.levels.ERROR)
            return
        end
        pane = id
    end
    tmux({ 'send-keys', '-t', pane, 'C-c' })
    tmux({ 'send-keys', '-t', pane, 'clear; ' .. cmd, 'Enter' })
end

local function close()
    if pane_alive() then tmux({ 'kill-pane', '-t', pane }) end
    pane = nil
end

-- nearest Makefile at or above the buffer's dir, so tex/ subdirs build from their project root
local function make(opts)
    local start = vim.fn.expand('%:p:h')
    if start == '' then start = vim.fn.getcwd() end
    local found = vim.fs.find(MAKEFILES, { upward = true, path = start, stop = vim.env.HOME })[1]
    if not found then
        vim.notify('make: no Makefile at or above ' .. start, vim.log.levels.WARN)
        return
    end
    vim.cmd('silent! wall')
    local dir = vim.fs.dirname(found)
    local args = opts.args ~= '' and ' ' .. opts.args or ''
    send('make -C ' .. vim.fn.shellescape(dir) .. args)
end

vim.api.nvim_create_user_command('Make', make, { nargs = '*', desc = 'make from nearest Makefile in run-pane' })
vim.api.nvim_create_user_command('RunClose', close, {})

vim.keymap.set('n', '<leader>rm', '<cmd>Make<cr>', { desc = 'make (nearest Makefile)' })
vim.keymap.set('n', '<leader>rM', ':Make ', { desc = 'make <target>' })
vim.keymap.set('n', '<leader>rq', close, { desc = 'Close run-pane' })

-- slime (REPL integration)

-- --- vim-slime configuration ---
-- Specify the target for vim-slime
vim.g.slime_target = 'tmux'
vim.g.slime_cell_delimiter = "# %%"
vim.g.slime_bracketed_paste = 1

-- set slime connect command and specified interpreter
--vim.g.slime_tmux_target = new_pane_id
-- @hey: how can we configure this as a function
python_exec = 'ipython3'
--python_exec = 'python3'
vim.g.slime_restart_repl_command = python_exec
vim.g.slime_new_pane_command = 'tmux split-window -h -p 40 -P -F "#{pane_id}" ' .. python_exec;
-- vim.g.slime_restart_repl_command = 'source ~/.venv/myproject/bin/activate && python'

-- opens a tmux pane and connect slime (AI assisted))
function SlimeOpenPythonREPL25V()
    -- Get current pane ID to switch back later, or just assume Neovim will stay focused
    -- local current_pane_id = vim.fn.system('tmux display-message -p "#{pane_id}"')

    -- Create a new vertical pane, % width, and run ipython
    -- The -d flag runs it in the background, so you stay in current pane.
    -- The -P flag prints the pane_id of the new pane.
    -- @hey: add a configurable python version command
    local new_pane_id = vim.fn.system(vim.g.slime_new_pane_command)
    new_pane_id = vim.fn.trim(new_pane_id) -- Remove any trailing newline/whitespace

    if new_pane_id ~= '' then
        -- Tell Slime to connect to this specific new pane
        -- This sets the target for *subsequent* Slime commands
        vim.g.slime_tmux_target = new_pane_id
        print("Slime connected to new tmux pane: " .. new_pane_id)

        -- Optional: send a simple command to test the connection (e.g., Python banner)
        -- vim.fn.feedkeys(':SlimeSend nl<CR>', 'n') -- Sends a newline to prompt REPL
        -- Or send a specific string (not recommended for general use, just for test)
        -- vim.fn.feedkeys(':SlimeSend print("Slime is ready!")<CR>', 'n')
    else
        vim.notify("Failed to open tmux pane for Slime REPL.", vim.log.levels.ERROR)
    end
end

-- restart function courtesy of GEMINI AI 2.5 FLASH
local function SlimeClose()
    -- save buffer?
    --vim.cmd('w')

    -- Check if tmux is running. If not, this function won't work.
    -- This prevents errors if the user tries to run it outside of tmux.
    local tmux_status = vim.fn.system('tmux display-message -p "#S"')
    if tmux_status:match('no server running') then
        vim.notify("Error: tmux is not running. Cannot restart Slime target.", vim.log.levels.ERROR)
        return
    end

    -- 6. Close the old pane (if it exists).
    if vim.g.slime_tmux_target then
        -- Check if the old pane still exists before trying to kill it.
        -- This prevents error messages from tmux if it was already closed.
        local pane_exists_check = vim.fn.system(string.format('tmux has-pane -t %s 2>/dev/null', vim.g.slime_tmux_target))
        if pane_exists_check:match('no such pane') then
            vim.notify("Old Slime pane (" .. vim.g.slime_tmux_target .. ") not found or already closed.",
                vim.log.levels.INFO)
        else
            -- Kill the old pane. Redirect stderr to /dev/null to suppress any minor warnings.
            vim.fn.system(string.format('tmux kill-pane -t %s 2>/dev/null', vim.g.slime_tmux_target))
            vim.notify("Closed old Slime pane: " .. vim.g.slime_tmux_target, vim.log.levels.INFO)
        end
    else
        vim.notify("No previous Slime pane found to close.", vim.log.levels.INFO)
    end

    -- just don't restart
end

-- restart function courtesy of GEMINI AI 2.5 FLASH
local function SlimeRestart()
    -- save buffer?
    --vim.cmd('w')

    -- Check if tmux is running. If not, this function won't work.
    -- This prevents errors if the user tries to run it outside of tmux.
    local tmux_status = vim.fn.system('tmux display-message -p "#S"')
    if tmux_status:match('no server running') then
        vim.notify("Error: tmux is not running. Cannot restart Slime target.", vim.log.levels.ERROR)
        return
    end

    -- 6. Close the old pane (if it exists).
    if vim.g.slime_tmux_target then
        -- Check if the old pane still exists before trying to kill it.
        -- This prevents error messages from tmux if it was already closed.
        local pane_exists_check = vim.fn.system(string.format('tmux has-pane -t %s 2>/dev/null', vim.g.slime_tmux_target))
        if pane_exists_check:match('no such pane') then
            vim.notify("Old Slime pane (" .. vim.g.slime_tmux_target .. ") not found or already closed.",
                vim.log.levels.INFO)
        else
            -- Kill the old pane. Redirect stderr to /dev/null to suppress any minor warnings.
            vim.fn.system(string.format('tmux kill-pane -t %s 2>/dev/null', vim.g.slime_tmux_target))
            vim.notify("Closed old Slime pane: " .. vim.g.slime_tmux_target, vim.log.levels.INFO)
        end
    else
        vim.notify("No previous Slime pane found to close.", vim.log.levels.INFO)
    end

    -- use our repl function
    SlimeOpenPythonREPL25V();
end

local SlimeRestartAndSend = function()
    -- Restart the Slime target and send the current file to it.
    SlimeRestart()       -- Restart the target first
    vim.cmd('SlimeSend') -- Send the current file to the REPL
end

-- Create a user command that can be called with :SlimeRestart from Neovim.
vim.api.nvim_create_user_command('SlimeClose', SlimeClose, {})
vim.keymap.set('n', '<Leader>sq', ':SlimeClose<CR>', { desc = 'Close Slime Target' })

vim.api.nvim_create_user_command('SlimeRestart', SlimeRestart, {})
vim.keymap.set('n', '<Leader>sr', ':SlimeRestart<CR>', { desc = 'Restart Slime Target' })

vim.api.nvim_create_user_command('SlimeRestartAndSend', SlimeRestartAndSend, {})
vim.keymap.set('n', '<Leader>so', ':SlimeRestartAndSend<CR>', { desc = 'Restart Slime Target and send file' })

-- Keymaps
-- @hey: we need a :SlimeRestart
--       also can we prevent the run cell command from moving the cursor?

-- Map a key to call this function, e.g., <leader>vp (vertical python)
-- open and config keymaps
vim.api.nvim_set_keymap('n', '<leader>vp', ':lua SlimeOpenPythonREPL25V()<CR>',
    { noremap = true, silent = true, desc = 'Open Python REPL in 25% tmux split' })
vim.api.nvim_set_keymap('n', '<leader>vc', "<cmd>SlimeConfig<cr>",
    { noremap = true, silent = true, desc = 'SlimeConfig' })

-- keymaps to send
vim.api.nvim_set_keymap('n', '<leader>sc', "<Plug>SlimeSendCell<BAR>/^# %%<CR>",
    { noremap = true, silent = true, desc = 'Slime send cell' })
vim.api.nvim_set_keymap('n', '<leader>ss', ':SlimeSend<CR>',
    { noremap = true, silent = true, desc = 'Send visual selection or current line to REPL' })
vim.api.nvim_set_keymap('n', '<C-l>', ':SlimeSend<CR>',
    { noremap = true, silent = true, desc = 'Send visual selection or current line to REPL' })
vim.api.nvim_set_keymap('v', '<leader>sv', '<esc>:SlimeRegionSend<CR>',
    { noremap = true, silent = true, desc = 'Send visual selection to REPL' })
vim.api.nvim_set_keymap('n', '<leader>sf', ':%SlimeSend<CR>',
    { noremap = true, silent = true, desc = 'Send current file to REPL' })

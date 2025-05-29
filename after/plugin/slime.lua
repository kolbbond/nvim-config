-- slime (REPL integration)

-- --- vim-slime configuration ---
-- Specify the target for vim-slime
vim.g.slime_target = 'tmux'
vim.g.slime_cell_delimiter = "# %%"
vim.g.slime_bracketed_paste = 1

-- opens a tmux pane and connect slime (AI assisted))
function SlimeOpenPythonREPL25V()
    -- Get current pane ID to switch back later, or just assume Neovim will stay focused
    -- local current_pane_id = vim.fn.system('tmux display-message -p "#{pane_id}"')

    -- Create a new vertical pane, % width, and run ipython
    -- The -d flag runs it in the background, so you stay in current pane.
    -- The -P flag prints the pane_id of the new pane.
    -- @hey: add a configurable python version command
    local new_pane_id = vim.fn.system('tmux split-window -h -p 40 -P -F "#{pane_id}" ipython3')
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
vim.api.nvim_set_keymap('v', '<leader>sv', '<esc>:SlimeRegionSend<CR>',
    { noremap = true, silent = true, desc = 'Send visual selection to REPL' })
vim.api.nvim_set_keymap('n', '<leader>sf', ':%SlimeSend<CR>',
    { noremap = true, silent = true, desc = 'Send current file to REPL' })

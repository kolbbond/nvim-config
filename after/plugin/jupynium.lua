-- jupynium keymaps
-- all under <leader>ju prefix, buffer-local to *.ju.* files

local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

--- Run a Jupynium command and notify on success/failure.
local function jupynium_start(cmd)
    vim.notify("Jupynium: starting...", vim.log.levels.INFO)
    local ok, err = pcall(vim.cmd, cmd)
    if not ok then
        vim.notify("Jupynium: " .. err, vim.log.levels.ERROR)
        return
    end
    -- check server pid after giving it time to spin up
    vim.defer_fn(function()
        local server = require("jupynium.server")
        if server.jupynium_pid() then
            vim.notify("Jupynium: server running (pid " .. server.jupynium_pid() .. ")", vim.log.levels.INFO)
        else
            vim.notify("Jupynium: server failed to start — use :JupyniumStartAndAttachToServerInTerminal to debug", vim.log.levels.ERROR)
        end
    end, 3000)
end

-- Server/sync lifecycle
map("n", "<leader>jus", function() jupynium_start("JupyniumStartAndAttachToServer") end, "Jupynium start server")
map("n", "<leader>jua", function() jupynium_start("JupyniumAttachToServer") end, "Jupynium attach to server")
map("n", "<leader>juy", "<cmd>JupyniumStartSync<cr>", "Jupynium start sync")
map("n", "<leader>juq", "<cmd>JupyniumStopSync<cr>", "Jupynium stop sync")

-- Execute / clear
map({ "n", "x" }, "<leader>jux", "<cmd>JupyniumExecuteSelectedCells<cr>", "Jupynium execute cell")
map("n", "<S-CR>", "<cmd>JupyniumExecuteSelectedCells<cr>", "Jupynium execute current cell")
map({ "n", "x" }, "<leader>juc", "<cmd>JupyniumClearSelectedCellsOutputs<cr>", "Jupynium clear cell output")
map("n", "<leader>juX", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if Jupynium_syncing_bufs == nil or Jupynium_syncing_bufs[bufnr] == nil then
        vim.notify("Jupynium: not syncing — run :JupyniumStartSync first", vim.log.levels.ERROR)
        return
    end
    -- select entire buffer so the browser selects all cells
    vim.cmd("normal! ggVG")
    -- wait for visual selection to sync to browser, then execute
    vim.defer_fn(function()
        vim.cmd("JupyniumExecuteSelectedCells")
        -- exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end, 300)
end, "Jupynium execute ALL cells")
map("n", "<leader>juK", "<cmd>JupyniumKernelHover<cr>", "Jupynium kernel hover (inspect)")
map("n", "<leader>jur", "<cmd>JupyniumKernelRestart<cr>", "Jupynium restart kernel")

-- Scroll / navigation
map({ "n", "x" }, "<leader>jul", "<cmd>JupyniumScrollToCell<cr>", "Jupynium scroll to cell")
map({ "n", "x" }, "<leader>juo", "<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>", "Jupynium toggle output scroll")
map("n", "<leader>jud", "<cmd>JupyniumDownloadIpynb<cr>", "Jupynium download .ipynb")
map("n", "<leader>jut", "<cmd>JupyniumShortsightedToggle<cr>", "Jupynium toggle shortsighted")

-- Cell navigation (these are short since you use them a lot)
map({ "n", "x", "o" }, "]j", "<cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<cr>", "Next Jupynium cell")
map({ "n", "x", "o" }, "[j", "<cmd>lua require'jupynium.textobj'.goto_previous_cell_separator()<cr>", "Prev Jupynium cell")

-- Text objects
map({ "x", "o" }, "aj", "<cmd>lua require'jupynium.textobj'.select_cell(true, false)<cr>", "Around Jupynium cell")
map({ "x", "o" }, "ij", "<cmd>lua require'jupynium.textobj'.select_cell(false, false)<cr>", "Inside Jupynium cell")

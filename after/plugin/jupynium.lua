-- jupynium keymaps
-- all under <leader>ju prefix, buffer-local to *.ju.* files

local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Server/sync lifecycle
map("n", "<leader>jus", "<cmd>JupyniumStartAndAttachToServer<cr>", "Jupynium start server")
map("n", "<leader>jua", "<cmd>JupyniumAttachToServer<cr>", "Jupynium attach to server")
map("n", "<leader>juy", "<cmd>JupyniumStartSync<cr>", "Jupynium start sync")
map("n", "<leader>juq", "<cmd>JupyniumStopSync<cr>", "Jupynium stop sync")

-- Execute / clear
map({ "n", "x" }, "<leader>jux", "<cmd>JupyniumExecuteSelectedCells<cr>", "Jupynium execute cell")
map({ "n", "x" }, "<leader>juc", "<cmd>JupyniumClearSelectedCellsOutputs<cr>", "Jupynium clear cell output")
map("n", "<leader>juK", "<cmd>JupyniumKernelHover<cr>", "Jupynium kernel hover (inspect)")
map("n", "<leader>jur", "<cmd>JupyniumKernelRestart<cr>", "Jupynium restart kernel")

-- Scroll / navigation
map({ "n", "x" }, "<leader>jul", "<cmd>JupyniumScrollToCell<cr>", "Jupynium scroll to cell")
map({ "n", "x" }, "<leader>juo", "<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>", "Jupynium toggle output scroll")
map("n", "<leader>jud", "<cmd>JupyniumDownloadIpynb<cr>", "Jupynium download .ipynb")
map("n", "<leader>jut", "<cmd>JupyniumShortsightedToggle<cr>", "Jupynium toggle shortsighted")

-- Run entire file (select all cells then execute)
map("n", "<leader>juR", "ggVG<cmd>JupyniumExecuteSelectedCells<cr><esc>", "Jupynium run entire file")

-- Cell navigation (these are short since you use them a lot)
map({ "n", "x", "o" }, "]j", "<cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<cr>", "Next Jupynium cell")
map({ "n", "x", "o" }, "[j", "<cmd>lua require'jupynium.textobj'.goto_previous_cell_separator()<cr>", "Prev Jupynium cell")

-- Text objects
map({ "x", "o" }, "aj", "<cmd>lua require'jupynium.textobj'.select_cell(true, false)<cr>", "Around Jupynium cell")
map({ "x", "o" }, "ij", "<cmd>lua require'jupynium.textobj'.select_cell(false, false)<cr>", "Inside Jupynium cell")

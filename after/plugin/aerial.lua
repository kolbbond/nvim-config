-- Aerial keymaps
vim.keymap.set("n", "<leader>ao", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial outline" })
vim.keymap.set("n", "<leader>an", "<cmd>AerialNext<CR>", { desc = "Next aerial symbol" })
vim.keymap.set("n", "<leader>ap", "<cmd>AerialPrev<CR>", { desc = "Prev aerial symbol" })
vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { desc = "Prev aerial symbol" })
vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { desc = "Next aerial symbol" })

-- Telescope integration
local ok, telescope = pcall(require, "telescope")
if ok then
    pcall(telescope.load_extension, "aerial")
    vim.keymap.set("n", "<leader>as", "<cmd>Telescope aerial<CR>", { desc = "Search symbols (Aerial)" })
end
